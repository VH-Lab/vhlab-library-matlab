function [outputs] = intrinsic_mouse_od_analysis(base_directory, ipsi_directory, contra_directory, varargin)
%
%   OUTPUTS = INTRINSIC_MOUSE_OD_ANALYSIS(BASE_DIRECTORY, ...
%        IPSI_DIRECTORY, CONTRA_DIRECTORY)
%
%   BASE_DIRECTORY is the experiment directory (e.g., 'C:\Users\me\Documents\2015-05-25')
%   and IPSI_DIRECTORY is the name of the IPSI measurements (e.g., 't00006') and
%   CONTRA_DIRECTORY is the name of the CONTRA measurements (e.g., 't00007').
%
%   OUTPUTS is a structure with the following fields:
%   Fieldname:         | Description:
%   ----------------------------------------------------------
%   odindex            | The ocular dominance index: (C-I)/(C+I)
%   contra_resp        | The contralateral response C (delta R/R)
%   ipsi_resp          | The ipsilateral response I (delta R/R)
%   
%
%   The function's default behavior can be modified by passing
%   name/value pairs as additional input arguments:
%   Name (default value):          | Description: 
%   ----------------------------------------------------------
%   Force_draw_new_ROI (0)         | Should we force the user to
%                                  |   redraw an ROI even if it
%                                  |   already exists?
%   Stims_to_combine [1 2]         | Stim IDs that should be averaged
%                                  |   together
%   Response_sign (-1)             | Sign of the response (usually dR/R is
%                                  |   negative), should be -1 or 1
%   image_scale ([-0.005 0.005])   | Scale of dR/R of images
%   verbose (1)                    | 0/1 Should we describe what we are
%                                  |   doing on the command line
%

Force_draw_new_ROI = 0;
Stims_to_combine = [1 2];
Response_sign = -1;
image_scale = [ -0.0005 0.0005];
verbose = 1;

assign(varargin{:});

if verbose,
	disp(['IPSI directory is ' ipsi_directory ]);
	disp(['CONTRA directory is ' contra_directory ]);
end;

ipsi_stims = [];
contra_stims = [];

for i=1:length(Stims_to_combine),
	s = load([base_directory filesep ipsi_directory filesep 'singlecondition' sprintf('%.4d',Stims_to_combine(i)) '.mat']);
	ipsi_stims = cat(3,ipsi_stims, s.imgsc);
	s = load([base_directory filesep contra_directory filesep 'singlecondition' sprintf('%.4d',Stims_to_combine(i)) '.mat']);
	contra_stims = cat(3, contra_stims, s.imgsc);
end;

ipsi_stim = mean(ipsi_stims,3);
ipsi_stim_image = rescale(ipsi_stim,image_scale,[0 255]);
contra_stim = mean(contra_stims,3);
contra_stim_image = rescale(contra_stim,image_scale,[0 255]);

figure;
subplot(2,2,1);
image(ipsi_stim_image);
colormap(gray(256));
title('IPSI image');

subplot(2,2,2);
image(contra_stim_image);
colormap(gray(256));
title('CONTRA image');


ipsi_roi_filename = [base_directory filesep ipsi_directory filesep 'ipsi_roi_file.mat'];

if exist(ipsi_roi_filename)==7 & Force_draw_new_ROI==0,
	BW = load(ipsi_roi_filename,'-mat');
	BW = BW.BW;
else,
	subplot(2,2,1);
	msgbox(['Please draw an ROI in the IPSI window; double click when done']);
	BW = roipoly;
end;

indexes = find(BW);

ipsi_resp = (Response_sign) * mean(ipsi_stim(indexes));
contra_resp = (Response_sign) * mean(contra_stim(indexes));
odindex = (contra_resp - ipsi_resp) / (contra_resp + ipsi_resp);

outputs = var2struct('odindex','ipsi_resp','contra_resp');


