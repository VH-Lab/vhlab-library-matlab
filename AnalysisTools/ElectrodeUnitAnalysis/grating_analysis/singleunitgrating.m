function [mycell,assocs, params,pc] = singleunitgrating(ds, name, ref, dirname, paramname, display)

params = [];
assocs = [];

[mycell,mycellname] = vhspike2_loadcell(ds,name,ref,1);

s = getstimscripttimestruct(ds,dirname);
s.mti = fitzcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);


 % trim the blank stim
blankid = -1;
for i=1:numStims(s.stimscript),
	p=getparameters(get(s.stimscript,i));
	if isfield(p,'chromhigh'), if eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if isfield(p,'isblank'), blankid = i; break; end;
end;

if blankid>1,
	inp.blankid = i;
end;
if 0,
	do = getDisplayOrder(s.stimscript);
	dogood = find(do~=blankid);
	donew = do(dogood);
	s.stimscript = remove(s.stimscript,blankid);
	s.stimscript = setDisplayMethod(s.stimscript,2,donew);
	s.mti = s.mti(dogood);
end;

inp.paramnames = {paramname};
inp.spikes = mycell;
inp.st = s;
inp.title = [mycellname ' ' dirname];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = [];
end;

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

f0curve = [co.f0curve{1}];
f1curve = [co.f1curve{1}];

  % now add extra analysis here
