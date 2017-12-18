function spiketimes = celldirspiketimes(ds, dirname, cell)
% CELLDIRSPIKETIMES - extract spike times for a cell in local directory time units
%
% SPIKETIMES = CELLDIRSPIKETIMES(DS, DIRNAME, CELL)
%
% Extracts spike times relative to the local time in directory DIRNAME.

s = getstimscripttimestruct(ds,dirname);

[s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,0);
s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
s.mti = s.mti(inds_nottotrim);

[stimids,allstimtimes,frameTimes] = read_stimtimes_txt([getpathname(ds) filesep dirname]);

offset = s.mti{1}.frameTimes(1) - frameTimes{1}(1);

spiketimes = get_data(cell,[s.mti{1}.startStopTimes(1) s.mti{end}.startStopTimes(4)]);
spiketimes = spiketimes - offset;

