function mti = mti_from_stimtimes_txt(dirname, script, starttime, saveit)
% MTI_FROM_STIMTIMES_TXT - Create MTI based on a stimtimes.txt file and script
% 
%  MTI = MTI_FROM_STIMTIMES_TXT(DIRNAME, SCRIPT, STARTTIME, SAVEIT)
%
%  It happens sometimes. Sometimes the stims.mat file disappears.
%  This function can rescue it if you know the exact script parameters.
%
%  Given the directory name (to read in the stimtimes.txt file)
%  and a STIMSCRIPT SCRIPT that matches the one used in the experiment
%  (though not necessary the same stimulus order), and given a start time
%  (that should not overlap any other trials), it creates an MTI record.
%  If SAVEIT is 1, then this is saved as the 'stims.mat' file in
%  DIRNAME.
%
%  Note that this will not perfectly reconstruct the stimulus, but it should
%  be close enough for analysis that does not require millisecond precision.
%
%  See also: READ_STIMTIMES
%  

[stimid, stimtimes,frametimes] = read_stimtimes_txt(dirname);

script = setDisplayMethod(script,2,stimid);

for i=1:length(stimid),
	mti{i} = struct;
	stim = get(script,stimid(i));
	df = struct(getdisplayprefs(stim));
	mti{i}.startStopTimes = starttime + [ stimtimes(i)-df.BGpretime ...
			stimtimes(i) ...
			stimtimes(i)+duration(stim)-df.BGposttime ...
			stimtimes(i)+duration(stim) ];
	mti{i}.frameTimes = starttime + frametimes{i};
	if isa(stim,'periodicstim'),
		mti{i}.frameTimes = starttime + stimtimes(i) + (0:(1/df.fps):(1/df.fps)*(length(df.frames)-1));
	end;
	mti{i}.stimid = stimid(i);
end;

if saveit,
	start = starttime;
	saveScript = script;
	MTI2 = mti;

	save([dirname filesep 'stims.mat'],'start','saveScript','MTI2');
end;


