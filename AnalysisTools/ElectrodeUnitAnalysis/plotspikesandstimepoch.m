function plothandles = plotspikesandstimsepoch(ds, cell, cellname, testdir, varargin)
% PLOTSPIKESANDSTIMSEPOCH - plot spikes and stimulus times for one testdir (epoch)
%
% PLOTHANDLES = PLOTSPIKESANDSTIMSEPOCH(DS, CELL, CELLNAME, TESTDIR)
%
% Plots, in the current axes, the spikes (as vertical hashes) and stimulus
% times for the cell CELL with cell name CELLNAME for any stimuli and data
% acquired in directory TESTDIR. The experiment directory is managed by the DIRSTRUCT DS.
% 
% PLOTHANDLES is a struct with fields SPIKES (the plot handles to the spike ticks),
% STIMBARS (the plot handles to the stimulus bars), and STIMTEXT (plot handles to the
% stimulus text id numbers).
%
% This function also takes name/value pairs that modify the behavior of the function:
% Parameter (default)       | Description
% ---------------------------------------------------------------------------------
% subtract_firststimtime (1)| Subtract the time of the first stimulus so that time is
%                           | local to the epoch rather than being global
%
% See also: GETSTIMSCRIPT, SPIKETIMES_PLOT, PLOT_STIMULUS_TIMESERIES

subtract_firststimtime = 1;

assign(varargin{:});

mypathname = getpathname(ds);

[stimscript,mti] = getstimscript(fullfile(mypathname,testdir));
mti = tpcorrectmti(mti,[getpathname(ds) filesep testdir filesep 'stimtimes.txt']);


stimon = [];
stimoff = [];
stimid = [];

for i=1:numel(mti),
	stimon(i) = mti{i}.startStopTimes(2);
	stimoff(i) = mti{i}.startStopTimes(3);
	stimid(i) = mti{i}.stimid;
end;

sp = get_data(cell, [stimon(1)-1 stimoff(end)+1]);

if subtract_firststimtime,
	stimon = stimon - mti{1}.startStopTimes(2);
	stimoff = stimoff - mti{1}.startStopTimes(2);
	sp = sp - mti{1}.startStopTimes(2);
end;

plothandles.spikes = spiketimes_plot(sp);

hold on;

[plothandles.stimbars,plothandles.stimtext] = plot_stimulus_timeseries(1, stimon, stimoff, 'stimid', stimid,...
		'textycoord',1+0.2);

a = axis;
axis([a(1) a(2) 0 2]);
box off;

