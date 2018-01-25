function spikes = spikesduringstim(ds, cell, testdir)
% SPIKESDURINGSTIM - extract all spikes that occurred during a stimulus in a test dir
%
% SPIKES = SPIKESDURINGSTIM(DS, CELL, TESTDIR)
%
% This function examines the CELL that was recorded during a 
% directory TESTDIR that has a 'stims.mat' file that contains presentation
% information of stimscripts in the NewStim library.
%  
% DS should be a DIRSTRUCT object that manages the experiment directory.
% CELL should be a SPIKEDATA object (or a descendent class).
% TESTDIR is the name of the directory to examine (e.g., 't00001').
%


s = getstimscripttimestruct(ds,testdir);
[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep testdir filesep 'stimtimes.txt'],1);
s.mti = s.mti(inds_nottotrim);

spikes = get_data(cell, [s.mti{1}.startStopTimes(1) s.mti{end}.startStopTimes(end)]);

