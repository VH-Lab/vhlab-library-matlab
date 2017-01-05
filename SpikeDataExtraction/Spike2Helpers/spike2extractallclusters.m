function spike2extractallclusters(ds, varargin)
%  SPIKE2EXTRACTALLCLUSTERS - Extract spike2 spike shapes using SON library
%
%    SPIKE2EXTRACTALLCLUSTERS(DS, ...)
%
%  This function extracts spike shapes from Spike2 files.
%
%  This function requires the sigTOOL library of Malcom Lidierth
%
%  Saves spikes using 
%
%  Additional parameters can be provided as name/value pairs:
%  -------------------------------------------------------------------
%  Related to Spike extraction: (see HELP SPIKE2CLUSTERS2SPIKESHAPES)
%  'spikechan'            |     default {[1]} (a single spike channel)
%  'timeoffset'           |     default 6.3e-4   
%  'samples'              |     Samples to examine (default 20)
%  Other:
%  'verbose'              |     Print progress (default 1)

spikechans = {[1]};
samples = 20;
timeoffset = 6.3e-4;
samples = 20;
verbose = 1;

assign(varargin{:});

nr = getallnamerefs(ds);

about = 'information in this file written by spike2extractallclusters.m';

for n=1:length(nr),
	T = gettests(ds,nr(n).name,nr(n).ref);
	for i=1:length(T),
		dirname = [getpathname(ds) filesep T{i}];
		if exist([dirname filesep 'spiketimes_0.txt'])==2,
			if verbose, disp(['Working on directory ' dirname '.']); end;
			[spikeshapes, electrodeid, clusterid, time] = ...
				spike2clusters2spikeshapes(dirname, spikechans, timeoffset, samples);
	
			for j=1:length(spikechans),
				ss = reshape(spikeshapes{j}',size(spikeshapes{j},1),size(spikeshapes{j},2));
				wavep.S0 = -samples;
				wavep.S1 = samples;
				wavep.numchannels = 1;
				wavep.name = nr(n).name;
				wavep.ref = nr(n).ref;
				wavep.comment ='';
				wavep.samplingrate = 10000;
				filename = [dirname filesep 'spike2matlabclusters_' int2str(j-1) '.vsw'];
				filename2 = [dirname filesep 'spike2matlabclusters_' int2str(j-1) '.mat'];
				if verbose, disp(['Writing file ' filename ]); end;
				fid = newvhlspikewaveformfile(filename,wavep);
				addvhlspikewaveformfile(fid,ss);
				fclose(fid);
				save(filename2,'clusterid','time','electrodeid','about','-mat');
			end;
		else,
			if verbose, disp(['Skipping directory ' dirname '.']); end;
		end;
	end;
end;


