function name = vhwillow_getdirfilename(dirname)
% VHWILLOW_GETDIRFILENAME - Get the Willow filename for a given directory
%
%   NAME = VHTAN_GETDIRFILENAME(DIRNAME)
%
%   Examines the directory DIRNAME and returns the name of the 
%   *.h5 file in that directory. If there is more than one *.h5 in DIRNAME
%   then an error is produced.
%
%   NAME is the full path to the file (including DIRNAME).
%

d = dir([dirname filesep '*.h5']);

if length(d)~=1,
	error(['Looked in ' dirname ' for unique *.h5 file but found ' int2str(length(d)) ' files.']); 
else,
	name = [dirname filesep d(1).name];
end;

