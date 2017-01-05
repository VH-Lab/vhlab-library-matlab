function grad = ot_map_gradient(map)

angs = rescale(mod(angle(map),2*pi),[0 2*pi],[0 pi])*180/pi;

Xdiff = [0  0 0 ;  0 -1 1;  0 0 0] * 1;
Ydiff = [0 -0 0 ;  0 -1 0;  0 1 0] * 1;

dx = conv2(angs,Xdiff,'same');
dy = conv2(angs,Ydiff,'same');

dx = angdiffwrap(dx,180);
dy = angdiffwrap(dy,180);

grad = sqrt(dx.*dx+dy.*dy);

