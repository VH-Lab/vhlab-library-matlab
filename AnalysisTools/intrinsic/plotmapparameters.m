function [imhandle,ctab,angs]=plotmapparameters(map,numColors,setctab,mask)

% example:
% plotmapparameters(pi+pi*2*compass2cartesian(P(:,:,3),0)/180,128,0,[])
 
angs = rescale(mod(map,2*pi),[0 2*pi],[2 numColors+1]);
if ~isempty(mask), or_angs(find(mask)) = 0; end;
imhandle=image(angs);

ctab = [];
if setctab,
	ctab = fitzlabclut(numColors);
	ctab = [0 0 0; ctab];
	colormap(ctab);
end;
