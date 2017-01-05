function output = lfpcomp_integ(L, stdintervals, intvals, intspvals,name, B, A)

% LFPCOMP_INTEG - Calculates mean absolute value over an interval for LFP/CSD data
%
%  OUTPUT = LFPCOMP_INTEG(L, [NOT_USED], TIMEINTERVALS, SPONTINTERVALS, NAMES, B, A)
%
%  Computes the mean absolute value of response for various time intervals.
%
%  B,A are optional arguments for filtering.  If present, the data are
%  filtered using FILTFILT.
%
%  OUTPUT is a struct with the following element:
%
%    t_NAME{i}   A list of each trial's response.   The string NAME{i} is
%                appended so one could call the function many times with
%                different output names.
%    ts_NAME{i}  A list of each trial's response during spontaneous interval
%                TS0..TS1.   The string NAME is appended so one could call
%                the function many times with different output names.
%
%   TIMEINTERVALS is a matrix of time intervals in the format
%       TIMEINTERVALS = [ TSTART1 TEND1; TSTART2 TEND2; ... ];
%   SPONTINTERVALS is a matrix of time intervals of spontaneous activity
%       SPONTINTERVALS = [ TS0_1 TS1_1 ; TS0_2 TS1_2; ... ];
%
%   NAMES should be a cell list of names with the same number of entries as
%   rows in the [TSTART TEND;...] and [TSO TS1;...] matricies.

T = {}; Ts = {};

shouldfilter = nargin>5;

for p=1:length(name),
	tstart(p) = findclosest(L(:,1),intvals(p,1));
	tend(p) = findclosest(L(:,1),intvals(p,2));
	ts0(p) = findclosest(L(:,1),intspvals(p,1));
	ts1(p) = findclosest(L(:,1),intspvals(p,2));
end;

for i=2:size(L,2),
	if shouldfilter,
		d = filtfilt(B,A,L(:,i));
	else, d = L(:,i);
	end;
	for p=1:length(name),
		T{p}(i-1) = mean(abs(d(tstart(p):tend(p))));
		Ts{p}(i-1) = mean(abs(d(ts0(p):ts1(p))));
	end;
end;

output = [];
for p=1:length(name),
	output = setfield(output,['t_' name{p} ], T{p});
	output = setfield(output,['ts_' name{p} ], Ts{p});
end;
