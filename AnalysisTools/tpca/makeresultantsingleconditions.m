function result = makeresultantsingleconditions(dirname, singleconditionfname, resultantfileout, varargin)
% MAKEMULTIPANELTPSTIMRESPONSES - Make a multipanel image showing stimulus responses
% 
%  MAKEMULTIPANELTPSTIMRESPONSES(DIRNAME, SINGLECONDITIONFNAME, RESULTANTFILEOUT, ... )
% 
%      normalizes the single condition images in SINGLECONDITIONFNAME by the sum of all
%  responses, and saves the result to RESULTANTFILEOUT.
% 
% This function also accepts name/value pairs that modify the default behavior:
% Parameter (default)           |   
% --------------------------------------------------------------------------
% channel (2)                   | The 2-photon channel that contains the responses
% laststimisblank (1)           | Is the last stimulus a blank?
%   
% See also: MAKEMULTIPANELTPDIRRESPONSES, MAKEMULTIPANELNMTPDISPLAY, NAMEVALUEPAIR

channel = 2;
laststimisblank = 1;

assign(varargin{:});

load( [dirname filesep singleconditionfname], 'indimages', '-mat');


lastimage = length(indimages);
if laststimisblank,
	lastimage = lastimage - 1;
end;

denominator = rectify(double(indimages{1}));

for i=2:lastimage,
	denominator = denominator + rectify(indimages{i});
end;

for i=1:lastimage,
	indimages{i} = indimages{i}./denominator;
end;

if laststimisblank,
	indimages{end} = 0*indimages{end};
end;

save( [dirname filesep resultantfileout], 'indimages', '-mat');


