function [newcell,assoc]=spperiodicgenerticanalysis(ds,cell,cellname,display,testnamelist,paramevalstr,param2evalstr,analysisfunc, analysis2func, begstr, plotfunc,f0orf1)

%  SPGENERICANALYSIS - Analyze spike responses
%
%  [NEWSCELL,ASSOC]=SP2GENERICANALYSIS(DS,CELL,CELLNAME,DISPLAY,...
%       TESTNAMELIST, PARAMEVALSTR, PARAM2VALSTR, ANALYSISFUNC, ANALYSIS2FUNC, BEGSTRING, PLOTFUNC, F0_OR_F1)
%
%  (Docs not updated for 2-D)
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

assoc = struct('type','','owner','','data','','desc',''); assoc = assoc([]);

tests = {}; testresps = {}; stimid = []; stims = {}; resps = {};

for j=1:length(testnamelist),
	tas = findassociate(newcell, testnamelist{j},'','');
	if ~isempty(tas),
		s = findstr(upper(testnamelist{j}),' TEST');
		resname = [testnamelist{j}(1:s) 'resp'];
		res = findassociate(newcell, resname,'','');
        if isempty(res), cellname, s, 
        elseif ~isempty(res)&isfield(res.data,'f0curve')&(f0orf1==0),
            res.data.curve = res.data.f0curve{1};
            X = res.data.f0vals{1};
            res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
        elseif f0orf1==1&~isfield(res.data,'f1curve'),
            error(['F1 analysis requested but no F1 data for cell ' cellname ' for test ' testnamelist{j} '.']);
        elseif isfield(res.data,'f1curve')&(f0orf1==1),
            res.data.curve = res.data.f1curve{1};
            X = abs(res.data.f1vals{1});
            res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
        elseif isfield(res.data,'f2curve')&(f0orf1==2),
            res.data.curve = res.data.f2curve{1};
            X = abs(res.data.f2vals{1});
            res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
        elseif f0orf1==2&~isfield(res.data,'f2curve'),
            error(['F2 analysis requested but no F2 data for cell ' cellname ' for test ' testnamelist{j} '.']);
        end;
		tests = cat(2,tests,tas.data);
		testresps = cat(2,testresps,res.data);
	end;
end;
 % eliminate any duplicate directories
[tests,I] = unique(tests);
if ~isempty(testresps), testresps = testresps(I); end;
 % eliminate any empty responses
I = [];
for j=1:length(testresps), if ~isempty(testresps{j}), I(end+1)=j; end; end;
tests = tests(I); testresps = testresps(I);

for j=1:length(tests),
	g=load([getpathname(ds) tests{j} filesep 'stims.mat'],'saveScript','MTI2','-mat');
	s=stimscripttimestruct(g.saveScript,g.MTI2);
	stims = cat(2,stims,s);
	stimid(end+1) = FitzColorStimID(get(s.stimscript,1),10);
end;

if isempty(tests), return; end;

	%loop over all color id's, find maximum response, and analyze

stimidlist = unique(stimid);	
for dim = 1:2,
    for k = 1 : length(stimidlist),
        bestR = -Inf; bestRi = -1;
        poten = find(stimid==stimidlist(k));
        for i=1:length(poten),
            mx=max(testresps{poten(i)}.curve(2,:));
            if bestR<mx, bestR = mx; bestRi = poten(i); end;
        end;
        if bestRi>0,
            resp = testresps{bestRi};
            % find nonblank elements
            stimlist = [];
            for i=1:numStims(stims{bestRi}.stimscript),
                if ~isfield(getparameters(get(stims{bestRi}.stimscript,i)),'isblank'),
                    stimlist(end+1) = i;
                end;
            end;
            % replace curve(1,:) w/ parameter values
            myinds = []; mydims = [];
            if ~0|eqlen(resp.curve(1,:),stimlist),
                for i=stimlist,
                    myinds(end+1) = i;
                    if ~isempty(paramevalstr),
                        p = getparameters(get(stims{bestRi}.stimscript,i));
                        mydims(i,1) = eval(paramevalstr);
                        mydims(i,2) = eval(param2evalstr);
                        if dim==1, resp.curve(1,i) = eval(paramevalstr);
                        elseif dim==2, resp.curve(1,i) = eval(param2evalstr); end;
                    end;
                end;
            else, myinds = 1:length(resp.curve(1,:));
            end;
            [mx,mxi] = max(resp.curve(2,myinds));
            if dim==1,
                myinds2 = find(mydims(:,2)==mydims(mxi,2));
            elseif dim==2,
                myinds2 = find(mydims(:,1)==mydims(mxi,1));
            end;
            resp.curve = resp.curve(:,myinds(myinds2));
            resp.ind = resp.ind(myinds(myinds2));
            % now eliminate all items not in the best run of opposite dim

               
            if isfield(resp,'blankresp'),
                resp.spont = resp.blankresp; resp.spontind = resp.blankind;
            else, % just use the spontaneous values already present
            end;

            if dim==1, newassocs = eval([analysisfunc '(resp);']);
            elseif dim==2, newassocs = eval([analysis2func '(resp);']); end;
            
            K = find(allstimids==stimidlist(k));
            if ~isempty(begStrs{K}), skips = ' '; else, skips = ''; end;
            for j=1:length(newassocs),
                assoc(end+1) = newassocs(j);
                assoc(end).type = [begstr skips begStrs{K} ' ' assoc(end).type];
            end;
        end;
    end;
end;
for j=1:length(assoc), newcell = associate(newcell,assoc(j)); end;
if display, figure; eval(plotfunc); end;