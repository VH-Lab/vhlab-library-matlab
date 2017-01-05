function [dirnames, status] = vhlv_getdirectorystatus(ds, optdirname)
% VHLV_GETDIRECTORYSTATUS - Get the status of directories that have Multichannel LabView data
%
%    [DIRS,STATUS] = VHLV_GETDIRECTORYSTATUS(DS, [DIRNAME])
%
%  Examines the directories in the DIRSTRUCT DS to see which ones
%  contain multichannel LabView data (that is, files with names
%  'vhlvanaloginput.vld'). For each such directory, it returns a 
%  status structure STATUS that have several fields that take the values
%  -1 (if a file is present but incomplete), 0 (if a file is not present),
%  or 1 (the file is present and complete). 
%
%  FIELDNAME (value)          : Description
%    vhlv_filtermap           :  Is there a vh_filtermap.txt file?
%    vhlv_filtermap_values    :  The values from the file
%    vhlv_thresholds          :  Is there a vh_thresholds file?
%    vhlv_channelgrouping     :  Is there a vh_channelgrouping.txt file?
%    lv_spikewaveforms_N      :  Are there lv_spikewaveforms_N.vws files?
%    lv_spiketimes_N          :  Are there lv_spiketimes_N.vst files?
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
	incl = [];
	for i=1:length(total_dirs),
		d = exist([getpathname(ds) filesep total_dirs{i} filesep 'vhlvanaloginput.vld']);
		if d==2,
			incl(end+1) = i;
		end;
	end;
	dirnames = total_dirs(incl);
end;

status = struct('vhlv_filtermap',[],'vhlv_filtermap_values',[],'vhlv_thresholds',[],'vhlv_thresholds_values',[],'vhlv_channelgrouping',[],'lv_spikewaveforms_N',[],'lv_spiketimes_N',[]);
status = status([]);

for i=1:length(dirnames)
	newstatus.vhlv_filtermap = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhlv_filtermap.txt']));
	if newstatus.vhlv_filtermap~=0,
		newstatus.vhlv_filtermap_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhlv_filtermap.txt']);
	else,
		newstatus.vhlv_filtermap_values = [];
	end;
	newstatus.vhlv_thresholds = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhlv_thresholds.txt']));
	if newstatus.vhlv_thresholds,
		newstatus.vhlv_thresholds_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhlv_thresholds.txt']);
		newstatus.vhlv_thresholds = -1; % assume incomplete until we have evidence otherwise
		if newstatus.vhlv_filtermap~=0,
			%class([newstatus.vhlv_thresholds_values.channel])
			if isempty(setdiff([newstatus.vhlv_filtermap_values.channel_list],[newstatus.vhlv_thresholds_values.channel])),
				% if every channel we know about has an assigned threshold, then we're done
				newstatus.vhlv_thresholds = 1;
			end;
		end;
	else,
		newstatus.vhlv_thresholds_values = [];
	end;
	newstatus.vhlv_channelgrouping = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhlv_channelgrouping.txt']));
	newstatus.lv_spikewaveforms_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'lv_spikewaveforms_*.vsw']));
	% in the future, this should check to make sure number of spikewaveforms clusters matches channgelgrouping
	newstatus.lv_spiketimes_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'lv_spiketimes_*.vst']));
	status(end+1) = newstatus;
end;


