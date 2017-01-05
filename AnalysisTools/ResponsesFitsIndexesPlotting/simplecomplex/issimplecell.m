function [b,f1f0,f1f0alt] = issimplecell(thecell, testname, varargin)
% ISSIMPLECELL - Test whether a cell is simple or complex based on grating responses
%
%  [B,F1F0,F1F0ALT] = ISSIMPLECELL(THECELL, TESTNAME, ...)
%
%  Examines data from TESTNAME (e.g., 'Dir1Hz3') and calculates the F1/F0
%  ratio.  If F1/F0 is 1 or more, the cell is declared 'simple' and B is 1.
%  Otherwise, the cell is declared to be complex and B is 0. The F1/F0 ratio
%  for the stimulus giving the maximum response is returned in F1F0.
%
%  The quantity 2*F1/(F0+F1) is returned in F1F0ALT;
%
%  If any records cannot be located, then NaN is returned for B and F1F0.
%
%  The behavior of the program can be modified by passing NAME/VALUE pairs as
%  additional arguments:
%  Parameter (default)              | Description: 
%  ---------------------------------------------------------------------------
%  AssociateTestPrefix ('SP F0 ')   | The prefix of the associate to be examined
%                                   |   (a corresponding associate with 'F0' substituted
%                                   |   for F1 will be examined for the F1 response).
%  AssociateTestPostfix ...         | The postfix of the associate to be examined.
%    ('Ach OT Response curve')      | 
%  BlankTestPostfix ...             | The postfix of the associate with the Blank response
%    ('Ach OT Blank Response')      | 
%  SubtractBlank (1)                | 0/1 Subtract the blank from the data?
%
%  See also: FINDASSOCIATE

AssociateTestPrefix = 'SP F0 ';
AssociateTestPostfix = 'Ach OT Response curve';
BlankTestPostfix = 'Ach OT Blank Response';
SubtractBlank = 1;

if length(testname)>1 & testname(end)~=' ', testname(end+1) = ' '; end;

assign(varargin{:});

b= NaN;
f1f0 = NaN;
f1f0alt = NaN;
B = findassociate(thecell,[AssociateTestPrefix testname AssociateTestPostfix],'','');
A = findassociate(thecell,[strrep(AssociateTestPrefix,'F0','F1') testname AssociateTestPostfix],'','');

if isempty(A) | isempty(B), return; end; % nothing to calculate

[maxA,bestA] = max(A.data(2,:)); % find largest mean response
[maxB,bestB] = max(B.data(2,:)); % find largest mean response

shiftA = 0;
shiftB = 0;

if SubtractBlank,
	D = findassociate(thecell,[AssociateTestPrefix testname BlankTestPostfix],'','');
	C = findassociate(thecell,[strrep(AssociateTestPrefix,'F0','F1') testname BlankTestPostfix],'','');
	if isempty(C) | isempty(D), return; end; % nothing to do
	shiftA = C.data(1);
	shiftB = D.data(1);
end;

b = (maxA-shiftA)>(maxB-shiftB);
if b, best = bestA; else, best = bestB; end;
f1f0 = (A.data(2,best)-shiftA)/(B.data(2,best)-shiftB);
f1f0alt = 2*(A.data(2,best)-shiftA)/(A.data(2,best)-shiftA+B.data(2,best)-shiftB);
