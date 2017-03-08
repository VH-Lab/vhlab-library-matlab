function [out] = vm_rc(ds, dirname, vm, t, varargin)
% VM_RC Calculate reverse-correlation for blinkingstim, stochasticgridstim
%
%   [OUT] = VM_RC(DS, DIRNAME, VM, T, ...)
%
%   Computes the reverse correlation of the spikes from the SPIKEDATA object MYCELL with
%   name MYCELLNAME, associated with the experimental directory specified in the 
%   DIRSTRUCT DS, for the stimulus in subdirectory DIRNAME.
%
%   The output is a structure OUT with fields:
%
%   REV_CORR is a NUM_TIMESTEPS x NUM_GRIDPOINTS array that is an estimate of the linear
%   kernel that can produce VM given the stimulus in DIRNAME. It is just
%   XC_STIMSIGNAL filtered by the autocorrelation of the stimulus.
%
%   XC_STIMSIGNAL is a NUM_TIMESTEPS x NUM_GRIDPOINTS array that is the
%   correlation of the signal VM with the stimulus in DIRNAME.
%
%   GRIDSIZE is the X and Y dimensions of the original grid.
%   
%   This function also takes parameters in the form of NAME/VALUE pairs:
%   Parameter (default value)    |  Description
%   ---------------------------------------------------------------------------------
%   mnt (-0.100)                 |  The minimum value of the time window of the
%                                |     correlation window (seconds)
%   mt (0.500)                   |  The maximum value of the time window of the 
%                                |     correlation window (seconds)
%   step (0.001)                 |  The time window/kernel window step size (seconds) 
%                                |     If [] is passed, then the native time resolution of T
%                                |     is used (i.e., step = T(2) - T(1))
%   dx (1)                       |  Spatial step size
%   baseline_function ('median') |  The function that should be evaluated to subtract the baseline activity
%                                |     (e.g., 'median', 'mean')
%   DoMedFilter (1)              |  Should we filter the REV_CORR filter? (0/1)
%   MedFilterWidth (3)           |  What should the width of the median filter be?  
%                                |    (See MEDFILT1)
%   stim_pres_to_include ([])    |  Stimulus presentations to include ([] means all)
%   stim_pres_to_exclude ([])    |  Stimulus presentations numbers to exclude ([] means none)
%   contrast_transform ([])      |  Transform contrats from [a1 ... an] to [ b1 ... bn] respectively
%                                |    Should be 2 rows of form [a1 ... an ; b1 ... bn]]
%   normalize_xc_stimsignal (0)  |  Should we normalize the xc_stimsignal by dx and dt?
%   normalize_revcorr (1)        |  Should we normalize the reverse correlation by dx and dt?

mnt = -0.1;
mt = 0.5;
step = 0.001;
dx = 1;
baseline_function = 'median';
DoMedFilter = 1;
MedFilterWidth = 3;
stim_pres_to_include = [];
stim_pres_to_exclude = [];
contrast_transform = [];
normalize_revcorr = 1;
normalize_xc_stimsignal = 0;

assign(varargin{:});
 
if isempty(step),
	step = t(2) - t(1);
end;


if ischar(dirname),
	s = getstimscripttimestruct(ds,dirname);
	[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,0);
	s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1); % not used
	s.mti = s.mti(inds_nottotrim);
	[stimids,allstimtimes,frameTimes] = read_stimtimes_txt([getpathname(ds) filesep dirname]);
	s.shift = -s.mti{1}.startStopTimes(2) + allstimtimes(1);
	% now mactime = spike2time - s.shift;
else,
    s = dirname{1};
    dirname = dirname{2};
end;

%s.shift,

%t = t - s.shift;

kerneltimes = mnt:step:mt;

do = getDisplayOrder(s.stimscript);

if isempty(stim_pres_to_include),
	stim_pres_to_include = 1:length(do);
end;

good_pres = ismember(1:length(do), stim_pres_to_include) & ~ismember(1:length(do), stim_pres_to_exclude);
good_pres_indexes = find(good_pres);

rev_corr = [];
xc_stimsignal = [];
xc_stimstim = [];

for i=good_pres_indexes,
	stim = get(s.stimscript,do(i));
	% analyze all stims
	disp(['Now analyzing stim ' int2str(i) ' of ' int2str(length(do)) '.']);
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
	[ct_i,ct_j] = size(contrast_transform);
	for jj=1:cj_t,
		cols(find(cols==contrast_transform(1,jj))) = contrast_transform(2,jj);
	end;
	stimoffsets = frameTimes{i}; %s.mti{i}.frameTimes;
	baseline_start = findclosest(t,frameTimes{i}(1));       %OR findclosest(t,s.mti{i}.startStopTimes(2)-2*0);
	baseline_end = findclosest(t,frameTimes{i}(end));       %OR findclosest(t,s.mti{i}.startStopTimes(3));
	baseline = feval(baseline_function, vm(baseline_start:baseline_end));
	ind_start = findclosest(t,frameTimes{i}(1)-10);         %OR findclosest(t,s.mti{i}.frameTimes(1) - 10);
	ind_end = findclosest(t,frameTimes{i}(end)+10);         %OR findclosest(t,s.mti{i}.frameTimes(end) + 10);
	I = ind_start:ind_end;
	% compute theoretical autocorrelation
	xc_stimstim = autocorrelation(stim,step,length(kerneltimes),1);
	xc_stimstim = xc_stimstim(:,1);
	%xc_stimstim = []; % calculate it manually
	%if i==1, figure; plot(xc_stimstim), end;     
	[rev_corr_,dummy,xc_stimsignal_,xc_stimstim]=reverse_correlation_mv_stepfunc(vm(I)-baseline,t(I),kerneltimes,...
		frameTimes{i}(:)',cols', 'dt',step,'dx',dx,'xc_stimstim',xc_stimstim,'DoMedFilter',DoMedFilter,...
		'MedFilterWidth',MedFilterWidth,'normalize',normalize_revcorr,'normalize_xc_stimsignal',normalize_xc_stimsignal);
	rev_corr = cat(3,rev_corr,rev_corr_);
	xc_stimsignal = cat(3,xc_stimsignal,xc_stimsignal_);
end;

avg_revcorr = mean(rev_corr,3);
avg_xcstimsignal = mean(xc_stimsignal,3);

[Rinv,R] = whitening_filter_from_autocorr(xc_stimstim,length(kerneltimes));

avg_xc_deconvolved = Rinv * avg_xcstimsignal / (step * dx);

if DoMedFilter,
	avg_xc_deconvolved = medfilt1(avg_xc_deconvolved, MedFilterWidth);
end;

out = var2struct('rev_corr','xc_stimsignal','xc_stimstim','avg_revcorr',...
		'avg_xcstimsignal','avg_xc_deconvolved','gridsize','kerneltimes');

