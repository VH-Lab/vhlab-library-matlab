function c = nameref2channel(dirname, name, ref)
% NAMEREF2CHANNEL - Find the corresponding vhintananaloginput.vld channel for a name/ref
%
%  C=NAMEREF2CHANNEL(DIRNAME,NAME,REF)
%
%  Returns the channel (or channels, in the case of a tetrode or N-trode) that correspond to
%  the NAME/REF pair given in directory DIRNAME.
%
%  This information is read out from the 'reference.txt' file and the 'vhintan_channelgrouping.txt' file.
%

chan_groupings = loadStructArray([dirname filesep 'vhintan_channelgrouping.txt']);

c = [];
match = 0;

for i=1:length(chan_groupings),
	if strcmp(chan_groupings(i).name,name) & chan_groupings(i).ref==ref,
		c = chan_groupings(i).channel_list;
		return;
	end;
end;

if match==0,
	error(['Could not locate channel match for name/ref ' name '| ' int2str(ref) ' in ' dirname '.']);
end;
