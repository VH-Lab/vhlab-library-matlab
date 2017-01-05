function [M,C,D1,D2,D12] = coordframe_conversion_matrix(coordframe1,coordframe2,alignpoints);

D1 = [];
D2 = [];
D12 = [];
M = [];
C = [];

for i=1:length(alignpoints),
	g11=strcmp(alignpoints(i).data.coordframe1name,coordframe1);
	g21=strcmp(alignpoints(i).data.coordframe2name,coordframe1);
	g12=strcmp(alignpoints(i).data.coordframe1name,coordframe2);
	g22=strcmp(alignpoints(i).data.coordframe2name,coordframe2);
	if double(g11)+double(g21)+double(g12)+double(g22)==2, % we can use this one
		if g11&g22,
			D1 = [D1 ; alignpoints(i).data.point1];
			D2 = [D2 ; alignpoints(i).data.point2];
		else,
			D2 = [D2 ; alignpoints(i).data.point1];
			D1 = [D1 ; alignpoints(i).data.point2];
		end;
	end;
end;

if size(D2,1)<3, return; end;

D11 = D1; D22 = D2; D1 = D22; D2 = D11;

 % compute all distances, differences

dists1 = []; dists2 = []; diffs1 = []; diffs2 = [];

for i=1:size(D2,1),
	for j=1:size(D2,1),
		if i~=j,
			dists1(end+1) = sqrt(sum((D1(i,:) - D1(j,:)).^2));
			dists2(end+1) = sqrt(sum((D2(i,:) - D2(j,:)).^2));
			diffs1(end+1,:) = D1(i,:) - D1(j,:);
			diffs2(end+1,:) = D2(i,:) - D2(j,:);
		end;
	end;
end;

 % now find scaling and rotations/reflections

scales = dists1./dists2;
x0 = mean(scales); % estimate scaling, should be very accurate

val_rot = Inf; val_ref = Inf; x0_rot = []; x0_ref = [];

for i=0:pi/8:2*pi-pi/8, % try different rotations or reflections
	x0(2) = i;
	% rotation
	[x1,val1] = fminsearch(@(X)  1000*sum(sqrt(sum(  ((scale2d(X(1))*rot2d(X(2))*diffs2')'  -diffs1).^2,2))), x0);
	[x2,val2] = fminsearch(@(X)  1000*sum(sqrt(sum(  ((scale2d(X(1))*refl2d(X(2))*diffs2')' -diffs1).^2,2))), x0);
	if val1<val_rot, x0_rot = x1; val_rot = val1; end;
	if val2<val_ref, x0_ref = x2; val_ref = val2; end;
end;

if val_rot<val_ref, % use rotation
	M = scale2d(x0_rot(1))*rot2d(x0_rot(2));
else,  % use reflection
	M = scale2d(x0_ref(1))*refl2d(x0_ref(2));
end;

 % now find shift

[C,val] = fminsearch(@(c) 1000*sum(sqrt(sum(   (repmat([c(1) c(2)],size(D2,1),1) + (M*D2')' - D1).^2,2))), [0 0]);

D12 = repmat(C,size(D2,1),1) + (M*D2')';
