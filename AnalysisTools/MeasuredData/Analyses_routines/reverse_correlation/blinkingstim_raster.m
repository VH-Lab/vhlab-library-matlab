function [rast_object] = blinkingstim_raster(ds, mycell, mycellname, dirname, gridloc, time_before, time_after)
% BLINKINGSTIM_RASTER Calculate raster for blinkingstim grid location
%
%   [RAST_OBJECT] = BLINKINGSTIM_RASTER(DS, MYCELL, MYCELLNAME, DIRNAME, GRIDLOC,...
%                      [TIME_BEFORE, TIME_AFTER])
%
%


if nargin>5,
	t_before = time_before;
else, t_before = 0;
end;

if nargin>6,
	t_after = time_after;
else,
	t_after = NaN;
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

do = getDisplayOrder(s.stimscript);

rast_inp.spikes = mycell;
rast_inp.triggers = {[]};
rast_inp.condnames = {[mycellname ', grid=' int2str(gridloc)]};

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

for i=1:length(do),
	stim = get(s.stimscript,do(i));
	% analyze all stims
	p = getparameters(stim);
	if isnan(t_after),
		t_after2 = 1/p.fps;
	else, 
		t_after2 = t_after;
	end;
	rast_p.interval = [t_before t_after2]; % assume these are all the same
	rast_p.cinterval = [t_before t_after2];
	V = getgridvalues(stim);
	[X,Y] = getgrid(stim); % get grid dimensions

	blinkList = getgridorder(stim);
        triggerTimes = s.mti{i}.frameTimes(find(blinkList==gridloc));

	rast_inp.triggers{1} = cat(1,rast_inp.triggers{1},triggerTimes(:));
end;

rast_object = raster(rast_inp, rast_p, where);

