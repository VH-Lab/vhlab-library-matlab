function [assoc,cells] = add_testdir_info(ds, cells, cellnames)
% ADD_TESTDIR_INFO - Add test directory info as associates to cells
%
%  [ASSOC,CELLS] = ADD_TESTDIR_INFO(DS, [CELLS])
%
%  Looks for the file 'testdirinfo.txt' at the root level of
%  the directory described by DIRSTRUCT DS, and uses that information
%  to build a list of ASSOCIATE structures.
%
%  It looks for the file 'testdirinfo.txt' at the root level of the
%  directory DS, with the following structure. The first row has the
%  category titles 'testdir' and 'types', separated by a tab. Then each
%  row has a test directory name followed by a tab and a comma-separated
%  list of types.
%
%  As an example:
%
%  testdir<tab>types
%  t00001<tab>PreDir1Hz, Dir1Hz1
%  t00002<tab>PreDir4Hz, Dir4Hz1
%  t00003<tab>PostDir1Hz, Dir1Hz2
%  t00004<tab>PostDir4Hz, Dir4Hz2
%
%  This information is converted into a set of ASSOCIATES ASSOC with type 'TYPENAME test',
%  for example: 'PreDir1Hz test', with the 'data' field 't00001'.
%
%  These associates are then associated with each MEASUREDDATA object CELL in 
%  the list, and the output is returned.
%
%  See also: ASSOCIATE, FINDASSOCIATE

pathn = getpathname(ds);

testdirinfo = loadStructArray([pathn filesep 'testdirinfo.txt']);

types = string2cell(testdirinfo(1).types,',');

for j=1:length(types),
    types{j} = [types{j} ' test'];
end;
assoc = string2associates(testdirinfo(1).testdir,types);

for i=2:length(testdirinfo),
	types = string2cell(testdirinfo(i).types,',');
	for j=1:length(types),
        types{j} = [types{j} ' test'];
    end;
	assoc = cat(2,assoc,string2associates(testdirinfo(i).testdir,types));
end;

if nargin>1,
    if nargin<3,
        	cells=associate_all(cells,assoc);
    else,
        % now scan to make sure that each cell was recorded for that directory
        for i=1:length(cells),
            [nameref] = cellname2nameref(cellnames{i});
            t = gettests(ds,nameref.name,nameref.ref);
            for j=1:length(assoc),
                if ismember(assoc(j).data,t),
                    cells{i} = associate(cells{i},assoc(j));
                end;
            end;
        end;
    end;
else,
	cells = []; % make sure not to leave output argument hanging
end;
