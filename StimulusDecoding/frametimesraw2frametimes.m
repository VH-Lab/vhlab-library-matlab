function frametimes = frametimesraw2frametimes(frametimesraw, stimtimes)
% FRAMETIMESRAW2FRAMETIMES - Convert a list of raw frame triggers to stimulus-divided frame times
%
%  FRAMETIMES = FRAMETIMESRAW2FRAMETIMES(FRAMETIMESRAW, STIMTIMES)
%
%  Given a raw list of frame times in FRAMETIMESRAW (that is, the time of each frame trigger),
%  and the time that each stimulus occurred STIMTIMES, this function computes a cell list
%  FRAMETIMES that, in each element FRAMETIMES{i}, has only the frame triggers during the presentation
%  of that stimulus.  Any frame triggers taken between the onset of the ith stimulus onset and the i+1th
%  stimulus onset are attributed to stimulus i. For the last stimulus, all frametimes occuring after the
%  last stimulus onset are attributed to the last stimulus.
%
%  See also: WRITE_STIMTIMES_TXT
%

eps = 1e-3;  % frame triggers must happen at least 1 ms before the stimulus onset of the next stim

frametimes = {};

for i=1:length(stimtimes),
	start = stimtimes(i);
	if i<length(stimtimes),
		stop = stimtimes(i+1)-eps;
	else,
		stop = Inf;
	end;
	frametimes{i} = frametimesraw( find( frametimesraw>=start & frametimesraw<=stop ) );
end;


