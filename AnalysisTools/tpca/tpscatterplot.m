function [Xn,Yn]=tpscatterplot(cells,cellnames,assocname_x,funcstring_x,assocname_y,funcstring_y,plotit, varargin)

%  TPSCATTERPLOT - Produces a scatterplot of cell data
%  [Xn,Yn]=TPSCATTERPLOT(CELLS,CELLNAMES,ASSOCNAME_X,FUNCSTRING_X,...
%                ASSOCNAME_Y,FUNCSTRING_Y,PLOTIT, ...);
%
%  Creates a scatterplot of points Xn and Yn based upon data read from
%    measureddata objects.
%
%  CELLS is a cell list of measureddata objects.  CELLNAMES is a cell
%  list of strings with the names of these objects.
%
%  Xn and Yn are determined by a user-specified mathematical operation
%    on associate data.  For each cell, the associates INDEXASSOC_X and
%    INDEXASSOC_Y are read, and local variables x and y are set to the
%    associate data fields.  The local variable 'cell' is set to the
%    current cell being processed.  Xn is computed by evaluating the function
%    in the string FUNCSTRING_Xn.  Note that this function string can use
%    x, y, and cell to operate on the X associate data, the Y associate data,
%    or read other associates from 'cell'.  FUNCSTRING_Yn is similarly evaluated
%    to determine Yn.
%
%  Examples of FUNCSTRING_Xn:
%	'x' just returns the assocate data in ASSOCNAME_X
%       'mod(x,180)' returns the associate data modulo 180
%       'myfunc(x,y,cell)' returns the result of myfunc called with the data
%
%  PLOTIT controls plotting behavior:
%      0 :  data are not plotted
%      1 :  data are plotted in a new window
%      2 :  data are plotted on the current axes, replacing contents
%      3 :  data are plotted on the current axes, preserving contents
%   
%  The user has the option of describing the marker used for each point
%  by passing the MARKER argument, which can be either 1x1 to specify that
%  all points should have the same marker, or 1xLENGTH(CELLS) vector specifying
%  the marker for each cell.  The marker code should be a character following
%  the guidelines in the Matlab PLOT command (e.g., 's' for square).
%
%  MARKERSIZE specifies the markersize of each plotted point.
%    It corresponds to the size of each symbol.  It should be either a 1x1
%    vector to specify that each symbol has one size, or be 1xLENGTH(CELLS)
%    to specify the marker for each data point.  Default size is six.
%
%  COLORS is an optional list of colors to use for the datapoints.  It can be
%    [r g b] to specify the same color for all points, or LENGTH(CELLS)x3 to 
%    specify the color for each cell.
%
%  CLICKFUNCTION
%    Optinally, the user may provide a clickfunction that is executed whenever
%    the user clicks the plot window.  The program will first display the
%    name of the closest clicked cell and the Xn and Yn values, and then
%    call the click function with
%      CLICKFUNCTION(cell, cellname, xn, yn, varargin)
%    where varargin are the additional arguments that were passed to TPSCATTERPLOT.


if nargin==0,  % it is the buttondownfcn
	ud = get(gca,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

	[i,v] = findclosest(sqrt(sum((repmat(pt,length(ud.Xn),1)-[ud.Xn' ud.Yn']).^2')'),0);

	if v<50,
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} ' w/ Xn =' num2str(ud.Xn(i)) ', Yn = ' num2str(ud.Yn(i)) '.']);
		else,
			disp(['Closest cell is # ' int2str(i) ' w/ Xn =' num2str(ud.Xn(i)) ', Yn = ' num2str(ud.Yn(i)) '.']);
		end;
		if ~isempty(ud.clickfunction),
			eval([ud.clickfunction '(ud.cells{i},ud.cellnames{i},ud.Xn(i),ud.Yn(i),ud.varargin{:});']);
		end;
	end;

	return;
end;

  % default parameters:
marker= 'o';
cols = [0 0 0];
markersize = 6 * ones(length(cells),3);
clickfunction = '';

  % assign any user changes to defaults
assign(varargin{:});

  % now fill in values for all cells if necessary
if length(markersize)==1,
	markersize= markersize* ones(1,length(cells));
end;
if length(marker)==1,
	marker= repmat(marker,length(cells),1);
end;

if exist('colors','var'), cols = colors; end;
if size(cols,1) == 1,
	cols = repmat(cols,length(cells),1);
end;

Xn = []; Yn = [];

for i=1:length(cells),
	indx = findassociate(cells{i},assocname_x,'','');
	indy = findassociate(cells{i},assocname_y,'','');
	if ~isempty(assocname_x)&~isempty(assocname_y),
		x = indx.data; y = indy.data; cell = cells{i}; 
		Xn(i)=eval(funcstring_x);
		Yn(i)=eval(funcstring_y);
	end;
end;

%  PLOTIT controls plotting behavior:
%      0 :  data are not plotted
%      1 :  data are plotted in a new window
%      2 :  data are plotted on the current axes, replacing contents
%      3 :  data are plotted on the current axes, preserving contents
%   

if plotit,
	if plotit==1, figure; elseif plotit==2, hold off; elseif plotit==3, hold on; end;

	% check to see if there's old userdata we can add to
	oldud = get(gca,'userdata');

	unique(markersize), unique(marker), unique(cols,'rows'),
	if (length(unique(markersize))==1)&(length(unique(marker))==1)&eqlen(size(unique(cols,'rows')),[1 3]),
		% we can plot it all in one shot
		plot(Xn,Yn,marker(1),'markersize',markersize(1),'color',cols(1,:));
	else,
		for i=1:length(Xn),
			plot(Xn(i),Yn(i),marker(i),'markersize',markersize(i),'color',cols(i,:));
			hold on;
		end;
	end;

	addtoold = 0;
	if ~isempty(oldud),
		if isfield(oldud,'clickfunction'),
	 		if strcmp(oldud.clickfunction,'tpscatterplot'),
				addtoold=1;
			end;
		end;
	end;
	if addtoold,
		ud = oldud;
		ud.cells = cat(1,ud.cells,cells); ud.cellnames = cat(1,ud.cellnames,cellnames);
		ud.Xn = cat(1,ud.Xn,Xn); ud.Yn = cat(1,ud.Yn,Yn); ud.varargin = cat(1,ud.varargin,varargin);
	else,
		ud = struct('cells',{cells},'cellnames',{cellnames},'Xn',Xn,'Yn',Yn,'clickfunction',clickfunction,'varargin',{varargin});
	end;
	set(gca,'userdata',ud);
	set(gca,'ButtonDownFcn','tpscatterplot');
end;
