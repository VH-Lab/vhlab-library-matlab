function [Lc, Sc, Rc] = RGB2TreeshrewConeContrasts(RGB_plus, RGB_minus, monitor);
% RGB2TreeshrewConeContrasts - Convert RGB values to tree shrew cone contrasts for a given monitor
%
%   [Lc, Sc, Rc] = RGB2TreeshrewConeContrasts(RGB_plus, RGB_minus, Monitor)
%
%   Given pairs of RGB_plus and RGB_minus values, calculate the contrast to the
%   tree shrew long-wavelength cones (L), short-wavelength cones (S), and rods (R),
%   for the monitor with properties Monitor (first column: wavelengths,
%   second column: red gun values, third column: green gun values; fourth column:
%   blue gun values).
%
%   See also:  TREESHREWCONECONTRASTSCOLOREXCHANGE, TREESHREWCONES

[CONEMON, CONES, MONITOR, CONETRANS, TRANS, WAVES] = treeshrewcones;

 % Step 1 ; interpolate the values of the monitor guns so they match
 %  the tree shrew cone wavelength values

monitor_ = [];
for i=2:size(monitor,2),
	monitor_(:,i-1) = interp1(monitor(:,1), monitor(:,i),  WAVES, 'linear', 0);
end;

 % Step 2: calculate how much, at 100%, each gun activates each cone
CONE_MON2 = CONES * monitor_;
  % first row of CONE_MON2 is the activation of S-cones by each gun
  % second row of CONE_MON2 is the activation of L-cones by each gun
  % third row of CONE_MON2 is the activation of Rods by each gun
  
 % Step 3 ; calculate the cone responses of each stimulus

Lc = []; 
Sc = [];
Rc = [];

for i=1:size(RGB_plus,2),
	CONE_ACT_PLUS = sum(repmat(RGB_plus(:,i)',3,1).*CONE_MON2,2);
	CONE_ACT_MINUS = sum(repmat(RGB_minus(:,i)',3,1).*CONE_MON2,2);
	CONE_CONTRAST =  (CONE_ACT_PLUS-CONE_ACT_MINUS)./(CONE_ACT_PLUS+CONE_ACT_MINUS);
	Sc(i) = CONE_CONTRAST(1);
	Lc(i) = CONE_CONTRAST(2);
	Rc(i) = CONE_CONTRAST(3);
end;

