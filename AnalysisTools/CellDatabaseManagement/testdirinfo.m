function testdirinfo
%  TESTDIRINFO describes the 'testdirinfo.txt' file that describes the stimuli run in each test directory
%  
%  The file 'testdirinfo.txt' at the root level of the directory DS,
%  has the following structure. The first row has the category titles
%  'testdir' and 'types', separated by a tab. Then each row has a test
%  directory name followed by a tab and a comma-separated list of types.
%
%  This file is typically created by the user while the experimental data
%  is collected.
%  
%  The function that reads this file is ADD_TESTDIR_INFO.
%
%  As an example of the form:
%
%  testdir<tab>types
%  t00001<tab>PreDir1Hz, Dir1Hz1
%  t00002<tab>PreDir4Hz, Dir4Hz1
%  t00003<tab>PostDir1Hz, Dir1Hz2
%  t00004<tab>PostDir4Hz, Dir4Hz2
%
%  See also ADD_TESTDIR_INFO

