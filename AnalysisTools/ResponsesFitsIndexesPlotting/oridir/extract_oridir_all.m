function output = extract_oridir_all(cells,cellnames,prefix,testnamelist)
% EXTRACT_ORIDIR_ALL - Extract orientation and direction index information for cells studied across time
%
%  OUTPUT = EXTRACT_ORIDIR_ALL(CELLS,CELLNAMES,PREFIX,TESTNAMELIST)
%
%  Extracts orientation and direction index information for a set of cells studied
%  across time.
%
%  CELLS and CELLNAMES should be a list of MEASUREDDATA objects (CELLS) and a cell
%  array of strings (CELLNAMES), such as that returned from READCELLSFROMEXPERIMENTLIST
%  or LOADCELLLIST.
%
%  PREFIX should be the prefix of the associate (e.g., 'SP F0' for spiking activity).
%
%  TESTNAMELIST is the list of possible testnames to look for: for example, 'Dir2Hz', 'Dir4Hz', etc.
%  The function will look for the presence of one of these tests with a 1, 2, appended: for example
%  'Dir2Hz1','Dir2Hz2', etc. If more than one such series is available, this function will choose the one
%  that is first in TESTNAMELIST.
%
%  At this time the function searches for occurances up to 10 repeats. 
%
%  See also: READCELLSFROMEXPERIMENTLIST, LOADCELLLIST, EXTRACT_ORIDIR_TEST
%

max_repeats = 10;

output = struct('testname','','indexes','');
output = output([]);

for i=1:length(cells),

	disp(['Examining cell ' int2str(i) ' of ' int2str(length(cells)) '.']);
	% step 1, figure out the test name to use

	newoutput.testname = '';
	for t=1:length(testnamelist),
		if ~isempty(findassociate(cells{i},[testnamelist{t} int2str(1) ' test'],'','')),
			newoutput.testname = testnamelist{t};
			break;
		end;
	end;

	if ~isempty(newoutput.testname),
		newoutput.indexes = struct([]);
		for n=1:max_repeats, 
			z=findassociate(cells{i},[newoutput.testname int2str(n) ' test'],'','');
			if ~isempty(z),
				if n==1,
					indexes_here = extract_oridir_test(cells{i},prefix,[newoutput.testname int2str(n)]);
					newoutput.indexes = indexes_here;
				else,
					issimple = newoutput.indexes(1).f1f0>=1;
					indexes_here = extract_oridir_test(cells{i},prefix,[newoutput.testname int2str(n)],...
						'Ach', 1-issimple );
					newoutput.indexes(end+1) = indexes_here;
				end;
			end;
		end;
	end;

	output(end+1) = newoutput;
end;


