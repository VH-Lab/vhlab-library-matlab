function spike2auditclusters(ds, nameref, dirname, saveit)
% SPIKE2AUDITCLUSTERS - audit clusters for a name/ref 
%
%   SPIKE2AUDITCLUSTERS(DS, NAMEREF, DIRNAME, SAVEIT)
%
%   This function will perform an audit of clusters that have been
%   extracted from Spike2 using SPIKE2EXTRACTALLCLUSTERS.  It allows
%   a new "quality" description to be associated with the cells.
%
%   Inputs:
%     DS - A DIRSTRUCT structure for the experiment directory
%     NAMEREF- A structure with the name and reference to examine
%               (e.g., struct('name','extra','ref',1))
%     DIRNAME: the directory name to examine.  If DIRNAME is
%       empty, then all directories where the cell was recorded 
%       are used.
%     SAVEIT - Should we save the answer back to disk?  0 means "no",
%       1 means "yes", -1 means "ask the user"
%
%    NOTE: This function has only been tested for single spikechan 
%    records.  One would need to re-test for multiple single channels or 
%    multichannel data.
%

  %  should operate on all cell indexes

spikewaves2NpointfeatureSampleList = [21 31];

 % Step 1 - Load the cell data from the experiment file

cellname = nameref2cellname(ds,nameref.name,nameref.ref,999);
ind = strfind(cellname,'999');
cellname(ind:ind+2) = '*';

[cells,cellnames] = load2celllist(getexperimentfile(ds),cellname,'-mat');

 % Step 2 - figure out which directories or directory to operate upon

if isempty(dirname),
	dirnamelist = gettests(ds,nameref.name,nameref.ref);
else,
	dirnamelist = {dirname};
end;

 % Step 3 - Determine the right spikechan to open by looping through all files to find a match

clusteridlist = [];
wavelist = [];

for i=1:length(dirnamelist),
	% for each directory, find correct spikechan
	dirprefix = [getpathname(ds) filesep dirnamelist{i} filesep];
	fileprefix = [dirprefix 'spike2matlabclusters_'];
	d = dir([fileprefix '*.vsw']);
	match = 0;
	for z=1:length(d),
		[waves,wavep] = readvhlspikewaveformfile([dirprefix d(i).name],1,1); % just read 1 wave to look at the header
		if strcmp(wavep.name,nameref.name) & wavep.ref==nameref.ref,
		% check for match, break
			match = z;
			break; % no need to continue the for loop
		end;
	end;
	if match==0,
		error(['Did not find record ' nameref.name ' | ' int2str(nameref.ref) ' in directory ' dirnamelist{i}   '.']);  % what kind of error message is this? need to think more
	end;
	% now that we have match, pull out the clusters
	[waves,wavep] = readvhlspikewaveformfile([dirprefix d(match).name]);
	matfile = d(match).name;
	loc = strfind(matfile,'.vsw');
	matfile(loc:loc+3) = '.mat';
	clusterinfo = load([dirprefix matfile],'-mat');
	wavelist = [wavelist waves];
	clusteridlist = [clusteridlist clusterinfo.clusterid{match}];
end;

 % Step 4 - Display the spikes

if 0,   % optionally, reorder the cluster list so it runs from 1 to N
	clusteridlist(find(clusteridlist==0)) = max(clusteridlist)+1; % get rid of 0's

	clusternums = unique([1 2 clusteridlist]); % need to make sure we include clusters 1 and 2
	clusteridlistorig = clusteridlist;

	for i=1:length(clusternums),
		clusteridlist(find(clusteridlistorig==clusternums(i))) = i;
	end;

	max(clusteridlist),
end;

[clusterids,clusterinfo] = cluster_spikewaves_gui('waves',wavelist,'waveparameters',wavep,...
	'clusterids',clusteridlist,...
	'EnableClusterEditing',0,'ForceQualityAssessment',1,...
	'spikewaves2NpointfeatureSampleList',spikewaves2NpointfeatureSampleList);

 % Step 5 - Convert the cluster quality measurement to an associate and give the user the option to save it

for i=1:length(cells),
	% find a match
	[cellnamenameref,cellnameindex] = cellname2nameref(cellnames{i});

	match = 0;
	for j=1:length(clusterinfo),
		if str2num(clusterinfo(j).number)==cellnameindex,
			match = j;
			break;
		end;
	end;

	if match~=0,
		isolation_asc = findassociate(cells{i},'Isolation','','');
		if isempty(isolation_asc),
			previous_isolation = 'No value';
		else,
			previous_isolation = isolation_asc.data;
		end;
		current_isolation = clusterinfo(match).qualitylabel;
		newisolation_asc = struct('type','Isolation','owner','spike2auditclusters.m','data',current_isolation,'desc','Isolation quality assessment');

		dosave = 0;
		switch saveit,
			case 1,
				dosave = 1;
			case 0,
			case -1,
				%options.Interpreter = 'None';
				answer = questdlg(['About to change isolation of ' cellnames{i} ' from ' previous_isolation ' to ' current_isolation],...
					'Confirm isolation change','Yes','No','Yes');
				if strcmp(answer,'Yes'), 
					dosave = 1;
				end;
		end;
		if dosave,
			disp(['Saving ' cellnames{i} ' per user request.']);
			cells{i} = associate(cells{i},newisolation_asc);
			saveexpvar(ds,cells{i},cellnames{i},0);
		else,
			disp(['Not saving ' cellnames{i} ' per user request.']);
		end;
	end;
end;

