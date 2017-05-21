function [or,di] = intrinorivectorsum(images, angles, plotit, difference)

% INTRINIROVECTORSUM - Vector sum orientation and direction maps for intrinsic
%
%  [OR,DI] = INTRINORIVECTORSUM(IMAGES, ANGLES, PLOTIT, DIFFERENCE)
%
%  Computes vector sum for orientation and direction data.
%
%  Complex values are returned in OR and DI.
%
%  IMAGES should be a three dimensional matrix of single condition images,
%     with IMAGES(:,:,i) corresponding to ANGLES(i). These images should be
%     POSITIVE to indicate a response (typically, this means that intrinsic signal
%     image single condition images should be scaled by -1, because in most intrinsic signal
%     imaging experiments, negative signal indicates positive response).
%
%  ANGLES is a vector list of single condition angles (e.g., 0:45:360-45).
%    ANGLES should be in compass units.
%
%  PLOTIT is 0/1, if it is 1 then data will be plotted in a new figure.
%
%  DIFFERENCE is 0/1 and determines if single conditions or orthogonal
%  difference maps are used.
%
%  OR is the vector sum for orientation data (angles modulo 180).
%    The matrix is complex, with absolute value indicating the vector magnitude
%    of the signal at each position, and with phase (angle) representing orientation.
%    Horizontal orientations are represented by 0 and 2*pi, and vertical orientations are
%    represented by pi. Orientation increases anti-clockwise. Note that orientation angle
%    increases at twice the rate of direction angle because orientation is also represented
%    in 0 .. 2*pi.
%
%  DI is the vector sum including direction data (angles modulo 360).
%


% input parameters

angles = compass2cartesian(angles,0) * pi/180;

angles_ot = 2*mod(angles,pi);
angles_di = mod(angles,2*pi);

or = zeros(size(images(:,:,1)));
di = zeros(size(images(:,:,1)));

if difference,
	newimgsori = images;
	for i=1:length(angles),
		loc = findclosest(angles,mod(angles(i)+pi/2,pi));
		newimgsori(:,:,i) = images(:,:,i) - images(:,:,loc(1));
		loc2 = findclosest(angles,mod(angles(i)+pi,2*pi));
		newimgsdir(:,:,i) = images(:,:,i) - images(:,:,loc2(1));
	end;
else,
	newimgsori = images;
	newimgsdir = images;
end;
clear images;

for i=1:length(angles),
	or = or+exp(sqrt(-1)*angles_ot(i)) * -newimgsori(:,:,i);
	di = di+exp(sqrt(-1)*angles_di(i)) * -newimgsdir(:,:,i);
end;

or = or / length(angles); di = di / length(angles);  % normalize by number of directions

if plotit,
	ctab = [fitzlabclut(128) ;gray(128)];
	or_angs = rescale(mod(angle(or),2*pi),[0 2*pi],[1 128]); 
	di_angs = rescale(mod(angle(di),2*pi),[0 2*pi],[1 128]);
	di_mag = abs(di);or_mag = abs(or);
	MN = min([min(min(di_mag)) min(min(or_mag))]); MX = max([max(max(di_mag)) max(max(or_mag))]);
	di_mag = rescale(di_mag,[MN MX],[129 256]);
	or_mag = rescale(or_mag,[MN MX],[129 256]);
	figure;
	colormap(ctab);

	subplot(2,2,1);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(or_angs);
	title('Orientation angles');axis equal;

	subplot(2,2,2);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(or_mag);
	title('Orientation magnitude');axis equal;

	subplot(2,2,3);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_angs);
	title('Direction angles');axis equal;

	subplot(2,2,4);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_mag);
	title('Direction magnitude');axis equal;
end;
