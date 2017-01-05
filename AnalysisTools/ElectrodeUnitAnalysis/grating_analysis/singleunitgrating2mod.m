function [mycell,groups, pref, params,pc,s,co] = singleunitgrating2(ds, mycell, mycellname, dirname, paramname, display, stimnumfield)

params = {};
currValues = [];
groups = [];

if ischar(dirname),
    [dirname paramname ],
    s = getstimscripttimestruct(ds,dirname);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
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
	if isfield(p,'chromhigh'), if eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if isfield(p,'isblank'), blankid = i; break; end;
    if nargin>=7,
        if ~isempty(stimnumfield),
            p = setfield(p,stimnumfield,i);
            s.stimscript = set(s.stimscript,eval([class(get(s.stimscript,i)) '(p)']),i);
        end;
    end;
    pp = getparameters(p.ps_mask);
    p.tFrequency = pp.tFrequency;
    p = setfield(p, [paramname 'mod'], getfield(pp,paramname));
    s.stimscript = set(s.stimscript,eval([class(get(s.stimscript,i)) '(p)']),i);
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
else, inp.paramnames = {[paramname 'mod']};
end;
inp.spikes = mycell;
inp.st = s;
inp.title = [mycellname ' ' dirname];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = [];
end;

inp,

pc = periodic_curve(inp,'default',where);
p = getparameters(pc);
p.graphParams(4).whattoplot = 6;
p.res = 0.050;
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
