function summary = fix_stimtimes_txt_glitch(dirname, varargin)
% FIX_STIMTIMES_TXT_GLITCH - Fixes a common stimtimes.txt file detection glitch with large numbers of stimuli and VHTrig device (USB-1208FS)
%
%  SUMMARY = FIX_STIMTIMES_TXT_GLITCH(DIRNAME, ...)
%
%  Fixes a common glitch that occurs when registering stimulus triggers using
%  Spike2 (CED Micro1401) and the VHTrig software run through Psychtoolbox and
%  USB-1208FS. At the time of this writing, the source of the problem is not known
%  but we believe it is related to one of those items.
%
%  The glitch results in an extra stimulus trigger occasionally being generated
%  after certain stim numbers are presented.  This program examines the statistics
%  and removes erroneous stim triggers.  
%
%  A copy of the original file is save as 'stimtimes_original.txt'. If this file exists
%  then it is not overwritten.
%
%  INPUTS: DIRNAME is the full path of the directory to be examined.
%
%  The behavior of the function can be modified by passing additional variables as
%  name/value pairs:
%  NAME (default):                  | Description
%  ---------------------------------------------------------------------------
%  makenochanges (0)                | 0/1 If 1, then the function merely summarizes changes
%                                   |    but makes no changes to any file
%  overwrite_stimtimes_original (0) | 0/1 If stimtimes_original.txt exists, should we
%                                   |    overwrite it?
%  stims_that_trigger_glitches [... | This is a list of stimuli that have been known to produce
%    111 127]                       |    glitches. Any stimulus with 0 data frames ('frame triggers')
%                                   |    that follows these stimuli will be removed, provided that
%                                   |    this resolves all descrepencies between the 'stimtimes.txt'
%                                   |    file and the 'stims.mat' file. If these conditions are not
%                                   |    met, the function gives up and produces an error.
%  error_on_failure (1)             | 0/1 Produce an error on failure.
%  
%  OUTPUTS: SUMMARY is a cell array of strings with all of the problems that were found and
%  changes made.
%    

makenochanges = 0;
overwrite_stimtimes_original = 0;
stims_that_trigger_glitches = [111 127];
error_on_failure = 1;

assign(varargin{:});

summary = {};

glitch_lines = [];

[stimids_stimtimes_txt,stimtimes,frametimes] = read_stimtimes_txt(dirname);

z = load([dirname filesep 'stims.mat']);

stimids_stims_mat = [];

for i=1:length(z.MTI2),
	stimids_stims_mat(end+1) = z.MTI2{i}.stimid;
end;

my_suspect_lines = [];

if length(stimids_stimtimes_txt) > length(stimids_stims_mat), % it is a candidate for the glitch fixing
	for i=2:length(stimids_stimtimes_txt),
		if any(stimids_stimtimes_txt(i-1)==stims_that_trigger_glitches) & isempty(frametimes{i}),
			my_suspect_lines(end+1) = i;
		end;
	end;
end;

canwefixit = 0;

if ~isempty(my_suspect_lines),
	% see if removing them would solve the problem
	indexes_good = setdiff(1:length(stimids_stimtimes_txt),my_suspect_lines);
	if eqlen(stimids_stimtimes_txt(indexes_good),stimids_stims_mat), % if it would fix the problem entirely
		canwefixit = 1;
	end;
end;

if canwefixit,

	% we can also assume indexes_good exists as a variable

	% Step 1: summarize the issues
	summary = {['Suspected glitch stim codes found on the following lines: ' int2str(my_suspect_lines) '.']};
	
	% Step 2: fix it
	if ~makenochanges,
		% Step 2.1) copy the file to a backup, if needed
		if exist([dirname filesep 'stimtimes_original.txt'],'file'),
			if overwrite_stimtimes_original & exist([dirname filesep 'stimtimes.txt']),
				summary{end+1} = ['Moving stimtimes.txt to stimtimes_original.txt, overwriting the original stimtimes_original.txt file.'];
				delete([dirname filesep 'stimtimes_original.txt']);
				movefile([dirname filesep 'stimtimes.txt'],[dirname filesep 'stimtimes_original.txt']);
			end; % otherwise don't do anything, leave the original original alone
		else,
				summary{end+1} = ['Moving stimtimes.txt to stimtimes_original.txt.'];
				movefile([dirname filesep 'stimtimes.txt'],[dirname filesep 'stimtimes_original.txt']);
		end;

		% Step 2.2) write the new file
		summary{end+1} = ['Writing new stimtimes.txt file.'];
		write_stimtimes_txt(dirname,stimids_stimtimes_txt(indexes_good),stimtimes(indexes_good),frametimes(indexes_good));
	end;
end;

if error_on_failure & (canwefixit==0),
	error(['Could not fix stimtimes.txt file in directory ' dirname '.']);
end;

