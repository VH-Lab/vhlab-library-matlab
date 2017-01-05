function import_cells_spike2(ds, namerefs)
% IMPORT_CELLS_SPIKE2 - Import spiketimes from Spike2 data
%
%   IMPORT_CELLS_SPIKE2(DS, NAMEREFS)
%
%   Imports spike objects (CKSMULTIUNIT objects) into the experiment.mat file in 
%   the analysis folder of the directory managed by the DIRSTRUCT object DS.
%
%   NAMEREFS is a structure list (with fields 'name' and 'ref') of all the name/ref
%   fields to import.
%
%   See also: DIRSTRUCT, REFERENCE_TXT

  % need to fix loadfitzcell so if no spike file is saved from a particular file, no
  % interval is added


if nargin<2 | isempty(namerefs),
	namerefs = getallnamerefs(ds);
end;


for i=1:length(namerefs),
	indlist = [];
	T = gettests(ds,namerefs(i).name,namerefs(i).ref);
	for t=1:length(T),
				% if we have more than one singleEC nameref here, how do we
                % know which spiketimes files to look at for a given
                % nameref?  Use the following file:
                % singleEC.txt
                % name     reference     type      filenum
                %
	        filenum = 0;
	        try, f = loadStructArray([getpathname(ds) filesep T{t} filesep 'singleEC.txt']);
	        catch, f = [];
	        end;
	        for j=1:length(f),
	            if strcmp(f(j).name,name)&(f(j).ref==ref),
	                filenum = f(j).filenum;
	            end;
	        end;
        
		D = dir([getpathname(ds) filesep T{t} filesep 'spiketimes_' int2str(filenum) '_*.txt']);
		for d=1:length(D),
			indlist(end+1)=sscanf(D(d).name,['spiketimes_' int2str(filenum) '_%d.txt']);
		end;
	end;

	indlist = unique(indlist);

	mycell = {}; mycellname = {};
	for z=1:length(indlist),
		[mycell1,mycellname1] = vhspike2_loadcell(ds,namerefs(i).name,namerefs(i).ref,indlist(z));
	    if ~isempty(mycell1), mycell{end+1} = mycell1; mycellname{end+1} = mycellname1; end;
	end;

	if ~isempty(mycell),
	    saveexpvar(ds,mycell,mycellname,1); % save, preserving any existing associates
	end;

end;
