function [ori_compass] = intrinsic_ori2dir(dirname, varargin)
% INTRINSIC_ORI2DIR - Convert cartesian orientation map from intrinsic imaging to direction 0..pi
%
%  [ORI_COMPASS] = INTRINSIC_ORI2DIR(DIRNAME, ...)
%
%  Reads in the intrinsic signal imaging orientation map information
%  (which is normally stored in cartesian radian coordinates), and converts to
%  compass coordinates in degrees and is returned in ORI_COMPASS.
%
%  This function takes several name/value pairs that modify its behavior:
%  Parameter (default value)      | Description
%  -------------------------------------------------------------------------
%  filename                       | The filename where the orientation map data is stored.
%    ('orientation_map_data.mat') | 
%  meanfilter (5)                 | Mean filter size (leave empty or 0 for none) 
%  

filename = 'orientation_map_data.mat';
meansmooth = 5;

assign(varargin{:});

fullfilename = [dirname filesep filename];

load(fullfilename,'or','-mat');

if ~isempty(meansmooth),
	if meansmooth,
		or = conv2(or, ones(meansmooth,meansmooth),'same');
	end;
end;

angles_cart = angle(or);

angles_cart = mod(angles_cart, 2*pi); % make sure we're still on the circle 
angles_scaled = angles_cart/2;  % scale down to 0..pi since orientation is really mapped 0 .. 180
ori_compass = cartesian2compass(angles_scaled,1); % convert to compass, stay in radians
ori_compass = ori_compass + pi/2; % shift from orientation to direction space
ori_compass = ori_compass*180/pi; % convert to degrees
ori_compass = mod(ori_compass, 180); % convert to 0..180

  % now, 0 degrees is horizontal bar moving up, 90 degrees is bar moving right


