function vhintan_importcells(ds, nrs)
% VHINTAN_IMPORTCELLS - Import cells from LabView that were spike-sorted with VH lab tools
%  
%    VHINTAN_IMPORTCELLS(DS)
%
%    Imports all spikes that were acquired in LabView and were spike-sorted
%    with the VH Lab tools.  DS is a DIRSTRUCT object that manages the 
%    experimental data directory (see 'help dirstruct')
%
%    The 'units' for each channel will be labeled starting with number 51.
%
%    One can also import the spikes for a single name/ref pair:
%
%    VHINTAN_IMPORTCELLS(DS, NAMEREF)
%
%    where NAMEREF is a structure with a field 'name' (a string) and 'ref' 
%    a number describing the record to import (see 'help reference_txt').
%
%    See also:  IMPORTSPIKEDATA, REFERENCE_TXT, DIRSTRUCT

if nargin<2,
	namerefs = getallnamerefs(ds);
else,
	namerefs = nrs;
end;

potential_extra_cells = {};
cells_to_save = {};
cellnames_to_save = {};

for i=1:length(namerefs),
	namerefs(i),
	indlist = [];
	T = gettests(ds,namerefs(i).name,namerefs(i).ref);
	for t=1:length(T),
		D = dir([getpathname(ds) filesep T{t} filesep 'intan_st_' namerefs(i).name '_' int2str(namerefs(i).ref) '_*.txt']);
		for d=1:length(D),
			index__here = sscanf(D(d).name,['intan_st_' namerefs(i).name '_' int2str(namerefs(i).ref) '_%d.txt']);
			if ~isempty(index__here),
				indlist(end+1)=index__here;
			end;
		end;
	end;

	indlist = unique(indlist),

	mycell = {}; mycellname = {};
	for z=1:length(indlist),
		[mycell1,mycellname1] = vhintan_loadcell(ds,namerefs(i).name,namerefs(i).ref,indlist(z));
	    if ~isempty(mycell1), mycell{end+1} = mycell1; mycellname{end+1} = mycellname1; end;
	end;
	
	cellname = nameref2cellname(ds,namerefs(i).name,namerefs(i).ref,888);
	s = strfind(cellname,'888');
	potential_extra_cells_here = {};
	for j=200+[50:70],
		potential_extra_cells_here{end+1} = [cellname(1:s-1) sprintf('%0.3d',j) cellname(s+3:end)];
	end;

	potential_extra_cells_here = setdiff(potential_extra_cells_here,mycellname);
	potential_extra_cells = cat(2,potential_extra_cells,potential_extra_cells_here);

	cells_to_save = cat(2,cells_to_save,mycell);
	cellnames_to_save = cat(2,cellnames_to_save,mycellname);

end;

	% this deletes and saves in one shot, saving disk access time
deleteexpvar(ds,potential_extra_cells,cells_to_save,cellnames_to_save,1);


