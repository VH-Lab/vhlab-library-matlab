function [dI1,dI2, inds]=tpdscatterplot(cells,incl1,incl2,index1assoc,funcstring1,index2assoc,funcstring2,pvalueassoc,pvalue);

%  TPDSCATTERPLOT - Points for difference scatterplot
%
%  [dI1,dI2,INDS]=TPDSCATTERPLOT(CELLS, INCL1, INCL2, INDEX1ASSOC, FUNCSTRING1, ...
%            INDEX2ASSOC, FUNCSTRING2, PVALUEASSOC, PVAL);
%
%  Generates a set of ordered pairs for a scatterplot that
%  is the change in one variable of interest vs. the change
%  in another variable of interest for all pairs of cells
%  meeting the selection criteria.
%
%  CELLS and is a list of MEASUREDDATA objects w/ associates.
%  INCL1 and INCL2 describe which cells should be included in
%  pairs.  All pairs will be chosen with one member in CELLS(INCL1) and
%  the other in CELLS(INCL2).  For a full scatterplot, use INCL1=INCL2
%  set INCL1=1:length(CELLS).  This is also the default when empty is
%  passed.
%
%  INDEX1ASSOC - Associate type for first variable
%
%  FUNCSTRING1 - Can be a string describing a mathematical
%    equation for the difference between the index values.
%    In the string, 'x1' is the value of the first index from
%    one cell in the pair, and 'x2' is the value of the first
%    index from another cell in the pair.  For example,
%    'abs(x1-x2)' or 'min(abs([x1-x2-360 x1-x2 x1-x2+360]))'.
%
%  INDEX2ASSOC - Associate type for second variable
%
%  FUNCSTRING2 - Mathematical equation for second variable.
%    Variables are again coded by x1, x2.
%
%  PVALUEASSOC is an associate type that contains a P value
%    for deciding whether or not to include a given point.
%
%  PVALUE is the cut-off P value (e.g., 0.05).
%
%  dI1 are the difference values for variable 1, dI2 are the
%  difference values for variable 2, and INDS are the cell indices
%  that were included.
%

dI1 = []; dI2 = []; inds = [];


if ~isempty(pvalueassoc),
    toinclude = [];
    for i=1:length(cells),  % let's narrow our search space for below
    	pva = findassociate(cells{i},pvalueassoc,'','');
    	if pva.data <= pvalue, toinclude(end+1) = i; end;
    end;
else, toinclude = 1:length(cells);
end;

if isempty(incl1), incl1 = toinclude; else, incl1 = intersect(incl1,toinclude); end;
if isempty(incl2), incl2 = toinclude; else, incl2 = intersect(incl2,toinclude); end;


for i=1:length(incl1),
	a1 = findassociate(cells{incl1(i)},index1assoc,'','');
	b1 = findassociate(cells{incl1(i)},index2assoc,'','');
	for j=1:length(incl2),
        if incl1(i)~=incl2(j), % don't include points w/ themselves
    		a2 = findassociate(cells{incl2(j)},index1assoc,'','');
    		b2 = findassociate(cells{incl2(j)},index2assoc,'','');
    		if ~isempty(a1)&~isempty(a2)&~isempty(b1)&~isempty(b2),
    			inds(end+1,:) = toinclude([i j]);
    			x1 = a1.data; x2 = a2.data;
    			dI1(end+1) = eval(funcstring1);
    			x1 = b1.data; x2 = b2.data;
    			dI2(end+1) = eval(funcstring2);
    		end;
        end;
	end;
end;


