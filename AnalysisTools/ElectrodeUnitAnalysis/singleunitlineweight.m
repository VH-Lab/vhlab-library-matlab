function [tc,s,co] = singleunitlineweight(ds, mycell, mycellname, dirname, paramname, display)

params = [];
assocs = [];

s = getstimscripttimestruct(ds,dirname);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);

 % trim the blank stim
blankid = -1;
blankid2 = -1;
paramval = [];
for i=1:numStims(s.stimscript),
	p=getparameters(get(s.stimscript,i)),
	if isfield(p,'chromhigh'), if eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if isfield(p,'isblank')&blankid==-1, blankid = i; end;
	if isfield(p,'isblank')&blankid~=-1, blankid2 = i; end;
	if isfield(p,paramname),
		pv = getfield(p,paramname);
		if isempty(intersect(paramval,pv)),
			paramval(end+1) = pv;
		else,
			pv = pv + max(paramval) + 2*mean(diff(paramval));
		end;
		p.dummy = pv;
		s.stimscript = set(s.stimscript,periodicstim(p),i);
	end;
	if isfield(p,'sFrequency')&isfield(p,'rect')&strcmp(paramname,'length'),
		r = p.rect;
		pv = r(3)-r(1);
		if isempty(intersect(paramval,pv)),
			paramval(end+1) = pv;
		else,
			pv = pv + max(paramval) + 2*mean(diff(paramval));
		end;
		p.dummy = pv;
		s.stimscript = set(s.stimscript,periodicstim(p),i);
	end;    
end;

if blankid>1,
	inp.blankid = i;
end;

blankid2,blankid,
if blankid>1,
    p = getparameters(get(s.stimscript,blankid));
    cl = class(get(s.stimscript,blankid));
    p.linenumber = numStims(s.stimscript);
    p.stimnum = numStims(s.stimscript);
    p.angle = 180;
    p.sFrequency = 1.8;
    p.cont = 0;
    p.contrast = 1.1;
    p.yposition = 0;
    p.dummy = max(paramval) + 1*mean(diff(paramval));
    p.disparity = 15+numStims(s.stimscript);
    eval(['newstim=' cl '(p);']);
    s.stimscript = set(s.stimscript,newstim,blankid);
end;

if blankid2>1,
    p = getparameters(get(s.stimscript,blankid2));
    cl = class(get(s.stimscript,blankid2));
    p.linenumber = numStims(s.stimscript);
    p.stimnum = numStims(s.stimscript);
    p.angle = 360;
    p.sFrequency = 2;
    p.yposition = 10;
    p.contrast = 1.2;
    p.cont = 2.0;
    p.disparity = 15+numStims(s.stimscript);
    p.dummy = 2*max(paramval) + 3*mean(diff(paramval));
    eval(['newstim=' cl '(p);']);
    s.stimscript = set(s.stimscript,newstim,blankid2);
end;

if 0,
	do = getDisplayOrder(s.stimscript);
	dogood = find(do~=blankid);
	donew = do(dogood);
	s.stimscript = remove(s.stimscript,blankid);
	s.stimscript = setDisplayMethod(s.stimscript,2,donew);
	s.mti = s.mti(dogood);
    clear inp;
end;

inp.paramname = 'dummy'; %paramname;
inp.spikes = mycell;
inp.st = s;
inp.title = [mycellname ' ' dirname];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = [];
end;

params.res = 0.01; params.showrast = 1; params.interp = 3; params.drawspont = 1; params.interval = [0.00 0]; params.int_meth = 0;

tc = tuning_curve(inp,params,where);
co = getoutput(tc);



return;
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
