function fitzlab_stevephys2vhlab(dirname)
% FITZLAB_STEVEPHYS2VHLAB - convert from Steve's electrophys in Fitzpatrick lab at Duke to his own lab's standards
%
% FITZLAB_STEVEPhyS2VHLAB(DIRNAME) 
%
% Adds a 'vhspike2_channelgroupings.txt' file to all subdirectories of an
% an experiment in directory DIRNAME.
%
% This is here to convert the data from Van Hooser et al. 2013
%

ds = dirstruct(dirname);

t = getalltests(ds);

for i=1:numel(t),
	nr = getnamerefs(ds,t{i});
	if numel(nr) > 1,
		error(['do not know what to, unexpected.']);
	else,
		vhs = struct('name',nr(1).name,'ref',nr(1).ref,'channel_list',[11 12 13 14]);
		if ~exist([getpathname(ds) filesep t{i} filesep 'vhspike2_channelgrouping.txt']),
			saveStructArray([getpathname(ds) filesep t{i} filesep 'vhspike2_channelgrouping.txt'],vhs);
		end;
	end;
end; 

