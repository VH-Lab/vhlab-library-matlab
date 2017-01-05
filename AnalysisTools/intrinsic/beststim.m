function [grayimage, magimage, indeximage] = beststim(stackfilename, usemax, stimparameters)

% BESTSTIM - Make a best stim projection of intrinsic data
%
%   [GRAYIMAGE,MAGIMAGE,INDEXIMAGE]=BESTSTIM(STACKFILENAME,USEMAX,STIMPARAMETERS)
%
%  Given a stack of TIFF images, BESTSTIM computes the stack entry number
%  that has the maximum or minimum value.  If USEMAX is 1, the maximum value
%  is used.  If USEMAX is 0, the minimum value is used.
%
%  Optionally, the stimulus parameters can be specified in STIMPARAMETERS.
%  For example, if entries in the stack correspond to orientations of 
%  0, 45, 90, and 135 degrees, then STIMPARAMETERS = [0 45 90 135].
%  Note that the number of STIMPARAMETERS must equal the number of stacks.
%  If you don't want to specify the parameters directly, use 1:NUMSTACKS.
%
%  INDEXIMAGE is an image with each pixel equal to the STIMPARAMETER index
%  that gave the maximum response.
%  MAGIMAGE is the image of maximum or minimum magnitudes for each pixel.
%  GRAYIMAGE is a grayscale image of INDEXIMAGE from 0..255.


stiminds = unique(stimparameters);

for i=1:length(stimparameters),
	im = imread(stackfilename,'tiff',i);
	stimindnum = find(stiminds==stimparameters(i));
	if i==1, magimage = im; indeximage = stimindnum*ones(size(im));
	else,
		if usemax, [mags,inds] = find(im>magimage); else, [mags,inds] = find(im<magimage); end;
		magimage(inds) = im(inds);
		indeximage(inds) = stimindnum;
	end;
end;

inc = 255/length(stiminds);
grayimage = 1+indeximage*inc;
