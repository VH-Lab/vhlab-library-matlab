function [wta] = intrinsicwinnertakeall(images, plotit)

% INTRINSICWINNERTAKEALL - Winner take all maps for intrinsic
%
%  [WTA] = INTRINSICWINNERTAKEALL(IMAGES, PLOTIT)
%
%  For each pixel, computes the image slice with the largest response
%  and returns the answer in WTA.
%
%  If PLOTIT is 1, then it plots it to a new figure.

[values,wta] = max(images,[],3);

if plotit,
	ctab = [jet(size(images,3))];
	figure;
	colormap(ctab);
    image(wta);
end;
