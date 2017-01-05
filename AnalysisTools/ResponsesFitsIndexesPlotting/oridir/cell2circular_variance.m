function cv = cell2circular_variance(cell, assoc_prefix)

% CELL2CIRCULARVARIANCE - Calculate circulare variance from a cell
%
%  CV = CELL2CIRCULARVARIANCE(CELL, ASSOC_PREFIX)
%
%  Reads from an associate called [ASSOC_PREFIX ' OT Response curve']
%  and calculates circular variance.  The 'blank' response is subtracted
%  (if available, [ASSOC_PREFIX ' OT Blank response'] is used).
%  
%
%  Example:
%
%    ASSOC_PREFIX = 'TP ME Ach'
%    or 
%    ASSOC_PREFIX = 'TP Ach'

A = findassociate(cell, [assoc_prefix ' OT Response curve'],'','');
B = findassociate(cell, [assoc_prefix ' OT Blank Response'],'','');

if ~isempty(B),
	A.data(2,:) = A.data(2,:) -B.data(1);
end;

cv = compute_circularvariance( A.data(1,:), A.data(2,:) );
