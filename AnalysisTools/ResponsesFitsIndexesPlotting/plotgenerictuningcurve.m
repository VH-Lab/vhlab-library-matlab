function plotgenerictuningcurve(cell,cellname,responsecurve,blankval,fitcurve,xaxislabel,showeb,xaxis,yaxis,colorkey,symbolkey)
% PLOTGENERICTUNINGCURVE - Plot a generic tuning curve
%     
%  PLOTGENERICTUNINGCURVE(CELL,CELLNAME,REPONSECURVE,BLANKVAL,FITCURVE,...
%         XAXISLABEL,SHOWEB,XAXIS,YAXIS,COLORKEY,SYMBOLKEY)
%
%
%  Plots a generic tuning curve on the current axes, and gives it the cell
%  title.
%
%   Grabs the associate from cell CELL called RESPONSECURVE; this function
%   assumes it is 4 rows: first row is X axis, second row is data, third row
%   is standard deviation, 4th row is standard error.  
%
%   If given, the FITCURVE associate is also read, and is plotted (first row
%   x axis, second row data).
%   
%   If a BLANKVAL is provided, then it is plotted as well (mean plus standard error).
%
%   The X-axis is labeled according to the string in XAXISLABEL.
%
%   If SHOWEB is present and is 0, then error bars are not shown.
%   
%   If XAXIS =[XMIN XMAX] is present, then the X axis will be set to those values.
%   If YAXIS =[YMIN YMAX] is present, then the Y axis will be set to those values.
%   If COLORKEY is present, then that color will be used; default is 'k' (black, see help plot).
%   If SYMBOLKEY is present, then that symbol will be used; default is 's' (square, see help plot).
%
%   The title of the plot is set to CELLNAME with no interpreter.
%
%   See also: PLOT
 
if ~isempty(responsecurve), rc = findassociate(cell,responsecurve,'',''); else, rc = []; end;
if ~isempty(fitcurve), fc = findassociate(cell,fitcurve,'',''); else, fc = []; end;
if ~isempty(blankval), bl = findassociate(cell,blankval,'',''); else, bl = []; end;
if nargin>6, eb = showeb; else, eb = 1; end;
if nargin>7, xlim = xaxis; else, xlim = []; end;
if nargin>8, ylim = yaxis; else, ylim = []; end;
if nargin>9, color = colorkey; else, color = 'k'; end;
if nargin>10, marker = symbolkey; else, marker = 's'; end;

wedidsomething = 0;

if ~isempty(rc),
	plot(rc.data(1,:),rc.data(2,:),[marker color]);
	hold on;
	wedidsomething = 1;
	if eb,
		h=myerrorbar(rc.data(1,:),rc.data(2,:),rc.data(4,:),rc.data(4,:),color);
		delete(h(2));
	end;
end;

if ~isempty(fc),
	wedidsomething = 1;
	plot(fc.data(1,:),fc.data(2,:),[color '-']);
	hold on;
end;

a = axis;

xlow = min([a(1);xlim(:)]);
xhigh = max([a(2);xlim(:)]);

if ~isempty(bl),
	wedidsomething = 1;
	plot([xlow xhigh],bl.data(1)*[1 1],[color '--']);
	if eb,
		hold on;
		plot([xlow xhigh],bl.data(1)*[1 1]-bl.data(3)*[1 1],[color '--']);
		plot([xlow xhigh],bl.data(1)*[1 1]+bl.data(3)*[1 1],[color '--']);
	end;
end;

if ~wedidsomething, % if they were all empty just return, don't make an axes by calling axis, etc
	return;
end;

a = axis;

if ~isempty(xlim),
	axis([xlim a([3 4])]);
end;

a = axis;

if ~isempty(ylim),
	axis([a([1 2]) ylim]);
end;


xlabel(xaxislabel);
title(cellname,'interp','none');

box off;
