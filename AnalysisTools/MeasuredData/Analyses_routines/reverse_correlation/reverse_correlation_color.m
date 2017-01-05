function [avgstim, gridsize, numspikes] = reverse_correlation_color(mycell, stimtime, mintime, maxtime, stepsize)
% SINGLEUNIT_RC Calculate reverse-correlation for blinkingstim, stochasticgridstim
%
%   [AVGSTIM, GRIDSIZE, NUMSPIKES] = REVERSE_CORRELATION_COLOR(MYCELL, STIMTIMES, MN, MX, STEP)
%
%   Computes the reverse correlation of the spikes from the SPIKEDATA object MYCELL with a set of 
%   STIMSCRIPTTIMESTRUCTs STIMTIMES (see 'help getstimscripttimestruct').
%   The reverse correlation calculation is calculated from MN to MX in step sizes of STEP (all units
%   in seconds from stimulus frame onset).
%   
%   AVGSTIM is a NUM_TIMESTEPS x NUM_GRIDPOINTS array in units of contrast.
%
%   GRIDSIZE is the X and Y dimensions of the original grid.
%
%   NUMSPIKES is the number of spikes fired during the stimulus presentations.

numspikes = 0;
kerneltimes = mintime:stepsize:maxtime;
avgstim = [];

for m=1:length(stimtime),
	do = getDisplayOrder(stimtime(m).stimscript);
	for d=1:length(do),
		stim = get(stimtime(m).stimscript);
		p = getparameters(stim);
		V = getgridvalues(stim);
		[X,Y] = getgrid(stim);
		gridsize = [X Y];
		spiketimes = get(mycell,[stimtime(m).mti{d}.frameTimes(1)-5 stimtime(m).mti{d}+5,2);
		numspikes = numspikes + length(spiketimes);
		avgstim_ = [];
		for c = 1:size(p.values,2),
			cols = p.values(V,c);
			avg_stim__ = spike_triggered_average_stepfunc(spiketimes,kerneltimes,stimtimes{m}.frameTimes,cols');
			avgstim_ = cat(3,avgstim__,avgstim_);
		end;
		avgstim = cat(4,avgstim,avgstim_);
	end;
end;


