function dr = driftcheck(im1,im2,searchxy)

% DRIFTCHECK - Checks for drift in image pair by correlation
%
%   DR = DRIFTCHECK(IM1,IM2,SEARCHXY)
%
%  Checks for drift over the range SEARCHXY = [PIXELS_X PIXELS_Y]
%  and returns the best offset, as determined by correlation,
%  in DR = [OFFSET_X OFFSET_Y].
%

bestavgcorr = [-Inf];
dr = [NaN NaN];

sz = size(im1);
for x=-searchxy(1):searchxy(1),
	for y=-searchxy(2):searchxy(2),
		if x>=0, start1x = 1+x; end1x = sz(2); start2x = 1; end2x = sz(2)-x;
		else, start1x = 1; end1x = sz(2)+x; start2x = 1-x; end2x = sz(2);
		end;
		if y>=0, start1y = 1+y; end1y = sz(1); start2y = 1; end2y = sz(1)-y;
		else, start1y = 1; end1y = sz(2)+y; start2y = 1-y; end2y = sz(1);
		end;
		avgcorr=sum(sum(im1(start1x:end1x,start1y:end1y).*(im2(start2x:end2x,start2y:end2y))))./((sz(1)-abs(x))*(sz(2)-abs(y)));
		if avgcorr>bestavgcorr,
			bestavgcorr = avgcorr;
			dr = [x y];
		end;
	end;
end;

