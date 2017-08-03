function cv = cell2dircircular_variance(cell, assoc_prefix)

% CELL2DIRCIRCULARVARIANCE - Calculate circulare variance from a cell
%
%  CV = CELL2DIRCIRCULARVARIANCE(CELL, ASSOC_PREFIX)
%
%  Reads from an associate called [ASSOC_PREFIX ' OT Response curve']
%  and calculates circular variance in direction space.  The 'blank' response is
%  subtracted (if available, [ASSOC_PREFIX ' OT Blank response'] is used).
%  
%
%  Example:
%
%    ASSOC_PREFIX = 'TP ME Ach'
%    or 
%    ASSOC_PREFIX = 'TP Ach'

  % trim any trailing space since we add it ourselves
if assoc_prefix(end)==' ', assoc_prefix = assoc_prefix(1:end-1); end;


A = findassociate(cell, [assoc_prefix ' OT Response curve'],'','');
B = findassociate(cell, [assoc_prefix ' OT Blank Response'],'','');

if ~isempty(B),
	A.data(2,:) = A.data(2,:) -B.data(1);
end;

cv = compute_dircircularvariance( A.data(1,:), A.data(2,:) );

function cv = compute_dircircularvariance( angles, rates )

% COMPUTE_DIRCIRCULARVARIANCE
%     CV = COMPUTE_DIRCIRCULARVARIANCE( ANGLES, RATES )
%
%     Takes ANGLES in degrees
%
% CV = 1 - |R|
% R = (RATES * EXP(I*ANGLES)') / SUM(RATES)
%
% See Ringach et al. J.Neurosci. 2002 22:5639-5651
% or Mazurek et al. Fronters Neural Circuits 2014

angles = angles/360*2*pi;
r = (rates * exp(i*angles)') / sum(abs(rates));
cv = 1-abs(r);
cv=round(100*cv)/100;

