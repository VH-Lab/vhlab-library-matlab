function vhplexsp2_importcells(ds, namerefs)

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
	        filenum = 1;  % channels are numbered from 1
	        try, f = loadStructArray([getpathname(ds) filesep T{t} filesep 'singleEC.txt']);
	        catch, f = [];
	        end;
	        for j=1:length(f),
	            if strcmp(f(j).name,name)&(f(j).ref==ref),
	                filenum = f(j).filenum;
	            end;
	        end;
        
		D = dir([getpathname(ds) filesep T{t} filesep 'plexonspikes-sp2.txt']);
		for d=1:length(D),
			spikedata = load([getpathname(ds) filesep T{t} filesep D(d).name],'-ascii');
			indexesonthischannel = find(spikedata(:,1)==filenum);
			indlist = cat(1,indlist,unique(spikedata(indexesonthischannel,2)));
		end;
	end;

	indlist = unique(indlist);

	mycell = {}; mycellname = {};
	for z=1:length(indlist),
		[mycell1,mycellname1] = vhplexsp2_loadcell(ds,namerefs(i).name,namerefs(i).ref,indlist(z));
	    if ~isempty(mycell1), mycell{end+1} = mycell1; mycellname{end+1} = mycellname1; end;
	end;

	if ~isempty(mycell),
	    saveexpvar(ds,mycell,mycellname,1); % save, preserving any existing associates
	end;

end;
