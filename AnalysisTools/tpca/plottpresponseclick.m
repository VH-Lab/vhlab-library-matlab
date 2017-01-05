function h0 = plottpresponseclick(cell,cellname,Xn,Yn,varargin)

% PLOTTPRESPONSECLICK - Plots responses for a cell using PLOTTPRESPONSE
%
%   H = PLOTTPRESPONSECLICK(CELL,CELLNAME,XN,YN,...)
%
%  This is a function that simply calls PLOTTPRESPONSE.  It can be a
%  useful clickfunction for TPSCATTERPLOT.
%
%  CELL is the measureddata object to be plotted, and CELLNAME is
%  the name of this object.  XN and YN are ignored but are present
%  because TPSCATTERPLOT provides them as input.
% 
%  Extra arguments can be provided as name/value pairs.  For example,
%    adding 'property','OT Fit Pref' will set property to 'OT Fit Pref'.
%
%  Extra arguments can be:
%
%  EB:  If 1 (default), then error bars of original data points are shown.
%  FIT: If 1, then a fit to the data is shown.
%  PROPERTY:  The property tp be plotted.
%
%  Known PROPERTY codes:
%
%     'OT Pref'
%     'OT Fit Pref'
%     'OT Fit Pref 2 Peak'
%     'POS Fit Pref'
%     'Recovery OT Fit Pref 2 Peak'
%
%  If property is 'Recovery OT Fit Pref 2 Peak', and if a variable DS
%     is passed as an extra variable, then an additional figure is shown
%     with the views of the original cell positions.

eb = 1; fit = 1; property = 'OT Fit Pref';

assign(varargin{:});

figure;
h0 = plottpresponse(cell,cellname,property,eb,fit,varargin{:});

