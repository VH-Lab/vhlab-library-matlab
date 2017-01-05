function [cell,assoc] = extractstimdirectorytimes(ds, cell, varargin)
% EXTRACTSTIMDIRECTORYTIMES - Loop through all known TEST directories and extract the time of presentation
%
%   [CELL, ASSOC] = EXTRACTSTIMDIRECTORYTIMES(DS, CELL, ...)
%
%   This function loops through all associates of MEASUREDDATA object CELL, 
%   and finds all those that end with the character string ' test' (capitalization
%   not important). It will then examine that directory, and extract the time that the
%   recording was made.  The time of the recording in seconds is added as an associate
%   with the name 'TESTNAME time', where TESTNAME is the name of the associate
%   ('TESTNAME test').
%
%   One can pass additional arguments (see help GETSTIMDIRECTORYTIME for usage):
%  Name (default):             | Description
%  -------------------------------------------------------------
%  ErrorIfEmptyTestData (1)    | Produce an error if the 'X test' directory is empty
%  WarnOnEarlyMorning (1)      | Warn if early morning recordings are found;
%                              |     these are assumed to be recordings on the next day
%  EarlyMorningCutOffTime (5)  | Early morning cut off time in hours (NaN for none)
%  ErrorIfEmpty (1)            | Produce an error if no time information is found


ErrorIfEmptyTestData = 1;
WarnOnEarlyMorning = 1;
EarlyMorningCutOffTime = 5;
ErrorIfEmpty = 1;

assign(varargin);


assoc = struct('type','','owner','','data','','desc','');
assoc = assoc([]);  % start with an empty list

A = findassociate(cell,'','','');

pn = getpathname(ds);

for i=1:length(A),
	index = strfind(upper(A(i).type), ' TEST');
	if ~isempty(index),
		newtype = [A(i).type(1:index(end)) 'time'];
		if isempty(A(i).data),
			if ErrorIfEmptyTestData,
				error(['Test directory associate label ''' A(i).type ''' is present but is empty.']);
			else,
				warning(['Test directory label ' A(i).type ' is present but empty and will be ignored.']);
			end;
		else,
			time = getstimdirectorytime([pn filesep A(i).data],varargin{:});
			assoc(end+1) = struct('type',newtype,'owner','extractstimdirectorytimes.m','data',time,'desc',...
				'Time of day of the recording; recordings between midnight and early morning are usually shifted 24 hours, unless the user specified otherwise');
			cell = associate(cell,assoc(end));
		end;
	end;
end;

