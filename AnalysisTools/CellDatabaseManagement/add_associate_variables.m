function varargout=add_associate_variables(ds,varargin)
% ADD_ASSOCIATE_VARIABLES - Add associates from the file 'associate_variables.txt' to all cells in an experiment
%
%  ADD_ASSOCIATE_VARIABLES(DS)
%
%  Reads associates from the file 'associate_variables.txt' in the main
%  experiment directory to all cells in the experiment managed by the
%  dirstruct DS.  The variables are then saved back to disk.
%
%  The file associate_variables.txt should be organized as a structure text document.
%  The first line should be "type<tab>owner<tab>data<tab>description<newline>" and
%  each additional line should contain the entries for each associate.
%
%  One can also use the following form if the cells are already read:
%  [CELLS]=ADD_ASSOCIATE_VARIABLES(DS, CELLS) 
%  In this form, the cells are NOT saved back to disk, the user should do it
%  in his/her own code.
%   
%
%  See also: ASSOCIATE, ASSOCIATE_VARIABLES_TXT

filename = [getpathname(ds) filesep 'associate_variables.txt'];

if ~exist(filename,'file'),
	error(['Could not find the file ''associate_variables.txt'' in the directory ' getpathname(ds) '.']);
end;
  
assoclist = loadStructArray(filename);

if nargin>1,
	cells = varargin{1};
else,
	[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');
end;

  % remove any previous instances of these variables

for i=1:length(cells),
	for j=1:length(assoclist),
		[a,inds]=findassociate(cells{i},assoclist(j).type,'','');
		if ~isempty(a),
			cells{i} = disassociate(cells{i},inds);
		end;
	end;
end;

cells=associate_all(cells,assoclist);

if nargin>1,
	varargout{1} = cells;
else,
	disp(['writing variables back to disk']);
	saveexpvar(ds,cells,cellnames,0);
end;

