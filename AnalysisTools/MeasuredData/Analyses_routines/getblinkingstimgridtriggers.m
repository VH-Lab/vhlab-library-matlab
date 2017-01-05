function triggerTimes = getblinkingstimgridtriggers(dirname, gridloc)
% Returns trigger times for a given grid location for a blinkingstim
%
%  TRIGGERTIMES = GETBLINKINGSTIMGRIDTRIGGERS(DIRNAME, GRIDLOC)
%
%  Inputs: DIRNAME - a full-path directory name where the data resides
%          GRIDLOC - The grid location to analyze
%  
%  Returns the frame times (in global experimental time, (Spike2 time in
%  VHLab)) of frames at grid location GRIDLOC.
%


s = getstimscripttimestruct(ds,dirname);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
s.mti = s.mti(inds_nottotrim);
    
    blinkList = getgridorder(blinkstim);


for i=1:length(testlist),
        sts = getstimscripttimestruct(cksds,testlist{i});
        blinkstim = get(sts.stimscript,1);
        blinkList = getgridorder(blinkstim);
        triggerTimes = sts.mti{1}.frameTimes(find(blinkList==gridloc));
end;


