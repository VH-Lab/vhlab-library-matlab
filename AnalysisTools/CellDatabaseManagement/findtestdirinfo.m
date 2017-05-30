function [dirname] = findtestdirinfo(ds, tag)
% FINDTESTDIRINFO - Find a test directory record from testdirinfo.txt file
%
%  DIRNAME = FINDTESTDIRINFO(DS, TAG)
%
%  Examines the directory managed by the DIRSTRUCT object DS and attempts to find
%  a match for the directory label TAG.
%
%  TAG should be a directory type (it should not have the word ' test' appended) 
%  to look for.  See TESTDIRINFO for documentation on the format of that file.
%
%  If no match is found, DIRNAME is empty.
%  
% 
% See also: TESTDIRINFO, ADD_TESTDIR_INFO


dirname = [];

assoc = add_testdir_info(ds);

for i=1:length(assoc),
	if strcmp(assoc(i).type,[tag ' test']),
		dirname = assoc(i).data;
		break;
	end;
end;


