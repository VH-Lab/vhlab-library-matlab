function result = makemultipaneltpdisplay(filename, ids, insertedimage, gain)
% MAKEMULTIPANELTPDISPLAY - Make a multipanel 3x3 display of 2-photon single condition images
%
%  RESULT = MAKEMULTIPANELTPDISPLAY(FILENAME, IDS, INSERTEDIMAGE, GAIN)
%
%  Makes a giant panel of two-photon single condition images,
%  given the following inputs:
%      FILENAME (full path) that has the single condition images generated from TPSINGLECONDITION
%                (should have a variable 'indimages' stored)
%      IDS - the stimulus numbers of the single conditions to include the image, going from left to right, top to bottom
%      INSERTEDIMAGE - An image to be inserted when -1 is given as an IDS value (or 0 to leave blank)
%      GAIN - a multiplicative factor on the image
%
%  Returns:
%      RESULT - A single cell containing an image that is 3x the width and 3x the height of the original image, 
%        with the panels distributed according to IDS.
%
%  (DEPRICATED: This function exists for backward compatibility, but
%  MAKEMULTIPANELNMTPDISPLAY is more general and is recommended for future use.)
%
%  See also: MAKEMULTIPANELNMTPDISPLAY

load(filename,'indimages','-mat');

result = makemultipanelNMtpdisplay(filename, 3, 3, ids, insertedimage, gain);

return;

  % code from 2006-2008: 

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
				elseif ~eqlen(insertedimage,0),
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

