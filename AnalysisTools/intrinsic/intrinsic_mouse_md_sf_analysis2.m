function [outputs] = intrinsic_mouse_md_sf_analysis2(base_directory, animal_number, varargin)
%
%   OUTPUTS = INTRINSIC_MOUSE_MD_SF_ANALYSIS2(BASE_DIRECTORY, ANIMAL_NUMBER, ...)
%
%   BASE_DIRECTORY is the experiment directory (e.g., 'C:\Users\me\Documents\2015-05-25')
%
%   This directory should contain a file called 'sf_responses.txt' that that is a tab-delimited
%   file with a header row with entries 'IPSIHEM_IPSIEYE', 'IPSIHEM_CONTRAEYE', 
%   'CONTRAHEM_IPSIEYE', and 'CONTRAHEM_CONTRAEYE' (no quotes, tabs between them).
%   Subsequent rows should have the test directory names (e.g., t00001, t00002, etc).
%   
%   IPSIHEM_IPSIEYE is the name of the directory where stimulation was measured
%     in the ipsilateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the monocularly deprived eye (e.g., t00001).
%   IPSIHEM_CONTRAEYE is the name of the directory where stimulation was measured
%     in the ipsilateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the eye contralateral to the  monocularly deprived eye
%     (e.g., t00002).
%   CONTRAHEM_IPSIEYE is the name of the directory where stimulation was measured
%     in the contralateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the monocularly deprived eye (e.g., t00003).
%   CONTRAHEM_CONTRAEYE is the name of the directory where stimulation was measured
%     in the contralateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the eye contralateral to the  monocularly deprived eye
%     (e.g., t00004).
%
%   ANIMAL_NUMBER specifies the row of the 'sf_responses.txt' file that will be used to analyze the 
%   data. Because it is possible to have more than one animal's data in a folder, the user should specify
%   the animal number to analyzed (starting with 1, 2, up to the number of animals recorded here).
%
%   By default, this output is also saved in a file 'sf_tuning_ANIMAL_NUMBER.mat' in BASE_DIRECTORY.
%   
%
%   OUTPUTS is a structure with the following fields:
%   Fieldname:         | Description:
%   ------------------------------------------------------------------
%   condition_name     | The name of the condition being evaluated
%   roi_name           | The roi being evaluated (i.e., 'roi_binoV1' or 'roi_monoV1')
%   sfs                | The SFs tested
%   sf_responses       | The responses to each SF tested
%   blank_response     | The response to the blank stimulus
%   line               | Structure with the parameters of the best fit line of SF responses
%   log                | Structure with the parameters the best fit line of SF responses vs. log10 of SF
%   logthreshold       | Structure with the parameters of the best thresholded line fit of SF responses vs. log10 of SF
%   log_slope          | The slope of the best fit line of SF responses vs. log10 of SF
%   base_directory     | The base directory
%   dirname            | The directory name
%   
%   The function's default behavior can be modified by passing name/value pairs as additional input arguments:
%   Name (default value):          | Description: 
%   ----------------------------------------------------------
%   Force_draw_new_ROI (0)         | Should we force the user to
%                                  |   redraw an ROI even if it
%                                  |   already exists?
%   Response_sign (-1)             | Sign of the response (usually dR/R is
%                                  |   negative), should be -1 or 1
%   stimulus_number (2)            | The stimulus number to use for drawing the roi
%                                  |   (should be stimulus with robust expected response)
%   image_scale ([-0.001 0.001])   | Scale of dR/R of images
%   save_in_directory (1)          | Should we save the output to the base directory?
%   savenameprefix ('sf_tuning_')  | Prefix of the filename to save
%   verbose (1)                    | 0/1 Should we describe what we are
%                                  |   doing on the command line
%
%
%   Example:
%            dirname = 'Z:\Projects\ChelseaISI\2017-01-04';
%            animal_num = 1;
%            out = intrinsic_mouse_md_sf_analysis2(dirname, animal_num);
% 
%
%   See also: INTRINSIC_MOUSE_MONOBINO

Force_draw_new_ROI = 0;
Stims_to_combine = [1 2];
Response_sign = -1;
stimulus_number = 2;
image_scale = [ -0.001 0.001];
save_in_directory = 1;
savenameprefix = 'sf_tuning_';
verbose = 1;

assign(varargin{:});

z = loadStructArray([base_directory filesep 'sf_responses.txt']);
z = z(animal_number);

parameters = workspace2struct; % save these parameters with the file

names = {'IPSIHEM_IPSIEYE', 'IPSIHEM_CONTRAEYE', 'CONTRAHEM_IPSIEYE', 'CONTRAHEM_CONTRAEYE'};
roi_names = {'roi_binoV1', 'roi_monoV1'};

 % Step 1, get rois

success = intrinsic_mouse_monobino(base_directory, z.IPSIHEM_IPSIEYE, z.IPSIHEM_CONTRAEYE, 'Force_draw_new_ROI', Force_draw_new_ROI, ...
      'stimulus_number', stimulus_number);
success = intrinsic_mouse_monobino(base_directory, z.CONTRAHEM_CONTRAEYE, z.CONTRAHEM_IPSIEYE, 'Force_draw_new_ROI', Force_draw_new_ROI, ...
      'stimulus_number', stimulus_number);

output_blank = emptystruct('condition_name','roi_name', 'sfs','sf_responses','blank_response','line','log','logthreshold','base_directory','dirname');  % chelsea add fields here

outputs = output_blank;

for i=1:length(names),
	for j=1:length(roi_names),
		output_here = output_blank;
		output_here(1).base_directory = base_directory;
		output_here.condition_name = names{i};
		dirname = getfield(z,names{i});
		output_here.dirname = dirname;
		output_here.roi_name = roi_names{j};

		if verbose,
			disp(['Working on ' names{i} '(' dirname '), roi ' roi_names{j} '...']);
		end;
	
		roi_filename = [base_directory filesep dirname filesep roi_names{j} '.mat'];
		background_roi_filename = [base_directory filesep dirname filesep 'roi_unresponsive.mat'];

		BW = load(roi_filename,'-mat');
		BW = BW.BW;
		roi_indexes = find(BW);

		CW = load(background_roi_filename,'-mat');
		CW = CW.BW;
		background_roi_indexes = find(CW);

		stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');

		output_here.sfs = [];
		output_here.sf_responses = [];
		for n=1:numStims(stimlist.saveScript),
			stim = get(stimlist.saveScript,n);
			p = getparameters(stim);
			if isa(stim,'periodicstim'),
				output_here.sfs(end+1) = p.sFrequency;
				s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
				s = s.imgsc;
				output_here.sf_responses(end+1) = Response_sign * ( mean(s(roi_indexes)) - mean(s(background_roi_indexes)) );
			elseif isfield(p,'isblank'), % is a blank stimulus
				% background
				s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
				s = s.imgsc;
				output_here.blank_response = Response_sign * ( mean(s(roi_indexes)) - mean(s(background_roi_indexes)) );
			end;
		end;

		[output_here.line.slope,output_here.line.y_intercept] = quickregression(output_here.sfs(:), output_here.sf_responses(:),0.05); % (:) for columns
		output_here.line.x_intercept = -output_here.line.y_intercept / output_here.line.slope;

		[output_here.logthreshold.slope,output_here.logthreshold.offset,output_here.logthreshold.threshold,output_here.logthreshold.exponent]= ...
		linepowerthresholdfit(-log10(output_here.sfs(:)),output_here.sf_responses(:),'exponent_start',1,'exponent_range',[1 1]);

		[output_here.log.slope,output_here.log.y_intercept] = quickregression(log10(output_here.sfs(:)), output_here.sf_responses(:),0.05); % (:) for columns
		output_here.log.x_intercept = -output_here.log.y_intercept / output_here.log.slope;

        %output_here.gaussfit = chelsea_gaussfit(output_here.sfs(:), output_here.sf_responses(:);
        %output_here.dogfit = chelsea_dogfit(output_here.sfs(:), output_here.sf_responses(:);        
        
		outputs(end+1) = output_here;
	end;
end;

if save_in_directory,
	save([base_directory filesep savenameprefix int2str(animal_number) '.mat'],'outputs','parameters','-mat');
end;

