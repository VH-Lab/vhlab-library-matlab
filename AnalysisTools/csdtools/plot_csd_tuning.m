function [h,data] = plot_csd_tuning(N,M,csd,stiminds,name1,name2 ,xaxis, yaxis, depths)

% PLOT_CSD_TUNING - Plots CSD tuning across stimulus conditions
%
%   [H,DATA] = PLOT_CSD_TUNING(N,M,CSD,STIMINDS,NAME1,NAME2,XAXIS,YAXIS,DEPTHS)
%
%   Plots means and standard errors of of responses for each channel in a CSD struct.
%   CSD structure is assumed to be an array [NUMSTIMS]x[NUMCHANNELS] of structures,
%   and each structure must have an numeric entry named NAME1 and NAME2.
%   STIMINDS is a list of stimuli to average over. If STIMINDS has more than one row,
%   it is assumed that all stimuli in a column are the same and should be averaged together.
%
%   [XMIN XMAX] and [YMIN YMAX] are used to set the axes for all conditions.
%   (They are all set to be the same.)
%
%   DEPTHS is an array of depths for each channel.

data = compute_csd_tune2(csd,stiminds,{name1},{name2});

h = [];

ymax = -Inf; ymin = Inf;

for i=1:20,
	h(end+1) = subplot(N,M,i); hold off;
	plot(data.mn(i,:));
	hold on;
	myerrorbar(1:length(data.mn(i,:)),data.mn(i,:),data.stderr(i,:),data.stderr(i,:));
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
	g=myerrorbar(1:length(data.mn(i,:)),data.mn2(i,:),data.stderr2(i,:),data.stderr2(i,:));
	set(g,'color',[0.7 0.7 0.7]);
	plot(1:length(data.mn(i,:)), (data.kw(i,:)<0.01)*max(yaxis), 'o');
	set(gca,'ytick',[]);
end;
