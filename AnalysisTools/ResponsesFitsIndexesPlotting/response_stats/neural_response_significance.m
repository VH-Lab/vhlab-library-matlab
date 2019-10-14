function [sigp,sigpb] = neural_response_significance(resp)

%NEURAL_RESPONSE_SIGNIFICANCE - Computes significance of response variation
%
%  [SIGP,SIGPB] = NEURAL_RESPONSE_SIGNIFICANCE(RESP)  
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of spatial frequencies tested,
%           |      curve(1,:) is spatial frequencies tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each stim
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blankresp|    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
%  
% SIGP is the P value of an ANOVA across all stimulus conditions.
% SIGBP is the P value of an ANOVA across all stimulus conditions,
%    including the blank if it is available. If it is not available,
%    then this is identical to SIGP.

groupmem = [];
vals = [];
for i=1:length(resp.ind),
	vals = cat(1,vals,colvec(resp.ind{i}));
	groupmem = cat(1,groupmem,i*ones(size(colvec(resp.ind{i}))));
end;
sigp = anova1(vals,groupmem,'off');
if isfield(resp,'blankind'),
	vals = cat(1,vals,colvec(resp.blankind));
	groupmem = cat(1,groupmem,(length(resp.ind)+1)*ones(size(colvec(resp.blankind))));
	sigpb = anova1(vals,groupmem,'off');
else, sigpb = sigp;
end;
