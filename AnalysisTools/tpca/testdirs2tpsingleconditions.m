function testdirs2tpsingleconditions(prefix, expernames, testdirs, varargin)
% TESTDIRS2TPSINGLECONDITIONS - Compute 2-photon single condition images for a set of test directories
%
%  TESTDIRS2SINGLECONDITIONS(PREFIX, EXPERNAMES, TESTDIRS)
%
%  Given EXPERNAMES, a cell list of directories containing experiemnts, located in the
%  directory PREFIX, this function loads the file TESTDIRINFO.TXT, and creates single
%  condition images on any directory whose type matches those in the cell array TESTDIRS.
%
%  If TESTDIRS is empty, then single condition images are computed for all
%  valid directories (that is, all directories that have a REFERENCE.TXT file).
%
%  The behavior of the function can also be modified by name/value pairs:
%  Parameter name (default)         | Description
%  -----------------------------------------------------------------------
%  channel (2)                      | The channel over which the single
%                                   |   condition images are computed
%  T0_T1 ([])                       | The input argument showing the
%                                   |    interval of time to use for computation
%
%  See also: TESTDIRINFO


if nargin<3,
	testdirs = {};
end;

channel = 2;
t0_t1 = [];

assign(varargin{:});

for i=1:length(expernames),

	ds = dirstruct([prefix filesep expernames{i}]);

	try,
		tdi = loadStructArray([getpathname(ds) filesep 'testdirinfo.txt']);
	catch,
		tdi = [];
		warning(['No testdirinfo.txt file in ' getpathname(ds) ', skipping...']);
	end;

	if ~isempty(tdi),
		if isempty(testdirs), % do all
			matches = 1:length(tdi);
		else,
			matches = [];
			for j=1:length(tdi),
				types = string2cell(tdi(j).types,',');
				if ~isempty(intersect(testdirs, types)),
					matches(end+1) = j;
				end;  % if 
			end;  % for
		end; % if 
		for j=1:length(matches),
			disp(['Computing single condition: ' getpathname(ds) filesep tdi(matches(j)).testdir '...']);
			clear result indimages;
			[result,indimages]=tpsinglecondition([getpathname(ds) filesep tdi(matches(j)).testdir],channel,[],t0_t1,[],0,'');
			fname = [getpathname(ds) filesep tdi(matches(j)).testdir filesep 'singleconditions_' int2str(channel) '.mat'];
			save(fname,'result','indimages','-mat');
		end;  % for j
	end;  % if ~isempty(tdi)
end;  % for
