function [outputs] = intrinsic_mouse_md_sf_analysis(base_directory, ipsihem_ipsieye_directory, ipsihem_contraeye_directory, contrahem_ipsieye_directory, contrahem_contraeye_directory, varargin)
%
%   OUTPUTS = INTRINSIC_MOUSE_MD_SF_ANALYSIS(BASE_DIRECTORY, ...
%        IPSI_DIRECTORY, CONTRA_DIRECTORY)
%
%   BASE_DIRECTORY is the experiment directory (e.g., 'C:\Users\me\Documents\2015-05-25')
%   and IPSI_DIRECTORY is the name of the IPSI measurements (e.g., 't00006') and
%   CONTRA_DIRECTORY is the name of the CONTRA measurements (e.g., 't00007').
%
%   OUTPUTS is a 4 element structure with the following fields:
%   Fieldname:         | Description:
%   ------------------------------------------------------------------
%   condition_name     | The name of the condition being evaluated
%   sfs                | The SFs tested
%   sf_responses       | The responses to each SF tested
%   slope              | The slope of the best fit line of SF responses
%   x_intercept        | The x intercept of the best fit line of SF responses
%   y_intercept        | The y intercept of the best fit line of SF responses
%   
%   The function's default behavior can be modified by passing
%   name/value pairs as additional input arguments:
%   Name (default value):          | Description: 
%   ----------------------------------------------------------
%   Force_draw_new_ROI (0)         | Should we force the user to
%                                  |   redraw an ROI even if it
%                                  |   already exists?
%   Response_sign (-1)             | Sign of the response (usually dR/R is
%                                  |   negative), should be -1 or 1
%   image_scale ([-0.001 0.001])   | Scale of dR/R of images
%   verbose (1)                    | 0/1 Should we describe what we are
%                                  |   doing on the command line
%

Force_draw_new_ROI = 0;
Stims_to_combine = [1 2];
Response_sign = -1;
image_scale = [ -0.001 0.001];
verbose = 1;

assign(varargin{:});

names = {'IPSIHEM_IPSIEYE', 'IPSIHEM_CONTRAEYE', 'CONTRAHEM_IPSIEYE', 'CONTRAHEM_CONTRAEYE'};
varnames = {'ipsihem_ipsieye_directory', 'ipsihem_contraeye_directory', 'contrahem_ipsieye_directory', 'contrahem_contraeye_directory'};

if verbose,
	for i=1:length(names),
		disp([names{i} ' directory is ' eval(varnames{i})]);
	end;
end;

output_blank = emptystruct('condition_name','sfs','sf_responses','slope','x_intercept','y_intercept');

outputs = output_blank;

for i=1:length(names),
	output_here = output_blank;
	output_here.condition_name = names{i};
	dirname = eval(varnames{i});
	
	stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');


	outputs(end+1) = output_here;
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
ipsi_no_resp_filename = [base_directory filesep ipsi_directory filesep 'ipsi_no_resp_file.mat'];
contra_no_resp_filename = [base_directory filesep contra_directory filesep 'contra_no_resp_file.mat'];

if exist(ipsi_roi_filename)==7 & Force_draw_new_ROI==0,
	BW = load(ipsi_roi_filename,'-mat');
	BW = BW.BW;
else,
	subplot(2,2,1);
	msgbox(['Please draw an ROI in the IPSI window; double click when done']);
	BW = roipoly;
end;

if exist(ipsi_no_resp_filename)==7 & Force_draw_new_ROI==0, %Gets unresponsive area of brain surface for ipsi stims
	CW = load(ipsi_no_resp_filename,'-mat');
	CW = CW.CW;
else,
	subplot(2,2,1);
	msgbox(['Please draw an unresponsive ROI in the IPSI window; double click when done']);
	CW = roipoly;
end;

if exist(contra_no_resp_filename)==7 & Force_draw_new_ROI==0, %gets unresponsive area of brain surface for contra stims
	DW = load(contra_no_resp_filename,'-mat');
	DW = DW.DW;
else,
	subplot(2,2,2);
	msgbox(['Please draw an unresponsive ROI in the CONTRA window; double click when done']);
	DW = roipoly;
end;

indexes = find(BW);
indexes_ipsi_no_resp = find(CW);
indexes_contra_no_resp = find(DW);
ipsi_no_resp_mean = mean(ipsi_stim(indexes_ipsi_no_resp));
contra_no_resp_mean = mean(contra_stim(indexes_contra_no_resp)); 


ipsi_resp = (Response_sign) * (mean(ipsi_stim(indexes)-(ipsi_no_resp_mean))); %subtracts mean of unresp ipsi area
contra_resp = (Response_sign) * (mean(contra_stim(indexes)-(contra_no_resp_mean))); %subracts mean of unresp contra area
odindex = (contra_resp - ipsi_resp) / (contra_resp + ipsi_resp);

outputs = var2struct('odindex','ipsi_resp','contra_resp','ipsi_no_resp_mean','contra_no_resp_mean');



