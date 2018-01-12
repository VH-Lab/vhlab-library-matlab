function [dirnames, status] = vhspike2_getdirectorystatus(ds, optdirname)
% VHSPIKE2_GETDIRECTORYSTATUS - Get the status of directories that have Multichannel LabView data
%
%    [DIRS,STATUS] = VHSPIKE2_GETDIRECTORYSTATUS(DS, [DIRNAME])
%
%  Examines the directories in the DIRSTRUCT DS to see which ones
%  contain multichannel LabView data (that is, files with names
%  '*.rhd'). For each such directory, it returns a 
%  status structure STATUS that have several fields that take the values
%  -1 (if a file is present but incomplete), 0 (if a file is not present),
%  or 1 (the file is present and complete). 
%
%  FIELDNAME (value)          : Description
%    vhspike2_filtermap           :  Is there a vhspike2_filtermap.txt file?
%    vhspike2_filtermap_values    :  The values from the file
%    vhspike2_thresholds          :  Is there a vhspike2_thresholds file?
%    vhspike2_channelgrouping     :  Is there a vhspike2_channelgrouping.txt file?
%    vhspike2_spikewaveforms_N    :  Are there vhspike2_spikewaveforms_N.vws files?
%    vhspike2_spiketimes_N        :  Are there vhspike2_spiketimes_N.vst files?
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
		d = exist(vhspike2_getdirfilename([pn filesep total_dirs{i}]));
		if d==2,
			incl(end+1) = i;
		end;
	end;
	dirnames = total_dirs(incl);
end;

status = struct('vhspike2_filtermap',[],'vhspike2_filtermap_values',[],'vhspike2_thresholds',[],'vhspike2_thresholds_values',[],'vhspike2_channelgrouping',[],'vhspike2_spikewaveforms_N',[],'vhspike2_spiketimes_N',[]);
status = status([]);

for i=1:length(dirnames)
	newstatus.vhspike2_filtermap = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_filtermap.txt']));
	if newstatus.vhspike2_filtermap~=0,
		newstatus.vhspike2_filtermap_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_filtermap.txt']);
	else,
		newstatus.vhspike2_filtermap_values = [];
	end;
	newstatus.vhspike2_thresholds = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_thresholds.txt']));
	if newstatus.vhspike2_thresholds,
		newstatus.vhspike2_thresholds_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_thresholds.txt']);
		newstatus.vhspike2_thresholds = -1; % assume incomplete until we have evidence otherwise
		if newstatus.vhspike2_filtermap~=0,
			%class([newstatus.vhspike2_thresholds_values.channel])
			if isempty(setdiff([newstatus.vhspike2_filtermap_values.channel_list],[newstatus.vhspike2_thresholds_values.channel])),
				% if every channel we know about has an assigned threshold, then we're done
				newstatus.vhspike2_thresholds = 1;
			end;
		end;
	else,
		newstatus.vhspike2_thresholds_values = [];
	end;
	newstatus.vhspike2_channelgrouping = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_channelgrouping.txt']));
	newstatus.vhspike2_spikewaveforms_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_spikewaveforms_*.vsw']));
	% in the future, this should check to make sure number of spikewaveforms clusters matches channgelgrouping
	newstatus.vhspike2_spiketimes_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'vhspike2_spiketimes_*.vst']));
	status(end+1) = newstatus;
end;


