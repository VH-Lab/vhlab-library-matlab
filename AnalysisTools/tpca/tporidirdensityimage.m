function [img_ot,img_di,img_mask] = tporidirdensityimage(cells, varargin)

% TPORIDIRDENSITYIMAGE - Create a smooth map from two-photon data
%
% [ORI_IM,DIR_IM] = TPORIDIRDENSITYIMAGE(CELLS,...)
%
% Creates an orientation density image from single cell two-photon data.
%
% Each cell's orientation or direction preference is represented by a
%  gaussian in a small stencil that is added to the image.
% 
% Extra arguments can be given as name/value pairs that replace the
%  default values below:
%
% Name [default]:                 Behavior:
% PLOTIT [1]                      0/1 should we plot the results
% SIGMA [15]                      Fall-off of gaussian.
% IMSIZE [512 512]                Size of the image field
% OTINDFUNC [see below]           Code to calculate orientation index, oi
% OTPREFFUNC [see below]          Code to calculate ori. preference, op
% DIRINDFUNC [see below]          Code to calculate direction index, di
% DIRPREFFUNC [see below]         Code to calculate dir. preference, dp
% INCLFUNC [see below]            Sets variable 'b' to be 0/1 depending
%                                       on whether cell should be included
%
%  The last five items are code fragments that can either be a long string
%  or a cell list of strings.  The variable j is used to loop over cells,
%  so these code snippets can access cells{j} to read fields from the
%  cells.
%
% otpreffunc = ['p=findassociate(cells{j},''OT Fit Pref'','''','''');
%    op=mod(p.data,180);'];
% dirpreffunc = ['p=findassociate(cells{j},''OT Fit Pref'','''','''');
%    op=mod(p.data,360);'];
%
% inclfunc = ['b=0;
% p=findassociate(cells{j},''OT visual response p'','''','''');
% if ~isempty(p),b=p.data<0.05;end;'];
%  


sigma = 150;
imsize = [512 512];

otindfunc = ['f=findassociate(cells{j},''OT Carandini Fit Params'','''','''');' ...
	'bl=findassociate(cells{j},''Best orientation resp'','''','''');'...
	'fi=findassociate(cells{j},''OT Carandini Fit'','''','''');'...
	'OtPi=findclosest(0:359,f.data(3)); OtNi=findclosest(0:359,mod(f.data(3)+180,360));'...
	'OtO1i=findclosest(0:359,mod(f.data(3)+90,360));OtO2i=findclosest(0:359,mod(f.data(3)-90,360));'...
	'oi=sum([1 1 -1 -1].*fi.data([OtPi OtNi OtO1i OtO2i]))/(sum(fi.data([OtPi OtNi]))-2*bl.data.blankresp(1));'];

dirindfunc = ['f=findassociate(cells{j},''OT Carandini Fit Params'','''','''');' ...
	'bl=findassociate(cells{j},''Best orientation resp'','''','''');'...
	'fi=findassociate(cells{j},''OT Carandini Fit'','''','''');'...
	'OtPi=findclosest(0:359,f.data(3)); OtNi=findclosest(0:359,mod(f.data(3)+180,360));'...
	'di=sum([1 -1].*fi.data([OtPi OtNi]))./(fi.data(OtPi)-bl.data.blankresp(1));'];


inclfunc = ['b=0;p=findassociate(cells{j},''OT vec varies p'','''','''');if ~isempty(p),b=p.data<0.05;end;'];

otpreffunc = ['p=findassociate(cells{j},''OT Fit Pref'','''','''');op=mod(p.data,180);'];
dirpreffunc = ['p=findassociate(cells{j},''OT Fit Pref'','''','''');dp=mod(p.data,360);'];

plotit = 0;
scale_mn = []; scale_mx = []; thresh = 1e-5;

if nargin>1, assign(varargin{:}); end;

img_ot = zeros(imsize);
img_di = zeros(imsize);
img_mask = zeros(imsize);

[grid_x,grid_y] = meshgrid(1:imsize(1),1:imsize(2));
stencil = exp(-((grid_x-imsize(1)/2).*(grid_x-imsize(1)/2)+(grid_y-imsize(2)/2).*(grid_y-imsize(2)/2))/(2*sigma));
stencil_mult = 1/sum(sum(stencil)); % make area 1

for j=1:length(cells),
	j,
	b =0;
	eval(inclfunc);
	if b==1,
		eval(otindfunc);
		eval(dirindfunc);
		eval(otpreffunc);
		eval(dirpreffunc);
		pixellocs = findassociate(cells{j},'pixellocs','','');
		x = mean(pixellocs.data.x); y = mean(pixellocs.data.y);
		img_0 = stencil_mult * exp(-(((grid_x-x).*(grid_x-x))+(grid_y-y).*(grid_y-y))/(2*sigma));
		img_ot = img_ot + max(min(oi,1),0) * exp(sqrt(-1)*(2*op*pi/180)) * img_0;
		img_di = img_di + max(min(di,1),0) * exp(sqrt(-1)*(dp*pi/180)) * img_0;
		img_mask = img_mask + img_0;
	end;
end;

if plotit, plottporidirdensityimage(img_ot,img_di,img_mask,'scale_mn',scale_mn,'scale_mx',scale_mx,'thresh',thresh); end;