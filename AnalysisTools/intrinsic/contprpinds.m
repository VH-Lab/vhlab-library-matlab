function inds = contprpinds(image,binctr,binwidth,mask,wrap)

 % bins should be [ low high; low high; low high]

goodpixels = find(mask==0);

taken = zeros(size(image));

for i=1:length(binctr),
	if ~isempty(wrap),
		mydiff = angdiffwrap(image-binctr(i),wrap);
	else, mydiff = abs(image-binctr(i));
	end;
	inds{i} = setdiff(intersect(goodpixels,find(mydiff<=binwidth)),find(taken));
	taken(inds{i}) = 1;
end;


