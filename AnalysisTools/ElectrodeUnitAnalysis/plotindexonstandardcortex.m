function [h_data,h_layerborders] = plotindexonstandardcortex(indexvalues, depths, layerborders, xaxis)

% PLOTINDEXONSTANDARDCORTEX - plot index values on a "standard" cortex
%
%   [H_DATA] = PLOTINDEXOSTANDARDCORTEX(INDEXVALUES,CELLDEPTHS)
%      or
%   [H_DATA,H_LAYERBORDERS] = PLOTINDEXOSTANDARDCORTEX(INDEXVALUES,...
%        CELLDEPTHS, LAYERBORDERS, XAXIS)
%
%  This function plots the index values where depths are normalized to a
%  "standard cortex".  INDEXVALUES are the index value to plot, and 
%  CELLDEPTHS are standardized cell depths for the cells to be plotted.
%  If the optional argument LAYERBORDERS is given, then dashed lines indicating
%  layer boundaries are plotted (from min(XAXIS) to max(XAXIS)).  The layer
%  borders are moved to the "back" of the plot (that is, the deepest layer,
%  so that cells will be plotted on the "surface" of the "paper").
%
%  The Matlab plotting handles for the data (H_DATA) and, if layer borders are
%  requested, the layer borders (H_LAYERBORDERS) are provided.

hold on;
h_data = plot(indexvalues,depths,'o');

h_layerborders = [];

if nargin>2,
	if ~isempty(layerborders),
		for i=1:length(layerborders),
			h_layerborders(end+1) = plot([min(xaxis) max(xaxis)],[1 1]*layerborders(i),'k--');
		end;
		movetoback(h_layerborders); % move these to the back of the plot
	end;
end;

set(gca,'ydir','reverse');
