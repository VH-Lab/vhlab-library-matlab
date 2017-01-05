function [im,ctab]=compareprpinds(prpinds1,prpinds2,theimage,plotit)

im = ones(size(theimage));

ctab = [ 0 0 0 ; 1 0 0 ; 0 0 1 ; 1 0 1];

im(prpinds1)=2;
im(prpinds2)=3;
im(intersect(prpinds1,prpinds2))=4;

if plotit,
	figure;
	colormap(ctab);
	image(im);
end;
