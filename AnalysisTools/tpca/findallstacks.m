function possiblestacks=findallstacks(cellsords)

% FINDALLSTACKS - Returns all two-photon stack names from cells
%
% STACKNAMES=FINDALLSTACKS(CELLS_OR_DIRSTRUCT)
%
% Given a cell list of two-photon cells or a directory structure,
%   returns a cell list of the names of all stacks created with
%   ANALYZETPSTACK.
%  
% See also:  DIRSTRUCT
% 

if isa(cellsords,'dirstruct'),
	[cells,cellnames] = load2celllist(getexperimentfile(cellsords),'cell*','-mat');
else, cells = cellsords;
end;

possiblestacks = {};
for i=1:length(cells),
	stackassoc = findassociate(cells{i},'analyzetpstack name','','');
	if ~isempty(stackassoc),
		possiblestacks{end+1} = stackassoc.data;
	end;
end;
possiblestacks = unique(possiblestacks);

