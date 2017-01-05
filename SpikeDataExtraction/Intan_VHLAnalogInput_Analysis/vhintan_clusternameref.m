function vhintan_clusternameref(ds, name, ref)
% VHINTAN_CLUSTERNAMEREF - Cluster a name/reference pair collected using Intan
%
%   VHINTAN_CLUSTERNAMEREF(DS, NAME, REF)
%
%  Prompts user to cluster spike waveforms from the DIRSTRUCT DS from the
%  record with name NAME and reference number REF.
%
%  The output is stored in the directories in which the data were acquired in
%  text files called 'intan_st_name_ref_00M.txt', where M is the cluster number.


 % step 1 - load in the spikes

dirlist = sort(gettests(ds,name,ref));
waves = [];
dirinds = [];
times = [];

EpochStartSamples = [];
EpochNames = dirlist;

for i=1:length(dirlist),
	EpochStartSamples(end+1) = length(times)+1;
	dirname = [getpathname(ds) filesep dirlist{i}],
	channelgrouping_filename = [dirname filesep 'vhintan_channelgrouping.txt'];
	if exist(channelgrouping_filename),
		channelgrouping = loadStructArray(channelgrouping_filename);
	else,
		error(['No file ' channelgrouping_filename '.']);
	end;
	% find which channelgrouping corresponds to our name ref
	channelgroupingnum = [];
	for j=1:length(channelgrouping),
		if strcmp(channelgrouping(j).name,name)&channelgrouping(j).ref==ref,
			channelgroupingnum = j;
			break;
		end;
	end;
	[spikewaveforms, header] = readvhlspikewaveformfile([dirname filesep 'intan_spikewaveforms_' int2str(channelgroupingnum) '.vsw']);
    try,
        waves = cat(3,waves,spikewaveforms);
    catch,
        error(['Spikewaveform size mismatch: previous data is ' int2str(size(waves,1)) 'x' int2str(size(waves,2)) ' but data in ' dirlist{i} ' is ' int2str(size(spikewaveforms,1)) 'x' int2str(size(spikewaveforms,2)) '.']);
    end;
	fid = fopen([dirname filesep 'intan_spiketimes_' int2str(channelgroupingnum) '.vst'],'r','b');
    if fid<0, error(['Could not open file ' [dirname filesep 'intan_spiketimes_' int2str(channelgroupingnum) '.vst'] '.']); end;
	spiketimes = fread(fid,'float64');
	fclose(fid);
	times = [ times; spiketimes ];
	dirinds = [dirinds; i*ones(size(spiketimes))];
end;

 % step 2 - cluster the spikes
[clusterids,CI] = cluster_spikewaves_gui('waves',waves,'waveparameters',header,'windowlabel',['Sort spikes for name/ref ' name '/' int2str(ref)],...
	'ClusterRightAway',0,'EpochStartSamples',EpochStartSamples,'EpochNames',EpochNames);
clusterlist = unique(clusterids);
if any(isnan(clusterlist)), clusterlist = clusterlist(1:find(isnan(clusterlist),1,'first')); end;

 % step 3 - write the spike times back to disk

fname_prefix = ['intan_st_' name '_' int2str(ref) '_'];
infofname_prefix = ['intan_ci_' name '_' int2str(ref) '_'];

for i=1:length(dirlist),
	dirname = [getpathname(ds) filesep dirlist{i}];
	dirinds_here = find(dirinds==i);  %  the indexes that were collected in this directory
	% clear any existing clusters
	for j=0:20,
		try,
			warn_state = warning;
			warning off;
			delete([dirname filesep fname_prefix sprintf('%0.3d', j) '.txt']);
			delete([dirname filesep infofname_prefix sprintf('%0.3d', j) '.mat']);
			warning(warn_state);
		end;
	end;
	for j=1:length(clusterlist),
		clusterinds = find(clusterids(dirinds_here)==clusterlist(j)); % find the subset of indexes here that were part of this cluster
		timeshere = times(dirinds_here(clusterinds));  % grab the times of those events
		dlmwrite([dirname filesep fname_prefix sprintf('%0.3d', clusterlist(j)) '.txt' ], timeshere,'delimiter',' ','precision',10);
		clusterinfo = CI(j);
		save([dirname filesep infofname_prefix sprintf('%0.3d',clusterlist(j)) '.mat'], 'clusterinfo','-mat');
		if isempty(timeshere),	% if we have no spiketimes here, check to make sure the unit is "present" here
			if isfield(CI(j),'EpochStart') & isfield(CI(j),'EpochStop'),
				z1=find(strcmp(CI(j).EpochStart,dirlist),1,'first');
				z2=find(strcmp(CI(j).EpochStop,dirlist),1,'first');
				if i>=z1 & i<=z2, % recording is present here, no modifications needed
				else, % recording is not present here; we shouldn't have an empty file but rather no file
					% that is, it's not that we were listening and the cell did not spike; we weren't even listening to it
					try,
						warn_state = warning;
						warning off;
						delete([dirname filesep fname_prefix sprintf('%0.3d',clusterlist(j)) '.txt']);
						delete([dirname filesep infofname_prefix sprintf('%0.3d',clusterlist(j)) '.mat']);
						warning(warn_state);
					end;
				end;
			end;
		end;
	end;
end;

