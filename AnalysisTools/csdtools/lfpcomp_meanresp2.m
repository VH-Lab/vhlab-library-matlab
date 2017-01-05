function output = lfpcomp_meanresp2(L, stdintervals, intvals, intspvals, B, A)

% LFPCOMP_MEANRESP - Calculates mean value over an interval for LFP/CSD data
%
%  OUTPUT = LFPCOMP_MEANRESP2(L, [NOT_USED], TIMEINTERVALS, SPONTINTERVALS, B, A)
%
%  Computes the mean response for time intervals.
%   TIMEINTERVALS is an array of time intervals in the format
%       TIMEINTERVALS = [ TSTART TEND WINDOWINTERVAL WINDOWSIZE ];
%   SPONTINTERVALS is an array of time intervals of spontaneous activity
%       SPONTINTERVALS = [ TSPONTSTART WINDOWSIZE ];
%
%  B,A are optional arguments for filtering.  If present, the data are
%  filtered using FILTFILT.
%
%  OUTPUT is a struct with the following element:
%
%    tm_NAME{i}   A list of each trial's response.   The string NAME is
%                XXX_YYY, where XXX is the start of each interval in ms and
%                YYY is the end of each interval in ms.
%    tms_NAME{i}  A list of each trial's response during spontaneous interval
%                TSPONTSTART...TSPONTSTART+WINDOWSIZE.
%
%

shouldfilter = nargin>4;

sampinterval = 1/(L(2,1) - L(1,1));
T0 = findclosest(L(:,1),intvals(1)); T1 = findclosest(L(:,1),intvals(2));
TE = round(intvals(4)*sampinterval); TI = round(intvals(3)*sampinterval);
T0s = findclosest(L(:,1),intspvals(1)); TEs = round(intspvals(2)*sampinterval);

%realsamps = intvals(1):1/sampinterval:intvals(2);;
%realsamps(1), realsamps(end),
samps = intvals(1):intvals(4):(intvals(2)-intvals(4));

W = []; Ws = [];

output = [];

for i=2:size(L,2),
	if shouldfilter,
		d = filtfilt(B,A,L(:,i));
	else, d = L(:,i);
	end;
	W = [W slidingwindow(d,T0,T1,TE)];
	Ws = [Ws slidingwindow(d,T0s,T0s,TEs)];
end;

for p=1:length(samps),
	namet = sprintf('%.3d_%.3d',round(samps(p)*1000),round((samps(p)+intvals(4))*1000));
	output = setfield(output,['tm_' namet],W(round(1+sampinterval*(samps(p)-intvals(1))),:));
	output = setfield(output,['tms_' namet],Ws);
end;
