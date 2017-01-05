function [im,scalebaraxes,scalebarimage]=pvcontinuousmap(dirname,channel,cells,cellnames,indexassoc,funcstring,steps,plotit,pvalueassoc,pvalue,symbol,symbolsize,colors,rotating)

%  PVCONTINUOUSMAP - Produces a colored map of responses
%  IM=PVCONTINUOUSMAP(DIRNAME,CHANNEL,CELLS,CELLNAMES,INDEXASSOC,...
%                FUNCSTRING,STEPS,PLOTIT,PVALUEASSOC,PVALUE,...
%			[SYMBOL],[SYMBOLSIZE],[COLOR],[ROTATE])
%
%    Generates a color map of neural responses.
%
%  DIRNAME is the name of the directory.  A preview image, based on
%  the first 50 frames, is generated from this data.  If no preview
%  image is desired, pass [SIZE_Y SIZE_X].
%
%  CHANNEL is the channel to be read.
%
%  CELLS is a cell list of measureddata objects.  CELLNAMES is a cell
%  list of strings with the names of these objects.
%
%  INDEXASSOC is associate type to plot (e.g., 'OT Fit Pref').
%
%  FUNCSTRING can be a string describing a mathematical manipulation
%     of the index value.  In the string, 'x' is the value of the
%     index read from the cell.  For example, 'mod(x,180)' will
%     give the index value modulo 180.  FUNCSTRING can also be
%     [] if no manipulation is desired.
%
%  STEPS are the values to colorize (e.g., 1:1:180 for
%     1 to 180 in steps of 1)
%
%  If PLOTIT is 1 data are plotted in a new window.
%
%  PVALUEASSOC is an associate type that contains a P value
%     for deciding whether or not to include a given point.
%
%  PVALUE is the cut-off P value (e.g., 0.05).
%
%  The user has the option of describing the shape of each cell.
%  by passes the SYMBOL argument, which should be a
%  1xLENGTH(CELLS) vector. If SYMBOL(I) is 
%     0     then the cell's shape is filled in 
%     1     a circle of radius SYMBOLSIZE is drawn
%     2     a square with size 2*SYMBOLSIZE is drawn
%  If SYMBOL is not provided, then cell shapes are drawn.
%  SYMBOLSIZE must be given if any member of SYMBOL is not 0.
%
%  COLOR is an optional list of colors to use for the cells.  It is a 
%    LENGTH(CELLS)x3 matrix.  If [-1 -1 -1] is passed, then the cell
%    is colorized according to its index value.  If any other value
%    is passed, then that color is used for the cell.  Color values are
%    RGB with values ranging from 0 to 1.
%
% ROTATE is an optional argument for rotating the image either 0 or 90 degrees.


scalebaraxes = []; scalebarimage = [];

if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.pts,1),1)-ud.pts).^2')'),0);

	if v<50,
		disp(['Closest cell is ' ud.cellnames{i} ' w/ value ' num2str(ud.values(i)) '.']);
		%try,
			figure;
			plottpresponse(ud.cells{i},ud.cellnames{i},ud.indexassoc,1,1);
		%end;
	end;

	return;
end;

if nargin>9,
	symb = symbol;
	if length(symbolsize)==1,
		symbolsize = symbolsize * ones(1,length(symb));
	end;
else,
	symb = zeros(1,length(cells));
end;
if nargin<12,
	cols = -1 * ones(length(cells),3);
else,	cols = colors;
end;

la = {};
%if nargin<13,
	for i=1:length(cells), la{i} = ''; end; labelsz = 12;
%else,	la = labels; labelsz = labelsize;
%end;

if nargin<13,
	rotate = 0;
else, rotate = rotating;
end;

if ischar(dirname),
	im1 = previewprairieview(dirname,50,1,1);
	im1 = rescale(im1,[min(min(im1)) max(max(im1))],[0 1]);
else,   im1 = zeros(dirname(2),dirname(1));
end;

im2 = im1; im3 = im1;

sz = size(im1); im0 = zeros(size(im1));
[blank_x,blank_y] = meshgrid(1:sz(2),1:sz(1));

numcolors = length(steps);
%ctab = fitzlabclut(numcolors);
ctab = jet(numcolors); ctab = ctab(end:-1:1,:);

index = [];

pts = [];  inclpts = []; values = [];

for i=1:length(cells),
	pva = []; incl = 1;
	inda = findassociate(cells{i},indexassoc,'','');
	if ~isempty(pvalueassoc),
		pva = findassociate(cells{i},pvalueassoc,'','');
		incl = 0;
		if ~isempty(pva),
			incl = pva.data <= pvalue;
		end;
	end;
	pixelindsa = findassociate(cells{i},'pixelinds','','');
	pixellocs = findassociate(cells{i},'pixellocs','','');
	if isempty(pixelindsa),
		warning(['Cell ' int2str(i) ' does not have associate ''pixelinds''.']);
		incl = 0;
	end;
	if incl, 
		x = inda.data;
		if ~isempty(funcstring),
			x=eval(funcstring);
		end;
		values(end+1) = x;  % next line x has new meaning
		x = mean(pixellocs.data.x); y = mean(pixellocs.data.y);
		if rotate==0, pts = [pts ; x y];
		elseif rotate==90, pts = [pts; y 1+sz(1)-x];
		end;
		inclpts(end+1) = i;
		if symb(i)==0,
			inds = pixelindsa.data;
		elseif symb(i)==1,
			xi_ = -symbolsize(i):1:symbolsize(i);
			yi_p= sqrt(symbolsize(i)^2-xi_.^2);
			yi_m=-sqrt(symbolsize(i)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
		elseif symb(i)==2,
			im0_ = im0;
			im0_(round(y-symbolsize(i):y+symbolsize(i)),round(x-symbolsize(i):x+symbolsize(i)))=1;
			inds = find(im0_);
		elseif symb(i)==3|symb(i)==4,
			if symb(i)==3, ang = values(end); else, ang = inda.data; end;
			theta = (90+90-rotate-ang)*pi/180;  % convert to radians 
			th =  0.2;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first point is in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			theta_ = theta;       % next point is in positive direction
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta - pi/2; % one arrow branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi/2; % and now the other branch
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;	     % back to the negative
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;	     % and back to center to add nose
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
		elseif symb(i)==5|symb(i)==6,  % circles w/ arrows
                        th =  1.2;  % thickness
			xi_ = -th*symbolsize(i,1):1:th*symbolsize(i,1);
			yi_p= sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			yi_m=-sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			%if i==1, figure; plot(xi,yi); end;
			inds1_ = find(inpolygon(blank_x,blank_y,xi,yi));
                        th =  1.0;  % thickness
			xi_ = -th*symbolsize(i,1):1:th*symbolsize(i,1);
			yi_p= sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			yi_m=-sqrt((symbolsize(i,1)*th)^2-xi_.^2);
			xi = [xi_ xi_(end:-1:1)]+x; yi=[yi_p yi_m(end:-1:1)]+y;
			%if i==1, hold on; plot(xi,yi,'r'); end;
			inds1__ = find(inpolygon(blank_x,blank_y,xi,yi));
			inds1 = setdiff(inds1_,inds1__);
			% now add arrow
			th=0.2;
                        if symb(i)==5, ang = values(end); else, ang = inda.data; end;
                        theta = (90+90-rotate-ang)*pi/180;  % convert to radians
                        xi_ = []; yi_ = [];
                        theta_ = theta + pi;  % first point is in negative direction
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        theta_ = theta;       % next point is in positive direction
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta - pi/2; % one arrow branch
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta;      % and back to center
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta + pi/2; % and now the other branch
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta;      % and back to center
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta + pi;         % back to the negative
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        theta_ = theta;      % and back to center to add nose
                        xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
                        xi_(end+1)=(1+th)*sin(theta_);yi_(end+1)=(1+th)*cos(theta_);
                        xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
                        xi=xi_*symbolsize(i,2)+x; yi=yi_*symbolsize(i,2)+y;
                        inds2 = find(inpolygon(blank_x,blank_y,xi,yi));
			inds = union(inds1,inds2);
		elseif symb(i)==7|symb(i)==8,  % lines orthogonal to angle
			if symb(i)==7, ang = values(end); else, ang = inda.data; end;
			theta = (90+90+90-rotate-ang)*pi/180;  % convert to radians 
			th = 0.4;  % thickness
			xi_ = []; yi_ = [];
			theta_ = theta + pi;  % first points are in negative direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta;       % next points is in positive direction
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi_(end+1)=sin(theta_)-th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)-th*cos(theta_+pi/2);
			theta_ = theta + pi;  % back to original point to complete line
			xi_(end+1)=sin(theta_)+th*sin(theta_+pi/2);yi_(end+1)=cos(theta_)+th*cos(theta_+pi/2);
			xi=xi_*symbolsize(i)+x; yi=yi_*symbolsize(i)+y;
			inds = inpolygon(blank_x,blank_y,xi,yi);
		else, error(['Unknown symbol ' int2str(symb(i)) '.']);
		end;
		if any(cols(i,:)<0),
			mycol = ctab(findclosest(steps,values(end)),:);
		else,
			mycol = cols(i,:);
		end;
		im1(inds) = mycol(1);
		im2(inds) = mycol(2);
		im3(inds) = mycol(3);
	end;
end;

if rotate==0,
	im = cat(3,im1,im2,im3);
elseif rotate==90,
	im = cat(3,im1(:,end:-1:1)',im2(:,end:-1:1)',im3(:,end:-1:1)');
end;

if plotit,
	figure;
	ax = axes('position',[0.100    0.15    0.70    0.70]);
	imageh = image(im);

	% scale bar
	scalebaraxes = axes('position',[0.9 0.11 0.05 0.8150]);
	scaleim1 = zeros(10,numcolors);
	scaleim2 = scaleim1; scaleim3 = scaleim1;
	for i=1:numcolors,
		scaleim1(:,i) = ctab(i,1);
		scaleim2(:,i) = ctab(i,2);
		scaleim3(:,i) = ctab(i,3);
	end;
	scalebarimage=image(cat(3,scaleim1',scaleim2',scaleim3'));
	set(gca,'fontsize',14);
	set(gca,'xtick',[]);
	set(gca,'ytick',1:8:41);
	ytick = get(gca,'ytick');
	yticklabs = {};
	for i=1:length(ytick),
		myind = findclosest(1:length(steps),ytick(i));
		yticklabs{i} = num2str(steps(myind),3);
	end;
	set(gca,'yticklabel',yticklabs);

	axes(ax);

	set(gcf,'userdata',struct('pts',pts,'inclpts',inclpts,'cells',{cells(inclpts)},'cellnames',{cellnames(inclpts)},'indexassoc',indexassoc,'imagesize',[size(im,1) size(im,2)],'values',values));
	set(imageh,'ButtonDownFcn','pvcontinuousmap');
	
end;

global myimmap

myimmap = im;
