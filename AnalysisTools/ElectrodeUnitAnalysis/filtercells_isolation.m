function inds = filtercells_isolation(cells, acceptablevalues, associatename)
% FILTERCELLS_ISOLATION - Filter cells based on the user isolation rating
%
%   INDS = FILTERCELLS_ISOlATION(CELLS)
%      or
%   INDS = FILTERCELLS_ISOLATION(CELLS,ACCEPTABLEVALUES)
%      or
%   INDS = FILTERCELLS_ISOLATION(CELLS,ACCEPTABLEVALUES,ASSOCIATENAME)
%
%   Identifies cells that exhibit particular user-rated isolation values.
%   Typically, this is performed by examining the 
%
%   By default, the acceptable values are {'Good','Excellent'}
%   The use can specify other values by explicitly passing ACCEPTABLEVALUES:
%      e.g., ACCEPTABLEVALUES = {'Multi-unit','Good','Excellent'}
%
%   One can also specify an alternate ASSOCIATENAME above.
%
%   Note that this function ignores capitalization when comparing isolation labels.
%

 % step 1 -- set up

 % default inputs:
values = {'Good','Excellent'};
assoc_name = 'Isolation';
 % evaluate optional input arguments, if necessary
if nargin>1,
	values = acceptablevalues;
end;
if nargin>2,
	assoc_name = associatename;
end;

values = upper(values);  % ignore case, just convert to upper case

 % step 2 -- examine each cell to make sure it has an Isolation associate with appropriate values

inds = [];
for i=1:length(cells),
	isolation_asc = findassociate(cells{i},assoc_name,'','');
	if length(isolation_asc)>1,
		isolation_asc = findassociate(cells{i},assoc_name,'spike2auditclusters.m','');
	end;
	if ~isempty(isolation_asc),
		if ~isempty(intersect(values,upper(isolation_asc.data))),
			inds(end+1) = i;
		end;
	end;
end;


