function [max_rate, coeff_var,stimid] = neural_maxrate_variability(resp)
%NEURAL_MAXRATE_VARIABILITY - Computes maximum rate, variability
%
%  [MAX_RATE, COEFF_VAR, STIMID] = NEURAL_MAXRATE_VARIABILITY(RESP)  
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of spatial frequencies tested,
%           |      curve(1,:) is spatial frequencies tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each SF
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blank    |    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
%  
% MAX_RATE is the maximum response across all stimulus conditions.
% COEFF_VAR is the coefficient of variation of this stimulus.
% STIMID is the stimulus id of the stimulus that gave the maximum response.

mns = []; stddevs = [];
mx = -Inf; mxind = -Inf;
for i=1:length(resp.ind),
    mns(i) = mean(resp.ind{i});
    stddevs(i) = std(resp.ind{i});
    if mns(i)>mx, mx = mns(i); mxind = i; end;
end;

stimid = mxind;
max_rate = mns(mxind);
if mns(mxind)~=0,
    coeff_var = stddevs(mxind)/mns(mxind);
else, coeff_var = 0;
end;