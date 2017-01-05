function [cells,inds]=selectstackcells(ds_or_cells,stackname)

% SELECTSTACKCELLS - Select all cells in a given stack
%
%   [CELLS,INDS]=SELECTSTACKCELLS(DS_OR_CELLS,STACKNAME)
%
%  Returns all cells within a given STACKNAME.  DS_OR_CELLS can be
%  either a directory structure of type DIRSTRUCT or a list of cell
%  objects.
%
%  CELLS is a cell list of cells that are in the stack, and 
%  INDS is an array with the indices.
%
%  See also:  FINDALLSTACKS


if isa(ds_or_cells,'dirstruct'),
	ds = ds_or_cells;
	cells=load2celllist(getexperimentfile(ds),'cell_tp*','-mat');
else, cells = ds_or_cells;
end;

inds = [];

for i=1:length(cells),
	stackassoc = findassociate(cells{i},'analyzetpstack name','','');
	if ~isempty(stackassoc),
		if strcmp(stackassoc.data,stackname),
			inds(end+1) = i;
		end;
	end;
end;

cells = cells(inds);
