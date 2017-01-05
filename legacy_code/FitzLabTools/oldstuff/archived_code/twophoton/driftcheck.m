function dr = driftcheck(im1,im2,searchX, searchY,brightnesscorrect)

% DRIFTCHECK - Checks for drift in image pair by correlation
%
%   DR = DRIFTCHECK(IM1,IM2,SEARCHX,SEARCHY,BRIGHTNESSCORRECT)
%
%  Checks for drift over the specific offset ranges
%  SEARCHX = [x1 x2 x3] and SEARCHY = [y1 y2 y3].
%  Positive shifts are rightward and upward with respect to
%  the original.
%
%  If BRIGHTNESSCORRECT is 1, then the images are normalized
%  by their standard deviation before correlating.  This
%  allows accurate correlation where total image brightness
%  has changed.
%
%  The best offset, as determined by correlation, is returned
%  in DR = [OFFSET_X OFFSET_Y].
%
%

bestavgcorr = [-Inf];
dr = [NaN NaN];

if brightnesscorrect,
	im1v = reshape(im1,prod(size(im1)),1); im2v = reshape(im2,prod(size(im2)),1);
	mn1 = nanmean(im1v); mn2 = nanmean(im2v);
	im1 = rescale(im1,mn1+2*nanstd(im1v)*[-1 1],[-1 1]);
	im2 = rescale(im2,mn2+2*nanstd(im2v)*[-1 1],[-1 1]);
end;

sz = size(im1);

if 1, % new method with mex file
norm = repmat(sz(1)-abs(searchY)',1,length(searchX)).* ...
		repmat(sz(2)-abs(searchX),length(searchY),1);

avgcorr = xcorr2dlag(im1,im2,searchX,searchY)./norm;
[y]=max(max(avgcorr));
[i,j] = ind2sub(size(avgcorr),find(avgcorr==y));
dr = [searchX(j(1)) searchY(i(1))];
end;

return;
if 0,  % old method

for x=searchX,
	for y=searchY,
		if x>=0, start1x = 1+x; end1x = sz(2); start2x = 1; end2x = sz(2)-x;
		else, start1x = 1; end1x = sz(2)+x; start2x = 1-x; end2x = sz(2);
		end;
		if y>=0, start1y = 1+y; end1y = sz(1); start2y = 1; end2y = sz(1)-y;
		else, start1y = 1; end1y = sz(2)+y; start2y = 1-y; end2y = sz(1);
		end;
		avgcorr=nansum(nansum(im1(start1y:end1y,start1x:end1x).*(im2(start2y:end2y,start2x:end2x))))./((sz(1)-abs(x))*(sz(2)-abs(y)));
		if avgcorr>bestavgcorr,
			bestavgcorr = avgcorr;
			dr = [x y];
		end;
	end;
end;

end;
