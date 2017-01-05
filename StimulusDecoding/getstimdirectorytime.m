function time = getstimdirectorytime(dirname, varargin)
% GETSTIMDIRECTORYTIME - Get the time that a recording was made
%
%  TIME = GETSTIMDIRECTORYTIME(DIRNAME)
%
%  Return the time that a recording in the directory DIRNAME was made.
%  The time is given in seconds since midnight on the first day of the experiment.
%  We assume that recordings done before EarlyMorningCutOffTime (default 5am) occurred
%  during the evening of the experiment (24 hours * 60 minutes/hour * 60 seconds/minute later
%  than the literal seconds since midnight).
%
%  One can add additional name/value pairs to alter the behavior of the function:
%  Name (default):             | Description
%  -------------------------------------------------------------
%  WarnOnEarlyMorning (1)      | Warn if early morning recordings are found;
%                              |     these are assumed to be recordings on the next day
%  EarlyMorningCutOffTime (5)  | Early morning cut off time in hours (NaN for none)
%  ErrorIfEmpty (1)            | Produce an error if no time information is found
%  
%  Examples: 
%       t = getstimdirectorytime('/User/vanhoosr/data/2013-05-05/t00001')
%       t = getstimdirectorytime('/User/vanhoosr/data/2013-05-05/t00001','ErrorIfEmpty',1)
%

ErrorIfEmpty = 1;
EarlyMorningCutOffTime = 5;
WarnOnEarlyMorning = 1;

assign(varargin{:});

time = NaN;

fname1 = [dirname filesep 'stims.mat'];
fname2 = [dirname filesep 'spike2data.smr'];
fname3 = [dirname filesep 'filetime.txt'];

if exist(fname1)==2&exist(fname2)==2&exist(fname3)==2,
	time = load(fname3,'-ascii'); % time in seconds since midnight
	isearlymorning = 0;
	if ~isnan(EarlyMorningCutOffTime),
		if time<EarlyMorningCutOffTime * 60 * 60,
			isearlymorning = 1;
			time = time + 24*60*60;
		end;
	end;
	if isearlymorning & WarnOnEarlyMorning,
		warning(['For directory ' dirname ', the function GETSTIMDIRECTORYTIME is assuming that recordings between midnight and ' num2str(EarlyMorningCutOffTime) ' were done the next day.']);
	end;
else,
	if ErrorIfEmpty,
		error(['No time information found for directory ' dirname '.']);
	end;
end;
