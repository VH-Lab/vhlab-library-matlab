function Intan_exporttoVHLV(IntanFile, VHLVfile, varargin)
% INTAN_EXPORTTOVHLV - Export Intan recorded data to a vhlvanaloginput.vld file
%
%  INTAN_EXPORTTOVHLV(INTANFILE, VHLVFILE, ...)
%
%  Given an Intan file in .rhd format, this function creates a file of type
%  VHLV (read by READVHLVDATAFILE and READVHVLHEADERFILE) that can be read by
%  any program capable of dealing with these files. The data file is given the
%  name VHLVFILE.vld and the associated header file is VHLVFILE.vlh.
%
%  This function accepts additional options as name/value pairs:
%  Parameter (default value)        | Description
%  ----------------------------------------------------------------------------
%  SyncChannel (1)                  | Channel number where sync channel is placed
%                                   |   (can be 1 or N+1, where N is number of Intan channels)
%  IntanDigSyncChannel (1)          | Sync Channel location on Digital inputs of Intan file
%  IntanChannels ([1:N])            | Intan analog input channels to use (default is all)
%  PerformHighPassFilter (1)        | Perform a high-pass filter of the data using CHEBY1
%  FilterOrder (4)                  | Order of the Cheby1 filter (see HELP CHEBY1)
%  FilterRipple (1)                 | Ripples of the Cheby1 filter (see HELP CHEBY1)
%  FilterHighPassFreq (300)         | Frequency cut off of the filter (see HELP CHEBY1)
%  Write_vhlv_syncchannel_txt (1)   | VHVLSyncChannelTxt (1) | Write the 'vhlv_syncchannel.txt' file with the
%                                   |   corresponding SyncChannel number
%  Write_vhlv_sync2trialtime_txt (1)| Write the sync factor (shift of 0, scale of 1.0) so computation isn't
%                                   |   needed (speeds import)
%  Write_vhlv_channelgrouping_txt   | Write the vhlv_channelgrouping file, using 1:1 mapping
%   (0)                             |
%  Chunk_size (100)                 | Chunk sizes to read from Intan file (seconds)
%  ExtraTime (0.05)                 | Extra time to read in each chunk (at beginning and end)
%  ShowProgressBar (1)              | Show a progress bar
% 
%  See also:  READ_INTANRHD2000_DATAFILE, READVHLVDATAFILE, WRITEVHLVDATAFILE
%

SyncChannel = 1;
IntanDigSyncChannel = 1;
IntanChannels = [];
PerformHighPassFilter = 1;
FilterHighPassFreq = 300;
FilterOrder = 4;
FilterRipple = 1;
Write_vhlv_syncchannel_txt = 1;
Write_vhlv_sync2spike2time_txt = 1;
Write_vhlv_sync2trialtime_txt = 1;
Write_vhlv_channelgrouping_txt = 0;
Chunk_size = 100;
ExtraTime = 0.05;
ShowProgressBar = 1;

assign(varargin{:});

[filepath] = fileparts(IntanFile);
if isempty(filepath),
	filepath = pwd;
end;

h = read_Intan_RHD2000_header(IntanFile);

samplerate = h.frequency_parameters.amplifier_sample_rate;
sampleinterval = 1/samplerate;

if isempty(IntanChannels),
	IntanChannels = 1:length(h.amplifier_channels);
end;


[dummy,tot_samples,tot_time,blockinfo]=read_Intan_RHD2000_datafile(IntanFile,h,'time',1,0,sampleinterval);

times = 0:Chunk_size:(tot_time+sampleinterval);
if times(end)~=tot_time+sampleinterval, % extend the last chunk so we get to the end of the data
	times(end) = tot_time+sampleinterval;  % we add an extra sample because we read up to times(i)-1 sample
end;

 % create the header file here
vhlv_header.ChannelString = ['Intan ' ];
for i=1:length(h.amplifier_channels),
    ch_shift = 0;
    if SyncChannel == i,
        vhlv_header.ChannelString = cat(2,vhlv_header.ChannelString,'SyncChannel');
    else,
        if i>SyncChannel,
            ch_shift = 1;
        end;
        vhlv_header.ChannelString = cat(2,vhlv_header.ChannelString,h.amplifier_channels(i-ch_shift).native_channel_name);
    end;
	if i~=length(h.amplifier_channels),
		vhlv_header.ChannelString(end+1:end+2) = ', ';
	end;
end;
vhlv_header.NumChans = length(IntanChannels) + ~isempty(SyncChannel);
vhlv_header.SamplingRate = samplerate;
vhlv_header.SamplesPerChunk = samplerate; % multiplexed mode
vhlv_header.precision = 'int16';
vhlv_header.Scale = '1'; 
for i=1:length(blockinfo),% edit this so it matches what it should
	if strcmp(blockinfo(i).type,'amp'),
		vhlv_header.Scale = (2^15-1)*blockinfo(i).scale;
	end;
end;
vhlv_header.Multiplexed = 1;

b = [];
a = [];
if PerformHighPassFilter,
	[b,a] = cheby1(FilterOrder,FilterRipple,FilterHighPassFreq/(0.5*samplerate),'high');
end;

if ShowProgressBar,
	mybar = waitbar(0,['Converting ' IntanFile ' to VHLV format.']);
else,
	mybar = [];
end;


for t=1:length(times)-1,
	t0 = times(t);
	t1 = times(t+1)-sampleinterval;

	s0 = fix(t0*samplerate); % this is the sample we will start from
	t0_ = t0 - ExtraTime;
	if t0_<0, t0_ = 0; end;
	s0_ = fix(t0_*samplerate);
	extra_samples_before = s0 - s0_;

	s1 = fix(t1*samplerate); % this is the same we will end at
	t1_ = t1 + ExtraTime;
	if t1_ > tot_time, t1_ = tot_time; end;
	s1_ = fix(t1_*samplerate); % this is the sample we will actually end at
	extra_samples_after = s1_ - s1;

	if SyncChannel & (length(h.board_dig_in_channels)>=1),
		d_data = read_Intan_RHD2000_datafile(IntanFile,h,'din',1,t0_,t1_);
		d_data = bitget(d_data, IntanDigSyncChannel) * 5; % 5 volts
	else,
		d_data = [];
	end;

	adata = read_Intan_RHD2000_datafile(IntanFile,h,'amp',IntanChannels,t0_,t1_);
	if PerformHighPassFilter, % do the filter
		for i=1:length(IntanChannels),
			adata(:,i) = filtfilt(b,a,adata(:,i));
		end;
	end;

	if ~isempty(d_data),
		all_data = [ adata(:,1:SyncChannel-1) double(d_data) adata(:,SyncChannel:end) ];
	else,
		all_data = adata;
	end;
	
	% drop any extra samples we read in to handle filtering artifiacts
	all_data = all_data(1+extra_samples_before:end-extra_samples_after,:);

    writevhlvdatafile(VHLVfile, vhlv_header, all_data, 'append',t>1);

	if ~isempty(mybar), waitbar(t/(length(times)-1),mybar); end;
end;

  % now write any extra files that are needed
shiftscale = [ 0 1 ];
if Write_vhlv_sync2spike2time_txt,
	dlmwrite([filepath filesep 'vhlv_sync2spike2time.txt'],shiftscale,'precision','%.10f');
end;
if Write_vhlv_sync2trialtime_txt,
	dlmwrite([filepath filesep 'vhlv_sync2trialtime.txt'],shiftscale,'precision','%.10f');
end;
if Write_vhlv_syncchannel_txt,
    dlmwrite([filepath filesep 'vhlv_syncchannel.txt'],SyncChannel);
end;
if Write_vhlv_channelgrouping_txt,
		error(['not finished yet.']);
end;

if ~isempty(mybar), close(mybar); end;


