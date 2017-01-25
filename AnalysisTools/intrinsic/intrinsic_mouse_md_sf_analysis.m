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
%   base_directory     | The base directory
%   dirname            | The directory name
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

output_blank = emptystruct('condition_name','sfs','sf_responses','slope','x_intercept','y_intercept','base_directory','dirname');

outputs = output_blank;

for i=1:length(names),
	output_here = output_blank;
	output_here.base_directory = base_directory;
	output_here.condition_name = names{i};
	output_here.dirname = dirname;
	dirname = eval(varnames{i});
	
	base_image = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',1) '.mat']);
	base_image = rescale(base_image,image_scale,[0 255]);
	figure;
	subplot(2,2,1);
	image(base_image);
	axis square;
	colormap(gray(256));
	title([base_directory ' ' names{i} ' (' dirname ')']);
	
	roi_filename = [base_directory filesep dirname filesep 'roi_file.mat'];
	background_roi_filename = [base_directory filesep dirname filesep 'background_roi_file.mat'];

	if exist(roi_filename,'file') & Force_draw_new_ROI==0,
		BW = load(roi_filename,'-mat');
		BW = BW.BW;
	else,
		msgbox(['Please draw an ROI in the responsive area; double click when done.']);
		BW = roipoly;
		save(roi_filename,'BW','-mat');
	end;

	roi_indexes = find(BW);

	if exist(background_roi_filename,'file') & Force_draw_new_ROI == 0,
		CW = load(background_roi_filename,'-mat');
		CW = CW.CW;
	else,
		msgbox(['Please draw an ROI in the unresponsive background area; double click when done.']);
		CW = roipoly;
		save(background_roi_filename,'CW','-mat');
	end;

	background_roi_indexes = find(CW);

	stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');

	output_here.sfs = [];
	output_here.sf_responses = [];
	for n=1:numStims(stimlist.saveScript),
		stim = get(stimlist.saveScript,n);
		if isa(stim,'periodicstim'),
			p = getparameters(stim);
			output_here.sfs(end+1) = p.sFrequency;
			s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
			output_here.sf_responses(end+1) = Response_sign * ( mean(s(roi_indexes)) - mean(s(background_roi_indexes)) );
		end;
	end;

	[output_here.slope,output_here.y_intercept] = quickregression(output_here.sfs, output_here.sf_responses,0.05);

	output_here.x_intercept = -output_here.y_intercept / output_here.slope;

	subplot(2,2,2);

	plot(output_here.sfs, output_here.sf_responses,'ko');
	ylabel('Response (dR/R)');
	xlabel('Spatial frequency');

	hold on;
	plot([0.01 1],[0.01 1]*output_here.slope+output_here.y_intercept,'k--');

	outputs(end+1) = output_here;
end;


