function [h,data] = plot_csd_cycle_latencym(N,M,csd,stiminds,time,ncyc,cyclength, xaxis, yaxis, depths)

% PLOT_CSD_CYCLE_LATENCY - Plots CSD tuning across stimulus conditions
%
%   [H,DATA] = PLOT_CSD_CYCLE_LATENCY(N,M,CSD,STIMINDS,TIME,NCYC,CYCLENGTH,XAXIS,YAXIS,DEPTHS)
%
%   Plots means and standard errors of of responses for each channel in a CSD struct.
%   CSD structure is assumed to be an array [NUMSTIMS]x[NUMCHANNELS] of structures.
%   TIME is a vector that is TIME = [ START STOP STEP WINDOWSIZE],
%   where START and STOP indicate the time (in seconds) to start and stop plotting and
%   STEP indicates the step between data points.  NCYC is the number of times the
%   cycle is repeated from time 0 assuming a length of CYCLENGTH.  WINDOWSIZE is
%   the windowsize.  PLOT_CSD_LATENCY will use this information to look for
%   named entries in the CSD struct.  For example, if
%   TIME = [ 0.030 0.050 0.020 0.020 ] will look for a struct entries
%   called 'tm_030_050' and 'tm_050_070'.  STIMINDS is a vector of stimuli
%   numbers to include in the average.  All of the stimuli will be averaged together.
%
%   [XMIN XMAX] and [YMIN YMAX] are used to set the axes for all conditions.
%   (They are all set to be the same.)
%
%   DEPTHS is an array of depths for each channel.

start = time(1); stop = time(2); step = time(3); wsz = time(4);

if size(stiminds,2)>size(stiminds,1), stiminds = stiminds'; end;

name1 = {};
name2 = {};

for n=1:ncyc,
	tind = 1;
	for t=start:step:stop,
		t_ = (n-1)*cyclength+t; t__ = t_+wsz;
		name1{n,tind} = sprintf('tm_%.3d_%.3d',round(t_*1000),round(1000*t__));
		name2{n,tind} = sprintf('tms_%.3d_%.3d',round(t_*1000),round(1000*t__));
		tind = tind+1;
	end;
end;
data = compute_csd_tune3(csd,stiminds,name1,name2,1);


xdata = (start:step:stop) + wsz/2;

h = [];

ymax = -Inf; ymin = Inf;

for i=1:N*M,
	h(end+1) = subplot(N,M,i); hold off;
	ydata = []; yerr = [];
	for t=1:length(data),
		ydata(end+1) = data(t).mn(i,1);
		yerr(end+1) = data(t).stderr(i,1);
	end;
	hold on;
	myerrorbar(xdata,ydata,yerr,yerr);
	A = axis;
	if A(3)<ymin, ymin = A(3); end;
	if A(4)>ymax, ymax = A(4); end;
	title([int2str(depths(i)) ' \mum']);
end;

for i=1:length(h),
	axes(h(i));
	A = axis;
	axis([xaxis yaxis]);
	hold on;
	ydata = []; yerr = []; stats = [];
	for t=1:length(data),
		ydata(end+1) = data(t).mn2(i,1);
		yerr(end+1) = data(t).stderr2(i,1);
		stats(end+1) = data(t).kw(i,1);
	end;
	g = myerrorbar(xdata,ydata,yerr,yerr);
	set(g,'color',[0.7 0.7 0.7]);
	plot(xdata, (stats<0.01)*[max(yaxis)-min(yaxis)]+min(yaxis), 'o');
	set(gca,'ytick',[]);
end;
