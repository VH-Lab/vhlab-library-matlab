function plotvoltagewaveformwithstimuli(dirname, varargin)
% PLOTVOLTAGEWAVEFORMWITHSTIMULI - plot a voltage waveform with the stimulus information
%
% 
%
% This function can also be altered with NAME/VALUE pairs that override the
% default functionality:
% Parameter (default)           | Description
% ---------------------------------------------------------------------------
% 'iodevice' ('Intan')          | Assume Intan RHD file (only available right now)
% 'channel' (1)                 | The device's analog input channel to read
% 'stimchannel' (1)             | The device's digital input channel to read

iodevice = 'Intan';
channel = 1;
stimchannel = 1;

assign(varargin{:});


switch lower(iodevice),
	case lower('Intan'),
		fname = dir([dirname filesep '*.rhd']);

		if numel(fname)>1 | numel(fname) == 0,
			error(['Must be exactly 1 RHD file.']);
		end;

		datafile = [dirname filesep fname(1).name];

		disp(['Reading data...']);
		analogdata = read_Intan_RHD2000_datafile(datafile,[],'amp',channel,0,Inf);
		analogtime = read_Intan_RHD2000_datafile(datafile,[],'time',1,0,Inf);
		stimdata = read_Intan_RHD2000_datafile(datafile,[],'din',stimchannel,0,Inf);

		[shift,scale] = vhintan_sync2spike2(dirname);

	otherwise,
		error(['Unknown device at this time.']);
end

[thestimscript,mti] = getstimscript(dirname);

[mti2,starttime] = vhlabcorrectmti(mti,[dirname filesep 'stimtimes.txt'],0);

stimids = [];
stimonset = [];
stimoffset = [];

for i=1:numel(mti2),
	stimids(end+1) = mti2{i}.stimid;
	stimonset(end+1) = (mti2{i}.startStopTimes(2) - starttime - shift)/scale;
	stimoffset(end+1) = (mti2{i}.startStopTimes(3) - starttime - shift)/scale;
end

stimonset,

sample_dt = analogtime(2) - analogtime(1);
sample_f = 1/sample_dt;

[b,a] = cheby1(4,0.8,[300/(0.5*sample_f)],'high');

analogdata_f = filtfilt(b,a,analogdata);

figure;
plot(analogtime,analogdata_f,'b');

prct_99 = prctile(analogdata_f,99);

hold on;

plot_stimulus_timeseries(prct_99, stimonset, stimoffset, 'stimid',stimids);

box off;

ylabel('Voltage');
xlabel('Time (s)');

title([dirname ', channel=' int2str(channel)],'interp','none');

