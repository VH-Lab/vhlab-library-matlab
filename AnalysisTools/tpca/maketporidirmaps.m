function [or,di] = maketporidirmaps(dirname, singleconditionfname, varargin)
% MAKETPORIDIRMAPS - Make orientation and direction maps from single condition images
% 
%  [OR,DI] = MAKETPORIDIRMAPS(DIRNAME, SINGLECONDITIONFNAME, ...)
% 
%  Creates several files and images that reflect the orientation and direction map responses.
%  
% This function also accepts name/value pairs that modify the default behavior:
% Parameter (default)              |   
% --------------------------------------------------------------------------
% channel (2)                      | The 2-photon channel that contains the responses
% savefile (1)                     | 0/1 Should we save the image and vectors to a file?
% filename ('sc_oridirmap.mat')    | Filename to be saved with complex vector ori and dir map. 
% savetifffiles (1)                | Should we save the files to TIFF format?
% dir_tifffilename_angle           | Filename to be saved for TIFF format for dirmap angles.
%       ('sc_dirmap_angle.tif')    | 
% dir_tifffilename_mag             | Filename to be saved for TIFF format for dirmap magnitudes.
%       ('sc_dirmap_map.tif')      | 
% ori_tifffilename_angle           | Filename to be saved for TIFF format for orimap angles.
%       ('sc_orimap_angle.tif')    | 
% ori_tifffilename_mag             | Filename to be saved for TIFF format for orimap magnitudes.
%       ('sc_orimap_map.tif')      | 
% angle_shift (0)                  | Angle shift (to correct animal head rotation, for example)
% dorectify (1)                    | 0/1 Rectify dF/F responses below 0
% cmap (fitzlabclut(256))          | The color table for the TIFF files for angles; the magnitude
%                                  |   TIFF files will range from 0..255 (scaled from 0..max)
%   
% See also: MAKEMULTIPANELNMTPDISPLAY, MAKEMULTIPANELTPSTIMRESPONSES, INTERVAL_NOTATION, NAMEVALUEPAIR

channel = 2;
savefile = 1;
savetifffiles = 1;
filename = 'sc_oridirmap.mat';
dir_tifffilename_angle = 'sc_dirmap_angle.tif';
dir_tifffilename_mag = 'sc_dirmap_mag.tif';
ori_tifffilename_angle = 'sc_orimap_angle.tif';
ori_tifffilename_mag = 'sc_orimap_mag.tif';
angle_shift = 0;
dorectify = 1;
cmap = fitzlabclut(256);

assign(varargin{:});

 % step 1, decode the directions used

s = getstimscript(dirname);

N = numStims(s);

dirstimlist = [];

for n=1:N,
	stim = get(s,n);
	p = getparameters(stim);
	if isfield(p,'isblank'),
		isblank = p.isblank;
	else,
		isblank = 0;
	end;
	if isfield(p,'angle') & ~isblank,
		dirstimlist(n) = getfield(p,'angle');
	else,
		dirstimlist(n) = NaN;
	end;
end;

 % read images

load([dirname filesep singleconditionfname],'indimages','-mat');

images = [];

for n=1:length(dirstimlist),
	if ~isnan(dirstimlist(n)),
		images = cat(3,images,-indimages{n});  % negative sign b/c will call intrinsic imaging map routine
	end;
end;

if dorectify,
	images = -rectify(-images); % we are keeping it negative here
end;

angles = dirstimlist(find(~isnan(dirstimlist)));

[or,di] = intrinorivectorsum(images, angles, 0, 0); % the intrinsic function works fine, but need to flip sign b/c signal is positive


  % save files

if savefile,
	save([dirname filesep filename],'or','di','-mat');
end;

if savetifffiles,

	or_a = mod(angle(or)+angle_shift,2*pi);
	ori_angles = rescale(or_a,[0 2*pi],[1 256]);
	or_m = abs(or);

	di_a = mod(angle(di),2*pi);
	di_angles = rescale(di_a,[0 2*pi],[1 256]);
	di_m = abs(di);

	or_m_image = rescale(double(or_m), [0 max(or_m(:))], [0 255]);
	di_m_image = rescale(double(di_m), [0 max(di_m(:))], [0 255]);

	imwrite(uint8(di_angles),  cmap, [dirname filesep dir_tifffilename_angle]);
	imwrite(uint8(ori_angles), cmap, [dirname filesep ori_tifffilename_angle]);
	imwrite(uint8(di_m), [dirname filesep dir_tifffilename_mag]);
	imwrite(uint8(or_m), [dirname filesep ori_tifffilename_mag]);
end;


