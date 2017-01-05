function result = makemultipaneltpdisplay(filename, ids, insertedimage, gain)


G = load(filename,'-mat');
indimages = G.indimages; clear G;

i = 1; r = 1;
while i<=length(ids),
	imstart = i;
	im_ = zeros(3*size(indimages{1},1),3*size(indimages{1},2));
	%ctr = [ ];
	for j=1:3,
		for k=1:3,
			if i<=length(ids),
                if ids(i)~=-1,
    				im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))=indimages{ids(i)}*gain;
                else,
       				im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))=conv2(insertedimage,ones(5)/sum(sum(ones(5))),'same');
                end;
				%ctr(end+1,[1:2])=[median(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1)) median(1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))];
				i=i+1;
			end;
		end;
	end;
	imend = i-1;
	result{r} = im_;
	r = r + 1;
end;