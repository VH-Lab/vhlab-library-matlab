function [events] = read_plexon_events_txt(filename)
% READ_PLEXON_EVENTS - Read a text file with exported Plexon event data
%
%   [EVENTS] = READ_PLEXON_EVENTS_TXT(FILENAME)
%
%  Reads event data that has been exported from Plexon to a text file. It is assumed
%  that the first row is a 'header' row that has tab delimited field names.
%  Subsequent rows contain tab-delimited data values for these fields.
%  
%  FILENAME is the file name to be opened and read (full path).
%  EVENTS is a structure with field names equal to the those in the header row of the
%  file. The values for the field names are the data points in those fields.
%
%  Keywords: plexon
%   

fid = fopen([filename]);

if fid<0,
	error(['Could not open file ' filename '.']);
end;

try, % handle errors because, if there is an error we still should close the file

	events = struct([]);

	tab = sprintf('\t'); % tab character

	headerline = fgets(fid);
	if isempty(headerline),
		error(['Header line is empty.']);
	end;

	headerline = deblank(headerline); % remove line feeds at the end

	tabs = [0 find(headerline==tab) length(headerline)+1];

	values = {};
	for i=2:length(tabs),
		eval(['events(1).' headerline(tabs(i-1)+1:tabs(i)-1) '=[];']);
		values{i-1} = [];
	end;

	fn = fieldnames(events); % assume they will come in the same order; they should

	while ~feof(fid),
		line = fgets(fid);
		if ~isempty(line)&~eqlen(-1,line),
			line = deblank(line);
			tabs = [0 find(line==tab) length(line)+1];
			for i=2:length(tabs),
				values{i-1} = cat(1,values{i-1},sscanf(line(tabs(i-1)+1:tabs(i)-1),'%f'));
			end;
		end;
	end;

	for i=1:length(fn),
		events = setfield(events,fn{i},values{i});
	end;

	fclose(fid);
catch, 
	fclose(fid);
	error(['Error reading plexon event file: ' lasterr '.']);
end;

