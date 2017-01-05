function [rast_object] = blinkingstim_counts(ds, mycell, mycellname, dirname, times)
% BLINKINGSTIM_COUNTS Calculate raster for blinkingstim grid location
%
%   [RAST_OBJECT] = BLINKINGSTIM_COUNTS(DS, MYCELL, MYCELLNAME, DIRNAME)
%

if ischar(dirname),
    s = getstimscripttimestruct(ds,dirname);
    [s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
    s.mti = s.mti(inds_nottotrim);
else,
    s = dirname{1};
    dirname = dirname{2};
end;

do = getDisplayOrder(s.stimscript);

rast_inp.spikes = mycell;
rast_inp.triggers = {};
rast_inp.condnames = {};

rast_p.res = 0.001;
rast_p.interval = []; % below
rast_p.cinterval = []; % below
rast_p.showcbars = 1;
rast_p.fracpsth = 0.5;
rast_p.normpsth = 1;
rast_p.showvar = 1;
rast_p.psthmode = 1;
rast_p.showfrac = 1;
rast_p.axessameheight = 1;

where.figure = figure;
where.rect = [ 0 0 1 1];
where.units = 'normalized';

start_time = 0; % arbitrary initialization, gets overwritten later
end_time = 10;

for i=1:length(do),

	if i==1, 
		start_time = s.mti{i}.startStopTimes(2);
	end;

	if i==length(do),
		end_time = s.mti{i}.startStopTimes(3);
	end;

	stim = get(s.stimscript,do(i));
	% analyze all stims
	p = getparameters(stim);
	rast_p.interval = [times(1) times(2)]; % assume these are all the same
	rast_p.cinterval = [times(1) times(2)];
	V = getgridvalues(stim);
	[X,Y] = getgrid(stim); % get grid dimensions

	blinkList = getgridorder(stim);

	for gridloc = 1 : max(blinkList),
		rast_inp.triggers{gridloc} = [];
        	triggerTimes = s.mti{i}.frameTimes(find(blinkList==gridloc));
		rast_inp.triggers{gridloc} = cat(1,rast_inp.triggers{gridloc},triggerTimes(:));
		rast_inp.condnames{gridloc} = int2str(gridloc);
	end;

end;


rast_object = raster(rast_inp, rast_p, where);

co = getoutput(rast_object);

rast_bg_inp = rast_inp;
rast_bg_params = rast_p;
rast_bg_where = [];

trigger_rand = zeros(size(triggerTimes)) + start_time + rand(size(triggerTimes))*(end_time-start_time);

rast_bg_inp.triggers = {trigger_rand};
rast_bg_inp.condnames= {'random'};

rast_background = raster(rast_bg_inp, rast_bg_params, rast_bg_where);
cb = getoutput(rast_background);


figure;

img_hz = reshape(co.ncounts-cb.ncounts,X,Y);
imagesc(img_hz); colorbar;


