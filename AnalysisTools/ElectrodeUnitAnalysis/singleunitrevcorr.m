function [mycell,assocs,rc] = singleunitrevcorr(ds, mycell, mycellname, dirname, display)

params = [];
assocs = [];

s = getstimscripttimestruct(ds,dirname);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);

if ~isempty(s),
           inp.stimtime = stimtimestruct(s,1);
           inp.spikes={mycell};inp.cellnames={mycellname};
           where.figure=figure;where.rect=[0 0 1 1];where.units='normalized';
           orient(where.figure,'landscape');
           rc = reverse_corr(inp,'default',where);
end;

return;

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

if mf1>mf0, pref = otpref(2); else, pref = otpref(1); end;

f0curve = [co.f0curve{1}];
f1curve = [co.f1curve{1}];

  % now add extra analysis here
