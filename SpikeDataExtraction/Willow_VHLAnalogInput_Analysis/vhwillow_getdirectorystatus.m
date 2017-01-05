function [dirnames, status] = vhwillow_getdirectorystatus(ds, optdirname)
% VHWILLOW_GETDIRECTORYSTATUS - Get the status of directories that have Multichannel LabView data
%
%    [DIRS,STATUS] = VHWILLOW_GETDIRECTORYSTATUS(DS, [DIRNAME])
%
%  Examines the directories in the DIRSTRUCT DS to see which ones
%  contain multichannel LabView data (that is, files with names
%  '*.h5'). For each such directory, it returns a 
%  status structure STATUS that have several fields that take the values
%  -1 (if a file is present but incomplete), 0 (if a file is not present),
%  or 1 (the file is present and complete). 
%
%  FIELDNAME (value)          : Description
%    vhwillow_filtermap           :  Is there a vh_filtermap.txt file?
%    vhwillow_filtermap_values    :  The values from the file
%    vhwillow_thresholds          :  Is there a vh_thresholds file?
%    vhwillow_channelgrouping     :  Is there a vh_channelgrouping.txt file?
%    willow_spikewaveforms_N      :  Are there willow_spikewaveforms_N.vws files?
%    willow_spiketimes_N          :  Are there willow_spiketimes_N.vst files?
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
		d = exist(vhwillow_getdirfilename([pn filesep total_dirs{i}]));
		if d==2,
			incl(end+1) = i;
		end;
	end;
	dirnames = total_dirs(incl);
end;

status = struct('vhwillow_filtermap',[],'vhwillow_filtermap_values',[],'vhwillow_thresholds',[],'vhwillow_thresholds_values',[],'vhwillow_channelgrouping',[],'willow_spikewaveforms_N',[],'willow_spiketimes_N',[]);
status = status([]);

for i=1:length(dirnames)
	newstatus.vhwillow_filtermap = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhwillow_filtermap.txt']));
	if newstatus.vhwillow_filtermap~=0,
		newstatus.vhwillow_filtermap_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhwillow_filtermap.txt']);
	else,
		newstatus.vhwillow_filtermap_values = [];
	end;
	newstatus.vhwillow_thresholds = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhwillow_thresholds.txt']));
	if newstatus.vhwillow_thresholds,
		newstatus.vhwillow_thresholds_values = loadStructArray([getpathname(ds) filesep dirnames{i} filesep 'vhwillow_thresholds.txt']);
		newstatus.vhwillow_thresholds = -1; % assume incomplete until we have evidence otherwise
		if newstatus.vhwillow_filtermap~=0,
			%class([newstatus.vhwillow_thresholds_values.channel])
			if isempty(setdiff([newstatus.vhwillow_filtermap_values.channel_list],[newstatus.vhwillow_thresholds_values.channel])),
				% if every channel we know about has an assigned threshold, then we're done
				newstatus.vhwillow_thresholds = 1;
			end;
		end;
	else,
		newstatus.vhwillow_thresholds_values = [];
	end;
	newstatus.vhwillow_channelgrouping = (2==exist([getpathname(ds) filesep dirnames{i} filesep 'vhwillow_channelgrouping.txt']));
	newstatus.willow_spikewaveforms_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'willow_spikewaveforms_*.vsw']));
	% in the future, this should check to make sure number of spikewaveforms clusters matches channgelgrouping
	newstatus.willow_spiketimes_N = ~isempty(dir([getpathname(ds) filesep dirnames{i} filesep 'willow_spiketimes_*.vst']));
	status(end+1) = newstatus;
end;


