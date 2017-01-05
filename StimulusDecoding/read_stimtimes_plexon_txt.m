function [stimids, stimtimes, frametimes] = read_stimtimes_plexon_txt(dirname)
% READ_STIMTIMES_PLEXON_TXT - Interpret the stimtimes.txt file written by VH lab Spike2
%
%   [STIMIDS, STIMTIMES, FRAMETIMES] = READ_STIMTIMES_PLEXON_TXT(DIRNAME)
%
%  Reads the stimulus ids, stimulus times, and frame times for each stimulus
%  from the 'stimtimes_plexon.txt' file located in the directory DIRNAME (full path
%  needed).
%  
%  STIMIDS is a vector containing the stim id of each stimulus presentation.
%     If this is unavailable in the exported events, then NaN is coded for each
%     stimulus.
%  STIMTIMES is a vector with the time of stimulus onset for each stimulus
%     presentation.
%  FRAMETIMES is a cell list of the times of all of the video frame updates
%     (that produced triggers). FRAMETIMES{i} is a vector of the frame times
%     for stimulus presentation i.
%   

fname = 'stimtimes_plexon.txt';

fname_alt = 'stimtimes_plexon.mat';

gotit = 0;

if exist([dirname filesep fname_alt]), % try to use binary file
    try,
        events = load([dirname filesep fname_alt],'FrameTrigger','StimulusTrigger','Strobed','-mat');
        events.stimid = events.Strobed(:,2);
        gotit = 1;
    end;
end;

if ~gotit,
    events = read_plexon_events_txt([dirname filesep fname]);
end;

stimtimes = events.StimulusTrigger;

frametimes = {};

% frametimes
for i=1:length(stimtimes),
	if i<length(stimtimes),
		matches = (events.FrameTrigger>=stimtimes(i)&events.FrameTrigger<stimtimes(i+1));
		frametimes{i} = events.FrameTrigger(matches);
		events.FrameTrigger= events.FrameTrigger(~matches); % drop the frametimes we just assigned
	else,
		frametimes{i} = events.FrameTrigger; % assign remaining frametimes to this stimulus
	end;

end;

if isfield(events,'stimid'),
	stimids = events.stimid;
else,
	stimids = nan(size(stimtimes));
end;


