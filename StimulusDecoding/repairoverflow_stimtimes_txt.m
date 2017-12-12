function repairoverflow_stimtimes_txt(dirname, skiplineafteroverflow, stimtimes_file, stims_mat_file, goodframes)
% REPAIROVERFLOW_STIMTIMES_TXT - repair stimtimes.txt file where numstims > 255
%
% REPAIROVERFLOW_STIMTIMES_TXT(DIRNAME, SKIPLINEAFTEROVERFLOW, ...
%      STIMTIMES_FILENAME, STIMS_MAT, GOODFRAMES)
%
% This function attempts to reconcile the stimulus that was displayed on
% the stimulus computer and saved as STIMS_MAT and the stimulus trigger times
% that were recorded on an acquisition device, saved in STIMTIMES_FILENAME.
% It attempts to fix errors that occur when the stimulus computer tries to
% express stimulus numbers greater than 255 (which it cannot, given it has 
% 8 stimulus bits).
%
% In some recording, after an overflow error, there is an extra line that
% needs to be removed. If that is the case, set SKIPLINEAFTEROVERFLOW to 1.
% Otherwise, it can be 0.
%
% If STIMTIMES_FILENAME is not provided, 'stimtimes.txt' is used.
% If STIMS_MAT filename is not provided, 'stims.mat' is used.
%
% GOODFRAMES is the number of frames in a proper stimulus. It defaults to 10.
% 
% The results are saved to a file called 'stimtimes-repaired.txt'
%
% The format of the STIMTIMES_FILENAME is described in STIMTIMES_TXT.


fout = ['stimtimes_repaired.txt'];

if nargin<2,
    skiplineafteroverflow = 0;
end

if nargin<3,
	stimtimes_file = 'stimtimes.txt';
end;

if nargin<4,
	stims_mat = 'stims.mat';
end;

if nargin<5,
	goodframes = 10;
end

fin = [dirname filesep stimtimes_file];

load([dirname filesep stims_mat],'-mat');

[stimids,stimtimes,frametimes] = read_stimtimes_txt(dirname,stimtimes_file);

stimtimes_entry = 1;
i = 1;

stimids_new = [];
stimtimes_new = [];
frametimes_new = {};

do = getDisplayOrder(saveScript);

disp(['Total stims to display: ' int2str(numel(do)) '.']);

while i<=numel(do),
	disp(['displayorder: ' int2str(i) ' stimtimes line#: ' int2str(stimtimes_entry) ...
		' stimshouldbe: ' int2str(do(i)) ...
		' stimis: ' int2str(stimids(stimtimes_entry)) ...
		' stimtime: ' num2str(stimtimes(stimtimes_entry))])
	recordthisentry = 1;
	if numel(frametimes{stimtimes_entry})<goodframes,
		disp('hmmm, a mismatch we did not expect')
		recordthisentry = 0;
	end
	if recordthisentry,
		stimids_new(i) = do(i);
		stimtimes_new(i) = stimtimes(stimtimes_entry);
		frametimes_new{i} = frametimes{stimtimes_entry}(1:goodframes);
	end
	stimtimes_entry = stimtimes_entry + 1;
	if skiplineafteroverflow&recordthisentry&(do(i)>=255), % skip an extra entry
		stimtimes_entry = stimtimes_entry + 1;
	end
	if recordthisentry,
		i = i + 1;
	end
end

write_stimtimes_txt(dirname,stimids_new,stimtimes_new,frametimes_new,fout);

