function cell = performsingleunitgrating(ds, cell, cellname, testnamelist, parameterlist, plotit)
% PERFORMSINGLEUNITGRATING - Extract spike responses from a test directory and add them to the database
%
%  CELL=PERFORMSINGLEUNITGRATING(DS, CELL, CELLNAME, TESTNAMELIST, PARAMETERLIST, PLOTIT)
%
%  For the MEASUREDDATA object CELL with the name CELLNAME, this funciton loops through the
%  test names in TESTNAMELIST, extracts the grating responses that vary with parameter
%  PARAMETERLIST, and adds them back to the MEASUREDDATA object.  Optionally, the responses are
%  plotted if PLOTIT is 1.
%
%  All of the items in TESTNAMELIST should end with the word 'test'; for example,
%  TESTNAMELIST = {'CoarseDir test','FineDir test'}.  The responses will be added back to the MEASUREDDATA
%  object CELL with 'resp' as the associate type. In our example, these associates would be 'CoarseDir resp'
%  and 'FineDir resp'.
%  If the CELL does not have a field TESTNAMELIST{i}, then no action is taken and no warning is given.
%
%  PARAMETERLIST can either be a single string (e.g., 'angle') or a list of strings with a different entry
%  for each TESTNAMELIST item.  
%

for t=1:length(testnamelist),
	myassoc = findassociate(cell,testnamelist{t},'','');
	index = strfind(testnamelist{t},'test');
	testnamelist{t},
	newtype = testnamelist{t};
	newtype(index:index+3) = 'resp';
	if ~isempty(myassoc)
		if was_recorded(cell, myassoc.data),
			if strcmp(celloritem(parameterlist,t),'stimnumber'),
				stimnumfield = 'stimnumber';
				[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds,cell,cellname,myassoc.data,...
					celloritem(parameterlist,t),plotit,stimnumfield);
			else,
				[dummy,dummy,dummy,dummy,dummy,dummy,co]=singleunitgrating2(ds,cell,cellname,myassoc.data,...
					celloritem(parameterlist,t),plotit);
			end;
			cell=associate(cell,struct('type',newtype,'owner','performsingleunitgrating',...
				'data',make_resp_from_output(co),'desc',''));
		end;
	end;
end;
