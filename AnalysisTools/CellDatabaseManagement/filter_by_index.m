function [cells,cellnames,incl] = filter_by_index(cells,cellnames,minindex,maxindex)
% FILTER_BY_INDEX - Filter out cells by the cluster index number
%
%  [CELLS,CELLNAMES,INCLUDED] = FILTER_BY_INDEX(CELLS, CELLNAMES, ...
%     MIN_INDEX, MAX_INDEX);
%  
%  Filters out any cell that does not have an index between MIN_INDEX
%  and MAX_INDEX.  The unfiltered cells are returned back in CELLS, 
%  CELLNAMES. The index is pulled from the cell name:
%
%  For example, if the cell name is 'cell_extra_001_002_2013_10_11',
%  then the index is 1 (the 'name' is 'extra' and the 'ref' is 1).
%
%  The indexes of the cells that pass the filter are returned in INCLUDED.
%

incl = [];

for i=1:length(cellnames),
	[nameref,index,datestr] = cellname2nameref(cellnames{i});
	if index >= minindex & index <=maxindex,
		incl(end+1) = i;
	end;
end;

cells = cells(incl);
cellnames = cellnames(incl);
