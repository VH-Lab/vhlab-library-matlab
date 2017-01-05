function h=addtrainingangleshade(angle,varargin)
% ADDTRAININGANGLESHADE - add a shaded box indicating training angle
%
%  H = ADDTRAININGANGLESHADE(ANGLE, ...)
%
%  Adds a shaded filled rectangle to the graph, indicating the training angle. The patch is
%  then put at the "back" of the figure so it lies underneath the other graphic
%  objects.
%  
%  One can also modify the behavior of this function by passing name/value pairs:
%  Parameter (default value):       | Description
%  ---------------------------------------------------------------
%  width (45)                       | Width of the shade along the X axis, in degrees
%  keepaxis (1)                     | Restore the axis to whatever it was before drawing
%  ymax (-1)                        | Use this ymin; if less than 0, use the y axis boundary
%  ymin (-1)                        | Use this ymin; if less than 0, use the yaxis boundary
%  color ([0.5 0.5 0.5])            | Color of the shaded patch
%  
%  See also: FILL
%

width = 45;
keepaxis = 1; 
ymax = -1;
ymin = -1;
color = [0.5 0.5 0.5];

assign(varargin{:});


a = axis;
if ymax<0,
	ymax = a(4);
end;
if ymin<0,
	ymin = a(3);
end;

x = [angle] + 0.5 * width * [-1 1];
y = [ymin ymax];

patch_vertexes = [ x(1) y(1) ; x(1) y(2); x(2) y(2); x(2) y(1) ];

h=fill(patch_vertexes(:,1),patch_vertexes(:,2),color);
set(h,'edgecolor',color);

  % now send this new graphic object to the back of the axes plot
ch = get(gca,'children');
set(gca,'children',ch([2:end 1]));

if keepaxis, % restore the axis if necessary
	axis(a);
end;
