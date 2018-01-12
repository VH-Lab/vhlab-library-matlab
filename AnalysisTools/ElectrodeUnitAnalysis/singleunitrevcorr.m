function [mycell,assocs,rc] = singleunitrevcorr(ds, mycell, mycellname, dirname, display)

params = [];
assocs = [];

s = getstimscripttimestruct(ds,dirname);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);

if ~isempty(s)&1,
           inp.stimtime = stimtimestruct(s,1);
           inp.spikes={mycell};inp.cellnames={mycellname};
           where.figure=figure;where.rect=[0 0 1 1];where.units='normalized';
           orient(where.figure,'landscape');
           rc = reverse_corr(inp,'default',where);
end;


spiketimes_local = celldirspiketimes(ds, dirname, mycell);

sp_rev_corr = spiketimes_rc(ds,dirname,spiketimes_local, 'mnt',-0.1, 'mt', 0.2, 'step', 0.001,'usespike01',1);
out=rc_plot(sp_rev_corr);


return;

