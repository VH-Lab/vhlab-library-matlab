function [or,di] = tporidirvectorsum(images, angles, smoothing, rotate, plotit)

% TPORIDIRVECTORSUM - Vector sum orientation and direction maps for 2-photon
%
%  [OR,DI] = TPORIDIRVECTORSUM(IMAGES, ANGLES, SMOOTHING, ROTATE, PLOTIT)
%
%  Computes vector sum for orientation and direction data.
%
%  Complex values are returned in OR and DI.
%
%  IMAGES should be a cell list of two-photon single condition maps, with each
%     IMAGE{i} corresponding to ANGLES(i).
%
%  ANGLES is a vector list of single condition angles (e.g., 0:45:360-45).
%
%  SMOOTHING is a smoothing kernal that is convolved with the data
%     (e.g., ones(11) sums over 11x11 pixel areas.).
%
%  ROTATE can be 0 or 90.  (We generally rotate the image so intrinsic and
%     two-photon will be aligned similarly.)
% 
%  PLOTIT is 0/1, if it is 1 then data will be plotted in a new figure.
%
%  OR is the vector sum for orientation data (angles modulo 180), and
%  DI is the vector sum including direction data (angles modulo 360).

angles = angles * pi/180;

angles_ot = 2*mod(angles,pi);
angles_di = mod(angles,2*pi);

or = zeros(size(images{1}));
di = zeros(size(images{1}));

for i=1:length(angles),
	dat = conv2(images{i},smoothing,'same');
	or = or+exp(sqrt(-1)*angles_ot(i)) * dat;
	di = di+exp(sqrt(-1)*angles_di(i)) * dat;
end;

or = or / length(angles); di = di / length(angles);  % normalize by number of directions

if rotate==90, or=transpose(or(:,end:-1:1)); di=transpose(di(:,end:-1:1)); end;

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
	title('Orientation angles');

	subplot(2,2,2);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(or_mag);
	title('Orientation magnitude');

	subplot(2,2,3);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_angs);
	title('Direction angles');

	subplot(2,2,4);p=get(gca,'position'); set(gca,'position',[p(1) p(2) 0.335 0.335]);
	image(di_mag);
	title('Direction magnitude');
end;
