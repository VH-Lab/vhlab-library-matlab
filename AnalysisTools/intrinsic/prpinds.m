function [prpI,indeximage] = prpinds(IMs,usemax,roipts)

if nargin<3,
	roi = [];
else, roi = find(roipts);
end;

for i=1:size(IMs,3),
	im = IMs(:,:,i);
        if i==1, magimage = im; indeximage = ones(size(im));
        else,
                if usemax, inds = find(im>magimage); else, inds = find(im<magimage); end;
                magimage(inds) = im(inds);
                indeximage(inds) = i;
        end;
end;

for i=1:size(IMs,3),
	prpI{i} = find(indeximage==i);
	if ~isempty(roi), prpI{i} = intersect(prpI{i},roi); end;
end;
