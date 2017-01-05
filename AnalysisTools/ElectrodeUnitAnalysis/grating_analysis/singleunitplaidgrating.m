function co = singleunitplaidgrating(ds, mycell, mycellname, dirname, paramname, display, stimnumfield)

s = getstimscripttimestruct(ds,dirname);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
s.mti = s.mti(inds_nottotrim);

s = unloopstimscripttimestruct(s); % remove any loops

newslist = DemultiplexScriptMTI(s,'contrast');

co = {};

for j=1:length(newslist),
	[dummy,dummy,dummy,dummy,dummy,dummy,co{j}]=...
		singleunitgrating2(ds,mycell,mycellname,{newslist(j) dirname}, paramname, display);
end;


