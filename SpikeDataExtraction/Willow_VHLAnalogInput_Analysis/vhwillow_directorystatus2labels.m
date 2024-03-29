function labels = vhwillow_directorystatus2labels(dirnames, status)
% VHWILLOW_DIRECTORYSTATUS2LABELS Converts directory status to a label
%
%   LABELS = VHWILLOW_DIRECTORYSTATUS2LABELS(DIRNAMES, STATUS)
%
%   Converts directory names DIRNAMES (a cell array of names) with
%   accommpanying directory status STATS (see help
%   VHWILLOW_GETDIRECTORYSTATUS) to strings that can
%   appear in a menu or other places.
%
%   t or T - indicates thresholding has been done (t is incomplete, T is complete)
%   e or E - indicates spike extraction has been done (e is incomplete, E is complete)
%   c or C - indicates that spike clustering has been done (c is incomplete, C is complete)

labels = {};

properties = {'vhwillow_filtermap','vhwillow_thresholds',...
	'vhwillow_channelgrouping','willow_spikewaveforms_N','willow_spiketimes_N','willow_spiketimes_N_M'};

active_properties = [2 4 6];

letters = {'f_F', 't_T', 'g_G', 'e_E', '   ', 'c_C'};

for i=1:length(dirnames)
	extrastr = '';
	for j=active_properties,
		if isfield(status(i),properties{j}),
			value = getfield(status(i),properties{j});
			extrastr = [extrastr letters{j}(value+2)];
		end;
	end;
	labels{i} = [dirnames{i} ' | ' extrastr];
end;
