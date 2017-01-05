function [avgstim, gridsize, numspikes] = singleunit_rc(ds, mycell, mycellname, dirname, mintime, maxtime, stepsize)
% SINGLEUNIT_RC Calculate reverse-correlation for blinkingstim, stochasticgridstim
%
%   [AVGSTIM, GRIDSIZE, NUMSPIKES] = SINGLEUNIT_RC(DS, MYCELL, MYCELLNAME, DIRNAME)
%     or
%   [AVGSTIM, GRIDSIZE, NUMSPIKES] = SINGLEUNIT_RC(DS, MYCELL, MYCELLNAME, DIRNAME, MN, MX, STEP)
%
%   Computes the reverse correlation of the spikes from the SPIKEDATA object MYCELL with
%   name MYCELLNAME, associated with the experimental directory specified in the 
%   DIRSTRUCT DS, for the stimulus in subdirectory DIRNAME.
%
%   AVGSTIM is a NUM_TIMESTEPS x NUM_GRIDPOINTS array in units of contrast.
%
%   GRIDSIZE is the X and Y dimensions of the original grid.
%   
%   If MN, MX, and STEP are provided then the reverse correlation calculation is calculated
%   from MN to MX in step sizes of STEP (all units in seconds from stimulus frame onset).
%   If these values are not provided, then default values are used: MN=-0.1,MX=0.5,STEP=0.001 .
%   

if nargin<5,
	mnt = -0.1;
else,
	mnt = mintime;
end;

if nargin<6,
	mt = 0.5;
else,
	mt = maxtime;
end;

if nargin<7,
	stsz = 0.001;
else,
	stsz = stepsize;
end;

if ischar(dirname),
    s = getstimscripttimestruct(ds,dirname);
    [s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
    s.mti = s.mti(inds_nottotrim);
else,
    s = dirname{1};
    dirname = dirname{2};
end;

kerneltimes = mnt:stsz:mt;

do = getDisplayOrder(s.stimscript);

avgstim = [];

numspikes = 0;

for i=1:length(do),
	stim = get(s.stimscript,do(i));
	% analyze all stims
	p = getparameters(stim),
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
	spiketimes=get_data(mycell,[s.mti{i}.frameTimes(1)-10 s.mti{i}.frameTimes(end)+10],2);
	numspikes = numspikes + length(spiketimes);
	avgstim_=spike_triggered_average_stepfunc(spiketimes,kerneltimes,s.mti{i}.frameTimes,cols');
	avgstim = cat(3,avgstim,avgstim_);
end;

figure;
subplot(2,1,1);
if size(avgstim,2)==1,
	imagesc(1:size(V,1),kerneltimes,avgstim);
	set(gca,'ydir','reverse');
else,
	pcolor(1:size(V,1),kerneltimes,mean(avgstim,3)); shading flat; 
end;
colormap(gray(256));
subplot(2,1,2);
[bs,bsimg] = rc_bootstrap(avgstim,1000);
image(bsimg);set(gca,'ydir','normal');


