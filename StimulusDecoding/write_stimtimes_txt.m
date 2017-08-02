function write_stimtimes_txt(dirname, stimids, stimtimes, frametimes, filename)
%  WRITE_STIMTIMES_TXT - Write the stimtimes.txt file given stimids, stimtimes, and frametimes for each stimulus
%
%   WRITE_STIMTIMES_TXT(DIRNAME, STIMIDS, STIMTIMES, FRAMETIMES, [FILENAME])
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
%   One may optionally provide the input FILENAME, which will write to the
%   filename FILENAME. By default FILENAME is 'stimtimes.txt' or
%   'stimontimes.txt'
% 
%   See also: READ_STIMTIMES_TXT
%

if nargin<5,
	filename = 'stimtimes.txt';
end;

if nargin<4,
	if nargin<5,
		filename = 'stimontimes.txt';
	end

	if exist([dirname filesep filename],'file'),
		error(['Could not write ' filename ' ; file already exists in ' dirname '.']);
	end;

	fid = fopen([dirname filesep filename],'wt');

	if fid<0,
		error(['Could not open the file ' dirname filesep filename ' for writing: ' ferror(fid)]);
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

if exist([dirname filesep filename],'file'),
	error(['Could not write ' filename '; file already exists in ' dirname '.']);
end;

fid = fopen([dirname filesep filename],'wt');

if fid<0,
	error(['Could not open the file ' dirname filesep filename ' for writing: ' ferror(fid)]);
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


