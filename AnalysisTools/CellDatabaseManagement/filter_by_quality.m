function [cells,cellnames,I] = filter_by_quality(ds, cells, cellnames, cellinfo)
% FILTER_BY_QUALITY - Filter out all but specified cell recordings
%
%  [CELLS,CELLNAMES,I] = FILTER_BY_QUALITY(DS, CELLS,CELLNAMES,CELLINFO)
%
%  Filters the list of MEASUREDDATA objects CELLS and the corresponding CELLNAMES
%  so that only those specified in CELLINFO are included.
%
%  See READ_UNITQUALITY for a description of the CELLINFO structure.
%
%  In a second step, if information about unit quality is present in the
%  information about unit quality is added to the cells as an associate
%  called 'QualityLabel'.
%
%  The indexes of the cells that pass the filter are returned in I.

I = [];

for i=1:length(cellinfo),
	cell_name = nameref2cellname(ds,cellinfo(i).name,cellinfo(i).ref,cellinfo(i).index);
	output = strfind(cellnames,cell_name);
	j = [];
	for zz=1:length(output),
		if ~isempty(output{zz}),
			j = zz;
			break;
		end;
	end;

	if ~isempty(j),

		I(end+1) = j; % we'll keep j

		% next see which if any directory links we have to remove because they weren't "good"
		inds_to_ax = [];
		[A,assoc_inds] = findassociate(cells{j},'','','');
		for a=1:length(assoc_inds),
			f = strfind(A(a).type,' test');
			if f==length(A(a).type-4), % we have a match,
				if ~any(A(a).data,cellinfo(i).goodtestdirs),
					inds_to_ax(end+1) = assoc_inds(a);
				end;
			end;
		end;
		if ~isempty(inds_to_ax),
			cells{j} = disassociate(cells{j},inds_to_ax);
		end;

		% now add a quality associate

		cells{j} = associate(cells{j},'Plexon Quality','',cellinfo(i).quality,'Quality label as determined by the user of the Offline Spike Sorter by Plexon');
	else,
		error(['No cell ' cell_name ' encountered in input cellnames.']);
	end;
end;

I = sort(I); % sort in order

cells = cells(I); 
cellnames = cellnames(I);
