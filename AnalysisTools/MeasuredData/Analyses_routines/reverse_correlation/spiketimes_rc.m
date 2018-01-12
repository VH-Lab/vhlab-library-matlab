function [out] = spiketimes_rc(ds, dirname, spiketimes, varargin);
% SPIKETIMES_RC Calculate reverse-correlation for blinkingstim, stochasticgridstim
%
%   [OUT] = SPIKETIMES_RC(DS, DIRNAME, SPIKETIMES, ...)
%
%   Computes the reverse correlation of the spikes from the SPIKETIMES (in the local directory
%   time base) for the stimulus in subdirectory DIRNAME of the directory mananaged by the DIRSTRUCT
%   object DS.
%
%   The output is a structure OUT with fields:
%
%   REV_CORR is a NUM_TIMESTEPS x NUM_GRIDPOINTS array that is an estimate of the linear
%   kernel that can produce VM given the stimulus in DIRNAME. It is just
%   XC_STIMSIGNAL filtered by the autocorrelation of the stimulus. For spike records, this
%   REV_CORR is often bad.
%
%   XC_STIMSIGNAL is a NUM_TIMESTEPS x NUM_GRIDPOINTS array that is the
%   correlation of the spiketimes with the stimulus in DIRNAME.
%
%   GRIDSIZE is the X and Y dimensions of the original grid.
%
%   GRIDSIZE is the X and Y dimensions of the original grid.
%
%
%   Parameter (default value)    |  Description
%   ---------------------------------------------------------------------------------
%   mnt (-0.100)                 |  The minimum value of the time window of the
%                                |     correlation window (seconds)
%   mt (0.500)                   |  The maximum value of the time window of the
%                                |     correlation window (seconds)
%   step (0.001)                 |  The time window/kernel window step size (seconds)
%   DoMedFilter (1)              |  Should we filter the REV_CORR filter? (0/1)
%   MedFilterWidth (3)           |  What should the width of the median filter be?
%   stim_pres_to_include ([])    |  Stimulus presentations to include ([] means all)
%   stim_pres_to_exclude ([])    |  Stimulus presentations numbers to exclude ([] means none)
%   usespike01 (1)               |  Use a vector of 0/1 spikes with time resolution step
%                                |    Otherwise, arbitrary precision spikes are used

mnt = -0.1;
mt = 0.5;
step = 0.001;
DoMedFilter = 1;
MedFilterWidth = 3;
stim_pres_to_include = [];
stim_pres_to_exclude = [];
usespike01 = 1;

assign(varargin{:});

if ischar(dirname),
	s = getstimscripttimestruct(ds,dirname);
	[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,0);
	s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1); % not used
	s.mti = s.mti(inds_nottotrim);
	[stimids,allstimtimes,frameTimes] = read_stimtimes_txt([getpathname(ds) filesep dirname]);
else,
    s = dirname{1};
    dirname = dirname{2};
end;

kerneltimes = mnt:step:mt;

do = getDisplayOrder(s.stimscript);

if isempty(stim_pres_to_include),
	stim_pres_to_include = 1:length(do);
end;

good_pres = ismember(1:length(do), stim_pres_to_include) & ~ismember(1:length(do), stim_pres_to_exclude);
good_pres_indexes = find(good_pres);

rev_corr = [];
rev_corr_raw = [];
xc_stimsignal = [];
xc_stimstim = [];

numspikes = 0;

for i=1:good_pres_indexes,
	stim = get(s.stimscript,do(i));
	% analyze all stims
	p = getparameters(stim);
	V = getgridvalues(stim);
	[X,Y] = getgrid(stim); % get grid dimensions
	gridsize = [X Y];
	% grayscale
	if isa(stim,'stochasticgridstim'),
		colsgray = rescale(mean(p.values,2),[0 256],[-1 1]);
	elseif isa(stim,'blinkingstim'),
		colsgray = rescale(mean([p.BG;p.value],2),[0 256],[0 1]);
	end;
	cols = colsgray(V);
	if min(size(cols))==1, cols = cols'; end;
	stimoffsets = s.mti{i}.frameTimes;
	numspikes = numspikes + length(spiketimes);
	%avgstim_=spike_triggered_average_stepfunc(spiketimes,kerneltimes,s.mti{i}.frameTimes,cols');
	xc_stimstim = autocorrelation(stim,step,length(kerneltimes),1);
	xc_stimstim = xc_stimstim(:,1); % first column
	%xc_stimstim = []; % force it to calculate it manually
	if usespike01,
		t_local = (frameTimes{i}(1)-5) : step : (frameTimes{i}(end)+1) ;
		spike01 = histc(spiketimes,t_local);
		[rev_corr_,rev_corr_raw_,xc_stimsignal_,xc_stimstim]=reverse_correlation_mv_stepfunc(spike01, t_local, kerneltimes,...
			frameTimes{i}(:)',cols', 'dt',step,'dx',1,'xc_stimstim',xc_stimstim,'DoMedFilter',DoMedFilter,...
			'MedFilterWidth',MedFilterWidth);
	else,
		[rev_corr_, rev_corr_raw_, xc_stimsignal_, xc_stimstim] = reverse_correlation_stepfunc(spiketimes, [], ...
			kerneltimes, frameTimes{i}(:)',cols','dt',step,'dx',1,'xc_stimstim',xc_stimstim,'DoMedFilter',DoMedFilter,...
			'MedFilterWidth',MedFilterWidth);
	end;
	rev_corr = cat(3,rev_corr,rev_corr_);
	rev_corr_raw = cat(3,rev_corr_raw,rev_corr_raw_);
	xc_stimsignal = cat(3,xc_stimsignal,xc_stimsignal_);
end;

avg_revcorr = mean(rev_corr);
avg_revcorr_raw = mean(rev_corr_raw);
avg_xcstimsignal = mean(xc_stimsignal,3);

[Rinv,R] = whitening_filter_from_autocorr(xc_stimstim,length(kerneltimes));

avg_xc_deconvolved = Rinv * avg_xcstimsignal / (step * 1);

if DoMedFilter,
	avg_xc_deconvolved = medfilt1(avg_xc_deconvolved, MedFilterWidth);
end;

out = var2struct('rev_corr','rev_corr_raw','xc_stimsignal','xc_stimstim','avg_revcorr','avg_revcorr_raw','avg_xcstimsignal',...
	'avg_xc_deconvolved','gridsize','kerneltimes');

