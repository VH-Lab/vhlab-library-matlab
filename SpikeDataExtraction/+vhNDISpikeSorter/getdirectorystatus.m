function [dirnames, status] = getdirectorystatus(ds, optdirname)
% GETDIRECTORYSTATUS - Get the status of directories that have Multichannel LabView data
%
%    [DIRS,STATUS] = GETDIRECTORYSTATUS(DS, [DIRNAME])
%
%  Examines the directories in the DIRSTRUCT DS to see which ones
%  contain multichannel LabView data (that is, files with names
%  '*.rhd'). For each such directory, it returns a
%  status structure STATUS that have several fields that take the values
%  -1 (if a file is present but incomplete), 0 (if a file is not present),
%  or 1 (the file is present and complete).
%
%  FIELDNAME (value)          : Description
%    vhintan_filtermap           :  Is there a vh_filtermap.txt file?
%    vhintan_filtermap_values    :  The values from the file
%    vhintan_thresholds          :  Is there a vh_thresholds file?
%    vhintan_channelgrouping     :  Is there a vh_channelgrouping.txt file?
%    intan_spikewaveforms_N      :  Are there intan_spikewaveforms_N.vws files?
%    intan_spiketimes_N          :  Are there intan_spiketimes_N.vst files?
%
%  If the directory DIRNAME is provided, then status is only returned about
%  that particular directory (or list of directories, if it is a cell array
%  of directory names).
%

if nargin>=2,
	if ischar(optdirname)
		dirnames = {optdirname};
	else,
		dirnames = optdirname;
	end;
else, % get a directory list
	total_dirs = getalltests(ds);
	pn = getpathname(ds);
	incl = [];
	for i=1:length(total_dirs),
		d = exist(vhNDISpikeSorter.getdirfilename([pn filesep total_dirs{i}]));
		if d==2,
			incl(end+1) = i;
		end;
	end;
	dirnames = total_dirs(incl);
end;

status = struct('vhintan_filtermap',[],'vhintan_filtermap_values',[],'vhintan_thresholds',[],'vhintan_thresholds_values',[],'vhintan_channelgrouping',[],'intan_spikewaveforms_N',[],'intan_spiketimes_N',[]);
status = status([]);

for i=1:length(dirnames)
	newstatus.vhintan_filtermap = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhintan_filtermap.txt']));
	if newstatus.vhintan_filtermap~=0,
		newstatus.vhintan_filtermap_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhintan_filtermap.txt']);
	else,
		newstatus.vhintan_filtermap_values = [];
	end;
	newstatus.vhintan_thresholds = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhintan_thresholds.txt']));
	if newstatus.vhintan_thresholds,
		newstatus.vhintan_thresholds_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhintan_thresholds.txt']);
		newstatus.vhintan_thresholds = -1; % assume incomplete until we have evidence otherwise
		if newstatus.vhintan_filtermap~=0,
			%class([newstatus.vhintan_thresholds_values.channel])
			if isempty(setdiff([newstatus.vhintan_filtermap_values.channel_list],[newstatus.vhintan_thresholds_values.channel])),
				% if every channel we know about has an assigned threshold, then we're done
				newstatus.vhintan_thresholds = 1;
			end;
		end;
	else,
		newstatus.vhintan_thresholds_values = [];
	end;
	newstatus.vhintan_channelgrouping = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhintan_channelgrouping.txt']));
	newstatus.intan_spikewaveforms_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'intan_spikewaveforms_*.vsw']));
	% in the future, this should check to make sure number of spikewaveforms clusters matches channgelgrouping
	newstatus.intan_spiketimes_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'intan_spiketimes_*.vst']));
	status(end+1) = newstatus;
end;
