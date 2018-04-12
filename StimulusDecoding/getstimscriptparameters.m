function varargout = getstimscriptparameters(thestimscript, varargin)
% GETSTIMSCRIPTPARAMETERS - return parameters for a stimscript 
%
% [P1, P2, ...] = GETSTIMSCRIPTPARAMETERS(THESTIMSCRIPT, 'PARAM1', 'PARAM2', ...)
%
% Returns the values of parametes PARAM1, PARAM2, etc., for each stimulus
% in the stimscript STIMSCRIPT.
%
% Example:
%   [angles] = getstimscriptparameters(mystimscript,'angle');
%

N = numStims(thestimscript);

P = numel(varargin);

varargout = cell(size(varargin));

for n=1:N, % loop over stims
	for p = 1:P, % loop over parameters
		params = getparameters(get(thestimscript, n));
		if isfield(params,varargin{p}),
			varargout{p}(n,1) = getfield(params,varargin{p});
		else,
			varargout{p}(n,1) = NaN;
		end
	end
end

