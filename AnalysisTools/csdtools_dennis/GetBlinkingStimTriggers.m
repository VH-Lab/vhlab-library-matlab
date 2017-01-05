function [all_triggertimes,startTime,reftime] = GetBlinkingStimTriggers(dirname,tfile,gridloc)

% Returns trigger times for a given grid location for a blinkingstim
%
%  TRIGGERTIMES = GETBLINKINGSTIMGRIDTRIGGERS(DS, DIRNAME, GRIDLOC)
%
%  Inputs: DS - DIRSTRUCT object try ds =
%               dirstruct('/Users/myname/myexperiments/2011-11-11');
%          DIRNAME - a full-path directory name where the data resides
%          GRIDLOC - The grid location to analyze
%  
%  Returns the frame times (in global experimental time) of frames at 
%  grid location GRIDLOC.
%


ds = dirstruct(dirname);
s = getstimscripttimestruct(ds,tfile);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
[s.mti,startTime] = tpcorrectmti(s.mti,[dirname filesep tfile filesep 'stimtimes.txt'],0);
s.mti = s.mti(inds_nottotrim);
blinkstim = get(s.stimscript,1);
blinkList = getgridorder(blinkstim);

all_triggertimes = [];

for i = 1:length(gridloc),
    
    triggertimes = s.mti{1}.frameTimes(find(blinkList == gridloc(i)));
    triggertimes = triggertimes - startTime;
    all_triggertimes = cat(2,all_triggertimes,triggertimes); % ... check this

end



% Notes
% 'mti' stands for 'measured timing information'.