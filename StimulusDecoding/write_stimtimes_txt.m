function write_stimtimes_txt(dirname, stimids, stimtimes, frametimes)
%  WRITE_STIMTIMES_TXT - Write the stimtimes.txt file given stimids, stimtimes, and frametimes for each stimulus
%
%   WRITE_STIMTIMES_TXT(DIRNAME, STIMIDS, STIMTIMES, FRAMETIMES)
%
%   Writes the 'stimtimes.txt' file that is normally written by
%   Spike2 or our Intan-based system during VH lab recordings. 
%
%   Inputs: DIRNAME, the directory name (full path) where the file should
%   be written; STIMIDS, a list of the stimulus id codes that were presented,
%   STIMTIMES, a list of the presentation time (in Spike2/Intan time units) for each
%   stimulus; and FRAMETIMES, a cell list of the times of all of the data frame
%   presentations that occurred during each stimulus presentation. That is,
%   FRAMETIMES{i} is an array with the stimulus times of stimulus i.
%
%   If FRAMETIMES is not provided, then the file 'stimontimes.txt' is
%   written, which has the same format as 'stimtimes.txt' but lacks
%   frametimes.
% 
%   See also: READ_STIMTIMES_TXT
%

if nargin<4,
    if exist([dirname filesep 'stimontimes.txt'],'file'),
        error(['Could not write stimontimes.txt; file already exists in ' dirname '.']);
    end;
    fid = fopen([dirname filesep 'stimontimes.txt'],'wt');

    if fid<0,
        error(['Could not open the file ' dirname filesep 'stimontimes.txt for writing: ' ferror(fid)]);
    end;

    for i=1:length(stimids),
        fprintf(fid,'%d ', stimids(i));
        fprintf(fid,'%.5f', stimtimes(i));
        fprintf(fid,'\r\n');
    end;

    fprintf(fid,'\r\n');

    fclose(fid);

    return;
end;

if exist([dirname filesep 'stimtimes.txt'],'file'),
	error(['Could not write stimtimes.txt; file already exists in ' dirname '.']);
end;

fid = fopen([dirname filesep 'stimtimes.txt'],'wt');

if fid<0,
	error(['Could not open the file ' dirname filesep 'stimtimes.txt for writing: ' ferror(fid)]);
end;

for i=1:length(stimids),
	fprintf(fid,'%d ', stimids(i));
	fprintf(fid,'%.5f', stimtimes(i));
	for j=1:length(frametimes{i}),
		fprintf(fid,' %.5f', frametimes{i}(j)); % note this includes a space
	end;
	fprintf(fid,'\r\n');
end;

fprintf(fid,'\r\n');

fclose(fid);


