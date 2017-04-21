function result = makemultipanelNMtpdisplay(filename, N, M, ids, insertedimage, gain)
% MAKEMULTIPANELNMTPDISPLAY - Make a multipanel NxM display of 2-photon single condition images
%
%  RESULT = MAKEMULTIPANELNMTPDISPLAY(FILENAME, N, M, IDS, INSERTEDIMAGE, GAIN)
%
%  Makes a giant panel of two-photon single condition images,
%  given the following inputs:
%      FILENAME (full path) that has the single condition images generated from TPSINGLECONDITION
%                (should have a variable 'indimages' stored)
%      N - number of 'rows' in multipanel view
%      M - number of 'columns' in multipanel view
%      IDS - the stimulus numbers of the single conditions to include the image, going from left to right, top to bottom
%      INSERTEDIMAGE - An image to be inserted when -1 is given as an IDS value (or 0 to leave blank)
%      GAIN - a multiplicative factor on the image
%
%  Returns:
%      RESULT - A single cell containing an image that is 3x the width and 3x the height of the original image, 
%        with the panels distributed according to IDS.
%
%
%  See also: MAKEMULTIPANELTPDISPLAY


load(filename,'indimages','-mat');

i = 1; r = 1;
while i<=length(ids),
	imstart = i;
	im_ = zeros(N*size(indimages{1},1),M*size(indimages{1},2));
	%ctr = [ ];
	for j=1:N,
		for k=1:M,
			if i<=length(ids),
				if ids(i)~=-1,
					im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),...
						1+(k-1)*size(indimages{i},2):k*size(indimages{i},2)) ...
							=indimages{ids(i)}*gain;
				elseif ~eqlen(insertedimage,0),
					im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),...
						1+(k-1)*size(indimages{i},2):k*size(indimages{i},2)) ...
							=conv2(insertedimage,ones(5)/sum(sum(ones(5))),'same');
				end;
				i=i+1;
			end;
		end;
	end;
	imend = i-1;
	result{r} = im_;
	r = r + 1;
end;
