function co = singleunitgrating_demultiplex(ds, mycell, mycellname, dirname, paramname1, paramname2, display)
% SINGLEUNITGRATING_DEMULTIPLEX - break a periodic tuning curve with multiple parameters down into multiple single tuning curves
%
% CO = SINGLEUNITGRATING_DEMULTIPLEX(DS, MYCELL, MYCELLNAME, DIRNAME, ...
%   PARAMNAME1, PARAMNAME2, DISPLAY)
%
%

s = getstimscripttimestruct(ds,dirname);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
s.mti = s.mti(inds_nottotrim);

s = unloopstimscripttimestruct(s); % remove any loops

newslist = DemultiplexScriptMTI(s,paramname2);

co = {};

for j=1:length(newslist),
	[dummy,dummy,dummy,dummy,dummy,dummy,co{j}]=...
		singleunitgrating2(ds,mycell,mycellname,{newslist(j) dirname}, paramname1, display);
end;


