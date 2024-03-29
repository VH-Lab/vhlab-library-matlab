function [newcell,assoc]=spperiodicgenerticanalysis(ds,cell,cellname,display,testnamelist,paramevalstr,analysisfunc, begstr, plotfunc,f0orf1)

%  SPGENERICANALYSIS - Analyze spike responses
%
%  [NEWSCELL,ASSOC]=SPGENERICANALYSIS(DS,CELL,CELLNAME,DISPLAY,...
%       TESTNAMELIST, PARAMEVALSTR, ANALYSISFUNC, BEGSTRING, PLOTFUNC, F0_OR_F1)
%
%  Analyzes spike recordings using a provided fitting function.
%  DS is a valid DIRSTRUCT experiment record.  CELL is a list of
%  MEASUREDDATA objects, CELLNAME is a string list containing the names
%  of the cells, and DISPLAY is 0/1 depending upon whether or not output
%  should be displayed graphically.
%  
%  TESTNAMELIST is a cell list of associate test names  to pool.
%  For example: {'Best orientation test','orientation test'}.  The
%  analysis will loop over the responses recorded during these tests
%  and, for each known color, pick the test with the best response.
% 
%  PARAMVALSTR is a string to be evaluated to determine the parameter
%  value for each entry in the response curve.  The stim's parameters
%  are provided as a variable p.  For example, if the proper response
%  curve entry for each stimulus is the 'sFrequency' value, then set
%  PARAMVALSTR = 'p.sFrequency;'.  Note that is is possible to perform
%  mathematical operations using this string:  if the value should be
%  5*rect([3 4]), then set PARAMVALSTR = '5 * p.rect([3 4]);'
%
%  ANALYSISFUNC is a string with the analysis function to call.  The
%  analysis function should return associates that can be added to the
%  CELL object.  The associate names are determined by adding
%  BEGSTRING to the associates returned from ANALYSISFUNC.
%
%  F0_OR_F1_OR_F2 should be 0 if the mean firing rate is to be used, 1 if
%    the F1 component is to be analyzed, or 2 is F2 is to be analyzed.
%
%  PLOTSTR is evaluated to display the results if DISPLAY is 1.
%  (e.g., 'plottpresponse(newcell,cellname,'Spatial frequency',1,1)')

[allstimids,begStrs,plotcolors,longnames] = FitzColorID;

if nargin==0, return; end;

newcell = cell;

% remove any previous values we returned
assoclist = eval(analysisfunc);
for I=1:length(assoclist),
	for k=1:length(begStrs),
		[as,i] = findassociate(newcell,[begstr ' ' begStrs{k} ' ' assoclist{I}],'',[]);
		if ~isempty(as), newcell = disassociate(newcell,i); end;
	end;
end;

assoc = struct('type','','owner','','data','','desc','');
assoc = assoc([]);

tests = {}; testresps = {}; stimid = []; stims = {}; resps = {};

[testresps, tests, testparams] = testnamelist2respstruct(cell, testnamelist, f0orf1);

if isempty(tests), return; end;

if strcmp(tests{1},'N/A'), % if we don't have a list to search through, just go
	newassocs = eval([analysisfunc '(testresps{1});']);
	for j=1:length(newassocs),
		assoc(end+1) = newassocs(j);
		assoc(end).type = [begstr ' ' assoc(end).type];
	end;
	for j=1:length(assoc), newcell = associate(newcell,assoc(j)); end;
	if display, figure; eval(plotfunc); end;

	return;
end;

for j=1:length(tests),
	g=load([getpathname(ds) tests{j} filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);
	stims = cat(2,stims,s);
	stimid(end+1) = FitzColorStimID(get(s.stimscript,1),10);
end;

	%loop over all color id's, find maximum response, and analyze

stimidlist = unique(stimid);	

for k = 1 : length(stimidlist),
	bestR = -Inf; bestRi = -1;
	poten = find(stimid==stimidlist(k));
	for i=1:length(poten),
		mx=max(testresps{poten(i)}.curve(2,:));
		if bestR<mx, bestR = mx; bestRi = poten(i); end;
	end;
	if bestRi>0,
		resp = testresps{bestRi};
		paramshere = testparams{bestRi};
        	% find nonblank elements
	        stimlist = [];
		for i=1:numStims(stims{bestRi}.stimscript),
			if ~isfield(getparameters(get(stims{bestRi}.stimscript,i)),'isblank'),
				stimlist(end+1) = i;
			end;
		end;
		% if necessary, replace curve(1,:) w/ parameter values
		myinds = [];
		if eqlen(resp.curve(1,:),stimlist),
			for i=stimlist,
				myinds(end+1) = i;
				if ~isempty(paramevalstr),
					p = getparameters(get(stims{bestRi}.stimscript,i));
					resp.curve(1,i) = eval(paramevalstr);
				end;
			end;
		else,
			myinds = 1:length(resp.curve(1,:));
		end;
		resp.curve = resp.curve(:,myinds);
		resp.ind = resp.ind(myinds);
		if isfield(resp,'blankresp'),
			resp.spont = resp.blankresp; resp.spontind = resp.blankind;
		else, % just use the spontaneous values already present
		end;

		if ~isempty(paramshere),
				newassocs = eval([analysisfunc '(resp, paramshere);']);
		else,
			newassocs = eval([analysisfunc '(resp);']);
		end

		K = find(allstimids==stimidlist(k));
		if ~isempty(begStrs{K}), skips = ' '; else, skips = ''; end;
		for j=1:length(newassocs),
			assoc(end+1) = newassocs(j);
			assoc(end).type = [begstr skips begStrs{K} ' ' assoc(end).type];
		end;
	end;
end;

for j=1:length(assoc), newcell = associate(newcell,assoc(j)); end;
if display, figure; eval(plotfunc); end;

