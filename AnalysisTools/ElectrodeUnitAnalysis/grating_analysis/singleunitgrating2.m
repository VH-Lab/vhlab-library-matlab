function [mycell,groups, pref, params,pc,s,co] = singleunitgrating2(ds, mycell, mycellname, dirname, paramname, display, stimnumfield)
% SINGLEUNITGRATING2 - Analyze spike responses to a grating stimulus
%
%  [MYCELL, GROUPS, PREF, PARAMS, PC, S, CO] = SINGLEUNITGRATING2(...
%     DS, MYCELL, MYCELLNAME, DIRNAME, PARAMNAME, DISPLAY, [STIMNUMFIELD])
%
%  Inputs:
%     DS - Directory structure (dirstruct object) for the experiment
%     MYCELL - A cell (spikedata object)
%     MYCELLNAME - The string name of the cell in CELL_NAME_REF_CLS_YEAR_MN_DY,
%          where NAME is the name of the corresponding name/ref record that corresponds
%          to the electrode, REF is a 4 digit number that specifies the reference number
%          of the electrode, CLS is a 3 digit number that specifies the cluster number of 
%          the unit on the electrode, YEAR is the 4 digit year, MN is 2 digit month, and
%          DY is the 2 digit day of the experiment.
%    DIRNAME - the directory name to be analyzed
%    PARAMNAME - the parameter of the grating stimulus to be analyzed, such as 
%          'angle', or 'sFrequency', or 'tFrequency'. See help periodicstim for a list.
%    DISPLAY - 0/1 should we display the result in a window?
%    STIMNUMFIELD - (Optional argument, default 0 if not present) 0 or string. Should we analyze
%          the stimuli by stimulus number (1, 2, ...) instead of the parameter specified in
%          PARAMNAME?  This is useful if more than 1 parameter has been varied and one wants
%          to plot the data on a single axis.  If the argument is not 0, it should be the
%          name of the field name that will contain the stimulus number information. 
%          (For example: 'stimnumber').
%
%  Outputs:  (These outputs are generally single quantities, except in the event that the
%             script has multiple iontophoretic current pulses, in which case they are 
%             cell lists, one entry for each iontophoretic current pulse value.)
%     MYCELL - The cell (spikedata object), with any new associates generated here attached
%     GROUPS - The values of the iontophoretic pulses (default [] if there are no pulses)
%     PREF - The parameter value with the maximum response. If the greatest F1 response is
%            greater than the greatest F0 response, then the parameter with the maximum
%            F1 value is reported.
%     PARAMS - a cell list of parameter structures for all stimuli in the stimscript
%     PC - The periodic_curve object that used in the analysis.
%     S - The stimscripttimestruct that contains the stimscript and the mti record for the
%            directory DIRNAME.
%     CO - The computed outputs from the periodic_curve object PC. If one is saving values to
%            disk, it is recommended that one save only CO, as the PC object has a lot of data
%            and will consume a lot of disk space, whereas the computed outputs are all contained in
%            the structure CO.
%     
%
%  See also:  DIRSTRUCT, SPIKEDATA, PERIODIC_CURVE, STIMSCRIPT, CELLNAME2NAMEREF,
%             STIMSCRIPTTIMESTRUCT, STIMULUS/GETPARAMETERS


if nargin>=7,
        if stimnumfield==0,
                stimnumfield = [];
        end;
end;


params = {};
currValues = [];
groups = [];

if ischar(dirname),
    [dirname paramname ],
    s = getstimscripttimestruct(ds,dirname);
    %s = modifyflanktuningstimforanalysis(s);
    [s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
    s.mti = s.mti(inds_nottotrim);
else,
    s = dirname{1};
    dirname = dirname{2};
    %keyboard;
end;




list = sswhatvaries(s.stimscript);
if ~isempty(intersect(list,'iontophor_curr')),
    % divide into groups
    pc = {}; params = {}; s_ = {}; co = {}; pref = {};
        % first get list of values
    for i=1:numStims(s.stimscript),
        currValues(i) = getfield(getparameters(get(s.stimscript,i)),'iontophor_curr');
    end;
    groups = unique(currValues);
    do = getDisplayOrder(s.stimscript);
    for g=1:length(groups),
        % make a new script only using stims from the group
        newscript = stimscript(0);
        doInds = [];
        doVals = [];
        for i=1:numStims(s.stimscript),
            if currValues(i)==groups(g),
                para = getparameters(get(s.stimscript,i));
                para.length = para.rect(3)-para.rect(1);
                stimclass = class(get(s.stimscript,i));
                eval(['newstim = ' stimclass '(para);']);
                newscript = append(newscript,newstim);
                doInds = [doInds find(do==i)];
                doVals = [doVals numStims(newscript)*ones(size(find(do==i)))];
            end;
        end;
        [doInds,scramble] = sort(doInds);
        sn.stimscript = setDisplayMethod(newscript,2,doVals(scramble));
        sn.mti = s.mti(doInds);
        if nargin>7,
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating2(ds, mycell, mycellname, {sn dirname}, paramname, display, stimnumfield);
        else,
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating2(ds, mycell, mycellname, {sn dirname}, paramname, display);
        end;
        pref{g} = prefout;
        params{g} = paramsout;
        pc{g} = pcout;
        s_{g} = s_out;
        co{g} = coout;
    end;
    s = s_;
    i = findclosest(groups,0);
    pref = pref{i};
    return;
end;
 % identify the blank stim, or add parameters
blankid = -1;
for i=1:numStims(s.stimscript),
	p=getparameters(get(s.stimscript,i));
	params{i} = p;
	if isfield(p,'isblank'), blankid = i; break; end;
	if isfield(p,'chromhigh'), if 0&eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if nargin>=7,
		if ~isempty(stimnumfield),
			p = setfield(p,stimnumfield,i);
			s.stimscript = set(s.stimscript,eval([class(get(s.stimscript,i)) '(p)']),i);
		end;
	end;
end;

if blankid>1,
	inp.blankid = i;
end;

if 0, % optionally, remove blank
	do = getDisplayOrder(s.stimscript);
	dogood = find(do~=blankid);
	donew = do(dogood);
	s.stimscript = remove(s.stimscript,blankid);
	s.stimscript = setDisplayMethod(s.stimscript,2,donew);
	s.mti = s.mti(dogood);
    clear inp;
end;

if iscell(paramname), inp.paramnames = paramname;
else, inp.paramnames = {paramname};
end;
inp.spikes = mycell;
inp.st = s;
inp.title = [mycellname ' ' dirname];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = [];
end;

%inp,inp.st,

pc = periodic_curve(inp,'default',where);
p = getparameters(pc);
p.graphParams(4).whattoplot = 6;
p.res = 0.001;
pc = setparameters(pc,p);
co = getoutput(pc);

[mf0,if0]=max(co.f0curve{1}(2,:));
[mf1,if1]=max(co.f1curve{1}(2,:));
maxgrating = [mf0 mf1];
f1f0=mf1/(mf0+0.00001);
otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];

if mf1>mf0, pref = otpref(2); else, pref = otpref(1); end;

f0curve = [co.f0curve{1}];
f1curve = [co.f1curve{1}];

  % now add extra analysis here
