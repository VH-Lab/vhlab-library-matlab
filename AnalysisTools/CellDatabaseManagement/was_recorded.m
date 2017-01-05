function b = was_recorded(cell, testdir)
% WAS_RECORDED - Looks to see if a cell was recorded in a given directory
%  
%  B = WAS_RECORDED(CELL, TESTDIR)
%
%  Examines the 'vhlv_loadcelldata' associate to see if the cell was
%  recorded in a given test directory.  If TESTDIR is
%  a tXXXXX directory name, then a straight lookup is performed.
%  If TESTDIR is any other string, then we will look to see if
%  the directory that corresponds to [TESTDIR ' test'] was recorded
%  and return 1 in that case. Otherwise, 0 is returned.
%
%  If there is no 'vhlv_loadcelldata' associate, then the program returns
%  1, assuming the cell was recorded (or that it would be filtered
%  out by other means if it was not).

b = 1; % assume it is unless we have evidence otherwise

testdirname = '';

A = findassociate(cell,'vhlv_loadcelldata','','');

if isempty(A), return; end;

 % check T

istestdir=0;

if length(testdir)==6,
	if testdir(1)=='t'|testdir(1)=='T',
		if all(testdir(2:6)>=double('0') & testdir(2:6)<=double('9')),
			istestdir = 1;
		end
	end
end

if istestdir,
	testdirname = testdir;
else,
	asc = findassociate(cell,[testdir ' test'],'','');
	if ~isempty(asc),
		testdirname = asc.data;
	end;
end;

if ~isempty(testdirname),
	a_ind = 1;
	for j=1:length(A.data),
		if isfield(A.data(j),'clusterinfo')
            if isfield(A.data(j).clusterinfo,'number'),
    			a_ind = j;
            end;
		end;
	end;
	if isfield(A.data,'clusterinfo')
		if isfield(A.data(a_ind).clusterinfo,'EpochStart'),
			strs{1} = A.data(a_ind).clusterinfo.EpochStart;
			strs{2} = A.data(a_ind).clusterinfo.EpochStop;
			if ~(strcmp(strs{1},testdirname) | strcmp(strs{2},testdirname)) % if it might be intermediate
				strs{3} = testdirname;
				[Y,I] =sort(strs);
				if I(2)~=3, b = 0; end;
			end;
        end
	end;
end;


