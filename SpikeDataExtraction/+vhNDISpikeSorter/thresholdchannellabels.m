function labels = thresholdchannellabels(status)
% VHINTAN_THRESHOLDCHANNELLABELS - Generate labels for channels that may/may not require thresholding
%
%  LABELS = VHINTAN_THRESHOLDCHANNELLABELS(STATUS)
%
%  Returns a label for each channel, such as '1 | T'.  STATUS should be a status
%  structure as returned by VHINTAN_GETDIRECTORYSTATUS.
%
%  The text after the | symbol indicates whether the channel has been assigned a threshold.
%
%  Space indicates no threshold, T indicates that a threshold has been assigned.


labels = {};

  % we want to group the channels by the filtermap

for i=1:length(status.vhintan_filtermap_values),
	str = '';
	for j=1:length(status.vhintan_filtermap_values(i).channel_list),
		numstr = int2str(status.vhintan_filtermap_values(i).channel_list(j));
		if ~isempty(status.vhintan_thresholds_values),
			if any([status.vhintan_thresholds_values.channel]==status.vhintan_filtermap_values(i).channel_list(j)),
				str = [str numstr 'T, '];
			else,
				str = [str numstr ', '];
			end;
		else,
				str = [str numstr ', '];
		end;
	end;
	if ~isempty(str), str = str(1:end-2); end;
	labels{i} = str;
end;
