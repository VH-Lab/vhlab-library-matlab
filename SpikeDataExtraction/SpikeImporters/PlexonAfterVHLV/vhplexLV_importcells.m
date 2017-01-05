function vhplexLV_importcells(ds, namerefs)
% VHPLEXLV_IMPORTCELLS Import cells that were acquired in LabView and spike-sorted in Plexon
%
%  VHPLEXLV_IMPORTCELLS(DS [, NAMEREFS])
%
%  Examines the directory structure and imports all spikes that were acquired in LabView
%  and sorted in Plexon's online sorter.
%
%  If NAMEREFS (a structure of name/reference pairs) is provided, then only those NAME/REF
%  pairs are examind for possible importing.
%
%  Assumes that each directory contains a proper 'reference.txt' file,
%  'vhlv_channelgrouping.txt' file, and 'plexonspikes-lv.txt' file.
%  (see help VHLV_CHANNELGROUPING, help PLEXONSPIKES-LV help REFERENCE_TXT)
%
%  See also: IMPORTSPIKEDATA
%
  

if nargin<2 | isempty(namerefs),
	namerefs = getallnamerefs(ds);
end;

for i=1:length(namerefs),
	indlist = [];
	T = gettests(ds,namerefs(i).name,namerefs(i).ref);
	%if strcmp(namerefs(i).name,'extra16') & namerefs(i).ref==3, keyboard; end;
	for t=1:length(T),

				% if we have more than one singleEC nameref here, how do we
                % know which spiketimes files to look at for a given
                % nameref?  Use the following file:
                % singleEC.txt
                % name     reference     type      filenum
                %
	        filenum = 0;  % channels are numbered from 0
	        try,
			f = loadStructArray([getpathname(ds) filesep T{t} filesep 'vhlv_channelgrouping.txt']);
	        catch,
			f = [];
		end;
		if isempty(f),
			filenum_offset = 0;
			num_singleECs = 0;
			z = loadStructArray([getpathname(ds) filesep T{t} filesep 'reference.txt']);
			for j=1:length(z),
				if strcmp(z(j).type,'singleEC'),
					num_singleECs = num_singleECs + 1;
				end;
				if (strcmp(z(j).name,namerefs(i).name) & z(j).ref==namerefs(i).ref),
					filenum_offset = num_singleECs;
				end;
			end;
			filenum = filenum + filenum_offset;
		else,
	        	for j=1:length(f),
		            if strcmp(f(j).name,namerefs(i).name)&(f(j).ref==namerefs(i).ref),
		                filenum = f(j).channel_list;
		            end;
		        end;
	        end;
        
		D = dir([getpathname(ds) filesep T{t} filesep 'plexonspikes-lv.txt']);
		for d=1:length(D),
			spikedata = load([getpathname(ds) filesep T{t} filesep D(d).name],'-ascii');
			indexesonthischannel = find(spikedata(:,1)==filenum);
			indlist = cat(1,indlist,unique(spikedata(indexesonthischannel,2)));
		end;
	end;

	indlist = unique(indlist);

	%namerefs(i);
	%indlist;

	mycell = {}; mycellname = {};
	for z=1:length(indlist),
		[mycell1,mycellname1] = vhplexLV_loadcell(ds,namerefs(i).name,namerefs(i).ref,indlist(z));
	    if ~isempty(mycell1), mycell{end+1} = mycell1; mycellname{end+1} = mycellname1; end;
	end;

	if ~isempty(mycell),
	    saveexpvar(ds,mycell,mycellname,1); % save, preserving any existing associates
	end;
end;

