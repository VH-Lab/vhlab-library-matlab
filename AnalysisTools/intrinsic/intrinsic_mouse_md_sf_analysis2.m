function [outputs] = intrinsic_mouse_md_sf_analysis2(base_directory, animal_number, varargin)
%
%   OUTPUTS = INTRINSIC_MOUSE_MD_SF_ANALYSIS2(BASE_DIRECTORY, ...
%        IPSI_DIRECTORY, CONTRA_DIRECTORY)
%
%   BASE_DIRECTORY is the experiment directory (e.g., 'C:\Users\me\Documents\2015-05-25')
%   IPSIHEM_IPSIEYE_DIRECTORY is the name of the directory where stimulation was measured
%     in the ipsilateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the monocularly deprived eye (e.g., 't00001').
%   IPSIHEM_CONTRAEYE_DIRECTORY is the name of the directory where stimulation was measured
%     in the ipsilateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the eye contralateral to the  monocularly deprived eye
%     (e.g., 't00002').
%   CONTRAHEM_IPSIEYE_DIRECTORY is the name of the directory where stimulation was measured
%     in the contralateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the monocularly deprived eye (e.g., 't00003').
%   CONTRAHEM_CONTRAEYE_DIRECTORY is the name of the directory where stimulation was measured
%     in the contralateral hemisphere with respect to the monocularly deprived eye and
%     where stimulation was provided through the eye contralateral to the  monocularly deprived eye
%     (e.g., 't00004').
%   
%
%   OUTPUTS is a 4 element structure with the following fields:
%   Fieldname:         | Description:
%   ------------------------------------------------------------------
%   condition_name     | The name of the condition being evaluated
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
%   The function's default behavior can be modified by passing
%   name/value pairs as additional input arguments:
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
%   verbose (1)                    | 0/1 Should we describe what we are
%                                  |   doing on the command line
%

Force_draw_new_ROI = 0;
Stims_to_combine = [1 2];
Response_sign = -1;
stimulus_number = 2;
image_scale = [ -0.001 0.001];
verbose = 1;

assign(varargin{:});

names = {'IPSIHEM_IPSIEYE', 'IPSIHEM_CONTRAEYE', 'CONTRAHEM_IPSIEYE', 'CONTRAHEM_CONTRAEYE'};
varnames = {'ipsihem_ipsieye_directory', 'ipsihem_contraeye_directory', 'contrahem_ipsieye_directory', 'contrahem_contraeye_directory'};

z = loadStructArray([base_directory filesep 'sf_responses.txt']);
z = z(animal_number);

for i=1:length(names),
	eval([varnames{i} ' = getfield(z,names{i});']);
end;


if verbose,
	for i=1:length(names),
		disp([names{i} ' directory is ' eval(varnames{i})]);
	end;
end;

output_blank = emptystruct('condition_name','sfs','sf_responses','blank_response','line','log','logthreshold','base_directory','dirname');

outputs = output_blank;



need_rois = 0;
for i=1:length(names),
	dirname = eval(varnames{i});
	roi_filename = [base_directory filesep dirname filesep 'roi_file.mat'];
	background_roi_filename = [base_directory filesep dirname filesep 'background_roi_file.mat'];
	if ~exist(roi_filename) | ~exist(background_roi_filename),
		need_rois = 1;
	end;
end;

pairs = [ 1 2 ; 4 3];  % order should be 'imaging ipsilateral input', 'imaging contralateral input'
pairnames = {'ipsilateral input','contralateral input'};
if need_rois | Force_draw_new_ROI,
	for j=1:size(pairs,1),  % take pairs of ipsi/contra images and have user draw rois
		roifig=figure('name','Draw ROIs');
		colormap(gray(256));
		clear base_image;
		for i=1:length(pairs(j,:)),
			dirname = eval(varnames{pairs(j,i)});
			base_image{i} = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',stimulus_number) '.mat']);
			base_image{i} = rescale(base_image{i}.imgsc,image_scale,[0 255]);
			subplot(2,2,i);
			image(base_image{i});
			axis square;
			title(pairnames{i});
		end;
		satisfied = 0;
		h = [];
		while ~satisfied,
			for i=1:length(pairs(j,:)),
				if i==1, eyestr = 'IPSI'; else, eyestr = 'CONTRA'; end;
				dirname = eval(varnames{pairs(j,i)});
				roi_filename = [base_directory filesep dirname filesep 'roi_file.mat'];
				roi_ipsifilename = [base_directory filesep dirname filesep 'roi_file_ipsi.mat'];
				background_roi_filename = [base_directory filesep dirname filesep 'background_roi_file.mat'];
				msgbox(['Please draw an ROI in the ' eyestr ' responsive area; double click when done.']);
				subplot(2,2,i);
				[BW,xi,yi] = roipoly;
				if i==1,
					BW_ipsi = BW;
				else,
					BW(find(BW_ipsi)) = 0; % make sure it is strictly contralateral
					save(roi_ipsifilename,'BW_ipsi','-mat');
				end;
				save(roi_filename,'BW','-mat');
				hold on;
				h(end+1) = plot(xi,yi,'b-');
			end;

			reply = input('Are you satisfied with ROIs? [Y/N]','s');
			if strcmp(upper(strtrim(reply)),'Y'),
				satisfied = 1;
			end;
		end;
		delete(roifig);
	end;
end;

Force_draw_new_ROI = 0;

for i=1:length(names),
	output_here = output_blank;
	output_here(1).base_directory = base_directory;
	output_here.condition_name = names{i};
	dirname = eval(varnames{i});
	output_here.dirname = dirname;
	
	base_image = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',stimulus_number) '.mat']);
	base_image = rescale(base_image.imgsc,image_scale,[0 255]);
	figure;
	subplot(2,2,1);
	image(base_image);
	axis square;
	colormap(gray(256));

	[dummy,fn] = fileparts(base_directory);
	title([fn ' ' names{i} ' (' dirname ')'],'interp','none');
	
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

	subplot(2,2,2);

	plot(output_here.sfs, output_here.sf_responses,'ko');
	ylabel('Response (dR/R)');
	xlabel('Spatial frequency');
	hold on;
	plot([0.01 1],[0.01 1]*output_here.line.slope+output_here.line.y_intercept,'k-');
	plot([0.01 1],[1 1]*output_here.blank_response,'k--');
	set(gca,'ylim',[-1 10]*1e-4);
	box off;
	title('Linear fit');

	[output_here.logthreshold.slope,output_here.logthreshold.offset,output_here.logthreshold.threshold,output_here.logthreshold.exponent]= ...
		linepowerthresholdfit(-log10(output_here.sfs(:)),output_here.sf_responses(:),'exponent_start',1,'exponent_range',[1 1]);

	subplot(2,2,3);

	plot(output_here.sfs, output_here.sf_responses,'ko');
	ylabel('Response (dR/R)');
	xlabel('Spatial frequency');
	hold on;
	plot(logspace(-3,0,100), ...
		linepowerthreshold(-log10(logspace(-3,0,100)), output_here.logthreshold.slope, ...
			output_here.logthreshold.offset, output_here.logthreshold.threshold, output_here.logthreshold.exponent),...
		'k-');
	plot([10^(-3) 10^(0)],[ 1 1 ]*output_here.blank_response,'k--');
	set(gca,'xscale','log');
	set(gca,'ylim',[-1 10]*1e-4);
	box off;
	title('Log-Linear fit w/ threshold');


	[output_here.log.slope,output_here.log.y_intercept] = quickregression(log10(output_here.sfs(:)), output_here.sf_responses(:),0.05); % (:) for columns
	output_here.log.x_intercept = -output_here.log.y_intercept / output_here.log.slope;

	subplot(2,2,4);

	plot(output_here.sfs, output_here.sf_responses,'ko');
	ylabel('Response (dR/R)');
	xlabel('Spatial frequency');
	hold on;
	plot([0.01 1],log10([0.01 1])*output_here.log.slope+output_here.log.y_intercept,'k-');
	plot([10^(-3) 10^(0)],[ 1 1 ]*output_here.blank_response,'k--');
	set(gca,'xscale','log');
	set(gca,'ylim',[-1 10]*1e-4);
	box off;
	title('Log-Linear fit');

	outputs(end+1) = output_here;

end;


