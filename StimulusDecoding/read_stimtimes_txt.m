function [stimids, stimtimes, frametimes] = read_stimtimes_txt(dirname)
% READ_STIMTIMES_TXT - Interpret the stimtimes.txt file written by VH lab Spike2
%
%   [STIMIDS, STIMTIMES, FRAMETIMES] = READ_STIMTIMES_TXT(DIRNAME)
%
%  Reads the stimulus ids, stimulus times, and frame times for each stimulus
%  from the 'stimtimes.txt' file located in the directory DIRNAME (full path
%  needed).
%  
%  STIMIDS is a vector containing the stim id of each stimulus presentation.
%  STIMTIMES is a vector with the time of stimulus onset for each stimulus
%     presentation.
%  FRAMETIMES is a cell list of the times of all of the video frame updates
%     (that produced triggers). FRAMETIMES{i} is a vector of the frame times
%     for stimulus presentation i.
%   

fname = 'stimtimes.txt';

fid = fopen([dirname filesep fname]);

if fid<0,
	error(['Could not open file ' fname ' in directory ' dirname '.']);
end;

stimids = [];
stimtimes = [];
frametimes = {};

i = 0;

while ~feof(fid),
	i = i + 1;
	stimline = fgets(fid);
	if ~isempty(stimline)&~eqlen(-1,stimline),
		stimdata = sscanf(stimline,'%f');
		if ~isempty(stimdata),
			try,
				stimids(i) = stimdata(1);
				stimtimes(i) = stimdata(2);
				frametimes{i} = stimdata(3:end);
			catch,
				fclose(fid);
				error(['error in ' dirname filesep fname '.']);
			end;
		end;
	end;
end;

fclose(fid);
