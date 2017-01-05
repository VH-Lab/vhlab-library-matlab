function result = intrinsicplotsingleconditions(dirname,labelprefix,paramname)

result = {};

sv = load([fixpath(dirname) 'stimvalues.mat']);
sv = sv.stimvalues;

indimages = {};

for i=1:length(sv),
        im = load([fixpath(dirname) 'singlecondition' sprintf('%0.4d',i) '.mat']);
        im = im.imgsc;
        indimages{i} = im;
end;

i = 1; r = 1;

while i<length(indimages)
	label = [];
	imstart = i;
	im_ = zeros(3*size(indimages{1},1),3*size(indimages{1},2));
	ctr = [ ];
	for j=1:3,
		for k=1:3,
			if i<=length(indimages)
				im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))=indimages{i};
				ctr(end+1,[1:2])=[median(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1)) median(1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))];
				label=[label num2str(sv(i)) ','];
				i=i+1;
			end;
		end;
	end;
	imend = i-1;
	str = [labelprefix ' ' paramname '=' label];
	fig = findobj(0,'tag',str);
	if isempty(fig), fig = figure('tag',str,'name',str,'NumberTitle','off'); else, figure(fig); end;
	imagedisplay(im_,'fig',fig);
	result{r} = im_;
	r = r + 1;
end;

