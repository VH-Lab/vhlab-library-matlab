function [all_triggertimes,startTime] = GetSGStimTriggers(dirname,tfile,gridloc,transition)

% Returns trigger times for a given grid location for a blinkingstim
%
%  TRIGGERTIMES = GETSGSTIMGRIDTRIGGERS(DS, DIRNAME, GRIDLOC)
%
%  Inputs: DS - DIRSTRUCT object try ds =
%               dirstruct('/Users/myname/myexperiments/2011-11-11');
%          DIRNAME - a full-path directory name where the data resides
%          GRIDLOC - The grid location to analyze
%          TRANSITION - use 0 for white to black and 1 for black to white
%  
%  Returns the frame times (in global experimental time) of frames at 
%  grid location GRIDLOC.
%


ds = dirstruct(dirname);
s = getstimscripttimestruct(ds,tfile);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
[s.mti,startTime] = tpcorrectmti(s.mti,[dirname filesep tfile filesep 'stimtimes.txt'],0);
s.mti = s.mti(inds_nottotrim);

all_triggertimes = [];

for n = 1:numStims(s.stimscript)

    sgsstim = get(s.stimscript,n);

    % find black -> white transitions

    V = getgridvalues(sgsstim);

    % find the frame numbers that correspond to transitions from black to
    % white
    % I think black is index 1, white is index 2
    
    %mystim = get(saveScript,1)
    %getparameters(mystim)
    %BG: [0 0 0]   is 1 --- in this case this is black
    %value: [255 255 255] is 2 --- in this case this is white
    
    %working with v:
    %v = getgridvalues(get(saveScript,1));
    %size(v)
    %max(v(:,1))
    %v(:,1) --- 1 --> 2 means black to white
    
    %to know whether it is TRULY black or white, load(stims.mat)
    
    
    if transition == 1  %black to white; 1 --> 2
        bw_transitions = 1+find( (V(gridloc,1:end-1)==1) & (V(gridloc,2:end)==2) );
    elseif transition == 0  %white to black; 2 --> 1
        bw_transitions = 1+find( (V(gridloc,1:end-1)==2) & (V(gridloc,2:end)==1) );
    else
        error('Transition value must be either 0 or 1.')
    end


    for i = 1:length(bw_transitions),

        triggertimes = s.mti{n}.frameTimes(bw_transitions(i));
        triggertimes = triggertimes - startTime;
        all_triggertimes = cat(2,all_triggertimes,triggertimes); % ... check this

    end


end;
% Notes
% 'mti' stands for 'measured timing information'.