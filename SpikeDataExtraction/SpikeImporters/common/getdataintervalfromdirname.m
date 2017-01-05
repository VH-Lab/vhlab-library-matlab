function [interval,starttime] = getdataintervalfromdirname(dirname)
% GETDATAINTERVALFROMDIRNAME - Return the interval that data was recorded on the Stimulus computer's clock
%
%  [INTERVAL,STARTTIME] = GETDATAINTERVALFROMDIRNAME(DIRNAME)
%
%  Returns the interval of time that spikes were recorded from the directory DIRNAME.
%  
%  Assumes the existence of a 'stims.mat' file and 'stimtimes.txt' file.
%
%  If the interval cannot be found, empty is returned for INTERVAL and STARTIME.


if exist([dirname filesep 'stims.mat'])&exist([dirname filesep 'stimtimes.txt']),
	g = load([dirname filesep 'stims.mat'],'MTI2','start');
	[mti2,starttime]=tpcorrectmti(g.MTI2,[dirname filesep 'stimtimes.txt'],1);
	interval = [starttime mti2{end}.frameTimes(end)+10]; % assume 10 sec of post recording
	interval = interval;
	starttime = g.start;
else,
	interval = [];
	starttime = [];
end;
