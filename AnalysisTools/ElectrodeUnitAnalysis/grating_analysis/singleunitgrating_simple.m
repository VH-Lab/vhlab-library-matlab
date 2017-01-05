function [mycell,groups, pref, params,pc,s,co] = singleunitgrating_simple(ds, mycell, mycellname, dirname, paramname, display, stimnumfield)
% SINGLEUNITGRATING_SIMPLE - Analyze spike responses to a grating stimulus
%
%  [MYCELL, GROUPS, PREF, PARAMS, DUMMY, S, CO] = SINGLEUNITGRATING_SIMPLE(...
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
%          'angle', or 'sFrequency'. See help periodicstim for a list.
%    DISPLAY - 0/1 should we display the result in a window?
%    STIMNUMFIELD - (Optional argument, default 0 if not present) 0/1 Should we analyze
%          the stimuli by stimulus number (1, 2, ...) instead of the parameter specified in
%          PARAMNAME?  This is useful if more than 1 parameter has been varied and one wants
%          to plot the data on a single axis.
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
%     DUMMY - An empty variable; here so the output argument form is the same as SINGLEUNITGRATING2
%     S - The stimscripttimestruct that contains the stimscript and the mti record for the
%            directory DIRNAME.
%     CO - The computed outputs 
%     
%
%  See also:  DIRSTRUCT, SPIKEDATA, PERIODIC_CURVE, STIMSCRIPT, CELLNAME2NAMEREF,
%             STIMSCRIPTTIMESTRUCT, STIMULUS/GETPARAMETERS


params = {};
currValues = [];
groups = [];

if nargin>=7,
	if stimnumfield==0,
		stimnumfield = [];
	end;
end;

if ischar(dirname),
    [dirname paramname ],
    s = getstimscripttimestruct(ds,dirname);
    [s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
    s.mti = s.mti(inds_nottotrim);
else,
    s = dirname{1};
    dirname = dirname{2};
    %keyboard;
end;

list = sswhatvaries(s.stimscript),
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
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating_simple(ds, mycell, mycellname, {sn dirname}, paramname, display, stimnumfield);
        else,
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating_simple(ds, mycell, mycellname, {sn dirname}, paramname, display);
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
myTf = 4;

for i=1:numStims(s.stimscript),
	p=getparameters(get(s.stimscript,i));
	params{i} = p;
	if isfield(p,'chromhigh'), if eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if isfield(p,'isblank'), blankid = i; break; end;
	if isfield(p,'tFrequency'),
		myTf = p.tFrequency;
	end;
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


[stimtimes_on,stimtimes_off] = mti2stimonoff(s.mti,1);
stim_values = stimscript2stimvalues(s.stimscript,paramname);
spiketimes = get_data(mycell,[stimtimes_on(1) stimtimes_off(end)]);

rc = spikeresponse(stimtimes_on,stimtimes_off,stim_values,spiketimes);
rc_f1 = spikeresponse_tf(stimtimes_on,stimtimes_off,stim_values,spiketimes,0.001,myTf);

if display,
	figure;
	subplot(2,2,1);
	h = myerrorbar(rc.curve(1,:),rc.curve(2,:),rc.curve(4,:));
	set(h,'linewidth',2,'color',[0 0 1]);
	box off;
	xlabel(paramname);
	ylabel('Spike rate (Hz)');
	subplot(2,2,2);
	h = myerrorbar(rc_f1.curve(1,:),abs(rc_f1.curve(2,:)),rc_f1.curve(4,:));
	set(h,'linewidth',2,'color',[0 0 1]);
	xlabel(paramname);
	ylabel('Modulation rate (Hz)');
	box off;
end;

co.f0vals{1} = rc.inds;
co.f0curve{1} = rc.curve;
co.f0blank = rc.blank;
co.f0blankinds = rc.blankinds;

co.f1vals{1} = rc_f1.inds;
co.f1curve{1} = rc_f1.curve;
co.f1blank = rc_f1.blank;
co.f1blankinds = rc_f1.blankinds;

pc = [];

[mf0,if0]=max(co.f0curve{1}(2,:));
[mf1,if1]=max(co.f1curve{1}(2,:));
maxgrating = [mf0 mf1];
f1f0=mf1/(mf0+0.00001);
otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];

if mf1>mf0, pref = otpref(2); else, pref = otpref(1); end;

return;



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

inp,inp.st,

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
