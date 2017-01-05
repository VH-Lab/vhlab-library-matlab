function ax = plotorientationcolors2(angles)

ax = axes;

ot_xy = [ 0.1 0];
angles = -(angles)*pi/180;
%offsets_y = [1.6:-0.2:0.2 ];
%offsets_x = [ 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2];
offsets_x= [0.2:0.2:(length(angles)*0.2) ];
offsets_y = repmat(0.2,1,length(angles));
cols = jet(length(angles));
for i=1:length(angles),
	if i==1, hold off; else, hold on; end;
	trans = [cos(angles(i)) sin(angles(i)) ; -sin(angles(i)) cos(angles(i))];
	pt1 = ot_xy*trans; pt2 = -ot_xy*trans;
	plot(offsets_x(i)+[pt1(1) pt2(1)],offsets_y(i)+[pt1(2) pt2(2)],...
		'linewidth',4, 'color',cols(i,:));
end;

axis off;
axis equal;
axis([0.1 0.1+length(angles)*0.2 0 0.3]);
