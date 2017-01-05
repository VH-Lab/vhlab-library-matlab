function [cells,cellnames,incl] = filter_by_reference(cells,cellnames,minreference,maxreference)
% FILTER_BY_REFERENCE - Filter out cells by the cluster reference number
%
%  [CELLS,CELLNAMES,INCLUDED] = FILTER_BY_REFERENCE(CELLS, CELLNAMES, ...
%     MIN_REFERENCE, MAX_REFERENCE);
%  
%  Filters out any cell that does not have a reference between MIN_REFERENCE
%  and MAX_REFERENCE.  The unfiltered cells are returned back in CELLS, 
%  CELLNAMES. The reference is pulled from the cell name:
%
%  For example, if the cell name is 'cell_extra_001_002_2013_10_11',
%  then the reference is 1 (the 'name' is 'extra' and the 'ref' is 1).
%
%  The referencees of the cells that pass the filter are returned in INCLUDED.
%

incl = [];

for i=1:length(cellnames),
	[nameref,index,datestr] = cellname2nameref(cellnames{i});
	if nameref.ref>= minreference & nameref.ref <=maxreference,
		incl(end+1) = i;
	end;
end;

cells = cells(incl);
cellnames = cellnames(incl);
