function cell = performspperiodicgenericanalysis(ds, cell, cellname, display, testnamelist, ...
	paramvalstr, analysisfunc, plotfunc, f0f1f2code);
% PERFORMSP2PERIODICGENERICANALYSIS - Perform F0/F1/F2 fitting for a list of directory types
%
%  CELL = PERFORMSP2PERIODICGENERICANALYSIS(DS, CELL, CELLNAME, DISPLAY, TESTNAMELIST, ...
%     PARAMVALSTR(*), ANALYSISFUNC(*), PLOTFUNC(*), F0F1F2CODE)
%
%  Perform fitting for a list of directory types.
% 
%  Input arguments
%  DS - Dirstruct for the experimental data
%  CELL - The cell to be examined
%  CELLNAME - The cell's name
%  DISPLAY - 0/1 should we display the results with the PLOTFUNC?
%  TESTNAMELIST - A list of test names to analyze, such as 'CoarseDir'; the function will look
%     for an associate called 'TESTNAMELIST{i} resp' to extract the responses for each record
%     in the list.
%  PARAMVALSTR - The stimulus parameter to be examined; such as 'p.angle'
%  ANALYSISFUNC - The analysis function to call (e.g., 'otanalysis_compute')
%  PLOTFUNC - The plot function to use to plot the data (optional, use empty for none)
%  F0F1F2CODE is 1 for F0, 2 for F1, 4 for F4; provide the sum of these for a combination
%      (for example, 3 is F0 and F1)
%
%  (*) Input arguments denoted by an astrix can be provided as either a cell list that
%  is the same size as TESTNAMELIST, so that each TESTNAMELIST item has a different parameter,
%  or these arguments can be provided as a string, and the same value will apply for all TESTNAMELIST
%  items.
% 

bits = [1 2 3];
str = {'SP F0','SP F1','SP F2'}; 
f_code = [0 1 2];

for t=1:length(testnamelist),
	beginning_string = testnamelist{t},
	index = strfind(beginning_string,' test');
	beginning_string = beginning_string(1:index(end)-1);
	for b=1:length(bits),
		if bitget(f0f1f2code, bits(b)),
			cell=spperiodicgenericanalysis(ds,cell,cellname,display,{testnamelist{t}},...
				celloritem(paramvalstr,t),celloritem(analysisfunc,t),...
				[str{b} ' ' beginning_string], celloritem(plotfunc,t), f_code(b));
		end;	
	end;
end;

