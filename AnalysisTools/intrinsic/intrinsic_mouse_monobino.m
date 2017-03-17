function [success] = intrinsic_mouse_monobino(base_directory, ipsi_response_dir, contra_response_dir, varargin)
% INTRINSIC_MOUSE_MONOBINO - Define regions of interest for monocular / binocular cortex
%
%   SUCCESS = INTRINSIC_MOUSE_MONOBINO(BASE_DIRECTORY, IPSI_DIRECTORY, CONTRA_DIRECTORY, ...)
%
%   BASE_DIRECTORY is the experiment directory (e.g., 'C:\Users\me\Documents\2015-05-25')
%   IPSI_DIRECTORY is a directory with responses generated through the ipsilateral eye (ipsilateral to the imaging hemisphere)
%   CONTRA_DIRECTORY is a directory that contains responses generated through the contralateral eye (contralateral to the imaging hemisphere)
%
%   The user is prompted to draw a REGION OF INTEREST that indicates the ipsilateral responsive zone, the
%   contralateral responsize zone, and an unresponsive region in the contralateral image. These ROIs are saved to Matlab files
%   'roi_monoV1.mat', 'roi_binoV1.mat', and 'roi_unresponsive.mat'.
%
%   If these files exist, then the ROI drawing is skipped unless the parameter 'Force_draw_new_ROI' is set.
%
%   SUCCESS is 1 if the rois were defined successfully and 0 otherwise.
%   
%   The function's default behavior can be modified by passing
%   name/value pairs as additional input arguments:
%   Name (default value):          | Description: 
%   ----------------------------------------------------------
%   Force_draw_new_ROI (0)         | Should we force the user to
%                                  |   redraw an ROI even if it
%                                  |   already exists?
%   stimulus_number (1)            | The stimulus number to use for drawing the roi
%                                  |   (should be stimulus with robust expected response)
%   image_scale ([-0.001 0.001])   | Scale of dR/R of images
%   verbose (1)                    | 0/1 Should we describe what we are
%                                  |   doing on the command line
%

Force_draw_new_ROI = 0;
Stims_to_combine = [1 2];
Response_sign = -1;
stimulus_number = 1;
image_scale = [ -0.001 0.001];
verbose = 1;

assign(varargin{:});

success = 0;

dirname = {ipsi_response_dir contra_response_dir};

for i=1:2,
	monocular_roi_filename{i}  = [base_directory filesep dirname{i} filesep 'roi_monoV1.mat'];
	binocular_roi_filename{i}  = [base_directory filesep dirname{i} filesep 'roi_binoV1.mat'];
	background_roi_filename{i} = [base_directory filesep dirname{i} filesep 'roi_unresponsive.mat'];
end;

need_rois = 0;
for i=1:2,
	if ~exist(monocular_roi_filename{i},'file') | ~exist(binocular_roi_filename{i},'file') | ~exist(background_roi_filename{i},'file'),
		need_rois = 1;
	end;
end;

title_str = {'ipsilateral','contralateral'};

roi_colors = [0 0 1; 1 0 0; 0 1 0];

if need_rois | Force_draw_new_ROI,
	roifig=figure('name','Draw ROIs');
	colormap(gray(256));

	for i=1:2,
		base_image{i} = load([base_directory filesep dirname{i} filesep 'singlecondition' sprintf('%.4d',stimulus_number) '.mat']);
		base_image{i} = rescale(base_image{i}.imgsc,image_scale,[0 255]);

		subplot(2,2,i);
		image(base_image{i});
		axis square;
		title(title_str{i});
	end;

	satisfied = 0;

	while ~satisfied,
		h = [];
		for i=1:3, 
			if i==1,
				eyestr = 'IPSI';
				respstr = 'response area';
			elseif i==2,
				eyestr = 'CONTRA';
				respstr = 'response area';
			else,
				eyestr = 'CONTRA';
				respstr = 'unresponsive area';
			end;

			questdlg(['Please draw an ROI in the ' eyestr ' ' respstr ' area. Double-click when done.'],'Note','OK','OK');

			subplot(2,2,min(2,i));
			[BW_{i},xi_{i},yi_{i}] = roipoly;

		end;

		BW_{2}(find(BW_{1})) = 0; % clear out any overlap with binocular
		BW_{3}(find(BW_{1})) = 0; % clear out any overlap with binocular
		BW_{3}(find(BW_{2})) = 0; % clear out any overlap with monocular

		for i=1:3,
			B{i} = bwboundaries(BW_{i},8);
			xi_{i} = B{i}{1}(:,2);
			yi_{i} = B{i}{1}(:,1);

			for j=1:2,
				subplot(2,2,j);
				hold on;
				h(end+1) = plot(xi_{i},yi_{i},'-','color',roi_colors(i,:));
			end;

		end;

		reply = input('Are you satisfied with ROIs? [Y/N]','s');
		if strcmp(upper(strtrim(reply)),'Y'),
			satisfied = 1;
		else,
			delete(h); % re-do
		end;
	end;

	delete(roifig);

	for i=1:2,
		% ipsi
		for j=1:3,
			BW = BW_{j};
			xi = xi_{j};
			yi = yi_{j};
			if j==1,
				save(monocular_roi_filename{i},'BW','xi','yi','-mat');
			elseif j==2,
				save(binocular_roi_filename{i},'BW','xi','yi','-mat');
			elseif j==3,
				save(background_roi_filename{i},'BW','xi','yi','-mat');
			end;
		end;
	end;
end;

success = 1;
