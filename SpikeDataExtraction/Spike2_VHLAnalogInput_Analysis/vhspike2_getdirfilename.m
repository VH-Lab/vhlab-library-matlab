function name = vhspike2_getdirfilename(dirname)
% VHSPIKE2_GETDIRFILENAME - Get the Intan filename for a given directory
%
%   NAME = VHSPIKE2_GETDIRFILENAME(DIRNAME)
%
%   Examines the directory DIRNAME and returns the name of the 
%   *.rhd file in that directory. If there is more than one *.SMR in DIRNAME
%   then an error is produced.
%
%   NAME is the full path to the file (including DIRNAME).
%

d = dir([dirname filesep '*.smr']);

if length(d)~=1,
	error(['Looked in ' dirname ' for unique *.smr file but found ' int2str(length(d)) ' files.']); 
else,
	name = [dirname filesep d(1).name];
end;

