function [responses] = intrinsic_roi_responses(dirname, roi, varargin)
% INTRINSIC_ROI_RESPONSES - compute mean, standard deviation, standard error of responses within an ROI
%
% RESPONSES = INTRINSIC_ROI_RESPONSES(DIRNAME, ROI, ...)
%
% RESPONSES is a 4xN. The 1st row is the stimulus values (NaN for a blank
% stimulus), the 2nd row is the mean responses, the 3rd row is the
% standard deviation of the responses, and the 4th row is the standard
% error.
%
%
% Note: this function does not check to see if single condition images are up-to-date. For this, use
% CREATESINGLECONDITIONS.
%
% This function can also be modified by name-value pairs (see NAMEVALUEPAIR):
% Parameter (default)              | Description
% ---------------------------------------------------------------------------
% Stims (1:n, where n is number of | The stimuli to include in the calculation
%   conditions including blank)    | 
% Reference_roi ([])               | Index values of a reference ROI to subtract
%                                  %   for MEAN response only
% Response_sign (-1)               | Sign of the response (-1 means responses is
%                                  |   negative and the raw data is multiplied by -1)
% 
% See also: CREATESINGLECONDITIONS
%
% 

 % initialize default parameters

so = load([fixpath(dirname) 'stimorder.mat']);
so = so.stimorder;
sv = load([fixpath(dirname) 'stimvalues.mat']);

Stims = unique(so);
Reference_roi = [];
Response_sign = -1;

assign(varargin{:});

responses = nan(4,numel(Stims));

sv = sv(Stims);

stimlist = load([dirname filesep 'stims.mat'],'-mat');

  % load single condition progress file
prog = load([fixpath(dirname) 'singleconditionprogress.mat']);


for n=1:numel(Stims),
	stim = get(stimlist.saveScript,Stims(n));
	p = getparameters(stim);
	if isfield(p,'isblank'),
		isblank, = p.isblank;
	else,
		isblank = 0;
	end
	responses(1,n) = sv(n);
	s = load([dirname filesep 'singlecondition' sprintf('%.4d',Stims(n)) '.mat']);
	s = s.imgsc;
	responses(2,n) = Response_sign* mean(s(roi));
	if ~isempty(Reference_roi),
		responses(2,n) = responses(2,n) - mean(s(Reference_roi));
	end;
	s2 = load([dirname filesep 'singlecondition_stddev' sprintf('%.4d',Stims(n)) '.mat']);
	s2 = s.imgsc;
	responses(3,n) = Response_sign* mean(s2(roi));
	responses(4,n) = responses(3,n) / sqrt(sum(prog.existence{Stims(n)}>0));
end

