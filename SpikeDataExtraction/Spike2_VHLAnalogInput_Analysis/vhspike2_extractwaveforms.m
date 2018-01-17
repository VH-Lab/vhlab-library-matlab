function [wavetimes, t] = extractvhspike2waveforms(dirname, samples, refractory_period_samples, varargin)
% VHSPIKE2_EXTRACTVHSPIKE2WAVEFORMS - Extract spike waveforms from VH lab Spike2 recordings
%
%     VHSPIKE2_EXTRACTVHSPIKE2WAVEFORMS(DIRNAME, [S0 S1], REFRACTORY_PERIOD_SAMPLES, ...)
%
%  Extracts spike waveforms from all electrode units that are in the directory
%  DIRNAME.  DIRNAME should be provided with a full path.  For each spike, the
%  samples [S0...S1] around the center sample (0) are selected to define the waveform.
%  (For example, S0 = -10, S1 = 30 takes 10 samples before the center, and 30 samples
%  after.)  There is a refractory period imposed (in samples, not second) of
%  REFRACTORY_PERIOD_SAMPLES.
%
%  It is assumed that there is a filter channel mapping file
%  vhspike2_filtermap.txt that describes which channels should be grouped together
%  for the purpose of filtering (see help vhspike2_filtermap).
%
%  It is also assumed that there is a channel grouping file 
%  vhspike2_channelgrouping.txt, that indicates which channels should be grouped together
%  for the purpose of identifying and distinguishing spike waveform shapes
%  (see help vhspike2_channelgrouping).
%
%  It is further assumed that there is a file called
%  vhspike2_thresholds.txt  that describes the thresholds to be used for
%  for detecting spikes on these electrode units (see help vhspike2_thresholds).
%
%  The waveforms are saved to files vhspike2_spikewaveforms_N.vsw, located
%  in the directory DIRNAME.  Each channel grouping is represented by a different
%  number N. (See 'help newvhlspikewaveformfile' for the file format.) The spike times
%  (with respect to the time that LabView started acquiring within that diretory) are
%  in the binary file vhspike2_spiketimes_N.vsw (in float64 format).
%
%  EXTRACTVHSPIKE2WAVEFORMS uses a number of parameters for reading the spikes.
%  You can alter the values of these parameters by passing extra name/value
%  pairs to the function (such as 'READSIZE', 30).
%
%  Parameter, default                Comment:
%  READSIZE, 20                     : How big of data chucks should be read? (seconds)
%  OVERLAP, 0.05                    : How much overlap should there be between data chunks?
%  MEDIAN_FILTER_ACROSS_CHANNELS, 1 : Should we perform a median filter across channels? 0/1
%  VERBOSE, 0                       : Should we print our progress through the file?
%  VERBOSE_GRAPHICAL, 1             : Should we display a progress bar?
%  CENTER_RANGE 10                  : Range we should search over to find the global negative
%

 % should make samples assymetric

READSIZE = 10;  % read in N second steps
OVERLAP = 0.05;  % overlap each read by 0.1 seconds
MEDIAN_FILTER_ACROSS_CHANNELS = 1; % compute median filter
VERBOSE = 0;
VERBOSE_GRAPHICAL = 1;
CENTER_RANGE = 10;

assign(varargin{:});

 % Step 1) read in the header file and channel list

header_filename = vhspike2_getdirfilename(dirname);
data_filename =   header_filename; 

header = read_CED_SOMESMR_header(header_filename);

t = [samples(1):samples(2)]/header.frequency_parameters.amplifier_sample_rate;

filtermap_filename = [dirname filesep 'vhspike2_filtermap.txt'];
if exist(filtermap_filename),
	filtermap = loadStructArray(filtermap_filename);
else,
	error(['No file ' filtermap_filename '.']);
end;

channelgrouping_filename = [dirname filesep 'vhspike2_channelgrouping.txt'];
if exist(channelgrouping_filename),
	channelgrouping = loadStructArray(channelgrouping_filename);
else,
	error(['No file ' channelgrouping_filename '.']);
end;

threshold_filename = [dirname filesep 'vhspike2_thresholds.txt'];
if exist(threshold_filename),
	threshold_instruction = loadStructArray(threshold_filename);
else,
	error(['No file ' threshold_filename '.']);
end;

channel_standard_deviations = struct('channel','','stddev','');
channel_standard_deviations = channel_standard_deviations([]); % make it an empty structure

wavetimes = {};

for k=1:length(channelgrouping),
	changrouping_wavefname{k} = [dirname filesep 'vhspike2_spikewaveforms_' int2str(k) '.vsw'];
	changrouping_created(k) = 0;
	wavetimes{k} = double([]);
end;
	
 % Step 2, perform the extraction
 %    First, we'll loop over electrode units  (i loop)
 %           then we'll loop over the channels within the electrode units (j loop)
 

for i=1:length(filtermap),

	start_time = 0;
	end_of_file_reached = 0;

	my_locations = [];
	my_wavetimes = [];
	my_waveforms = single([]);

	hasprogbar = 0;
	tot_time = 100; % make something up so it doesn't crash

	if VERBOSE_GRAPHICAL,
		zzzz=which('progressbar');
		if ~isempty(zzzz),
			hasprogbar = 1;
		end;
		if hasprogbar,
			progressbar(['Extracting spikes from filter group ' int2str(i)]);
		end;
	end;
	[dummy1,dummy2,dummy3,dummy4,t0__] = read_CED_SOMSMR_datafile(data_filename,header,filtermap(i).channel_list(1),0,0);  

	while (~end_of_file_reached),
		if VERBOSE,
			start_time,  % display the progress
		end;
		if VERBOSE_GRAPHICAL&hasprogbar,
			progressbar(start_time/tot_time);
		end;
		end_time = start_time + READSIZE;
			% read the data
		if numel(filtermap(i).channel_list) > 1,
			error(['Right now, we do not know how to deal with more than one channel in a filtermap for Spike2...please submit feature request if this is needed.']);
		end
		samplerate = 1.0/double(read_CED_SOMSMR_sampleinterval(data_filename,header,filtermap(i).channel_list(1)));
		[B,A] = cheby1(4,0.8,300/(0.5*samplerate),'high');
		[D,tot_sam,tot_time,dummy,T] = read_CED_SOMSMR_datafile(data_filename,header,'amp',filtermap(i).channel_list,start_time,end_time);
		D = filtfilt(B,A,D);

		if abs(length(D) - ((end_time - start_time) * header.frequency_parameters.amplifier_sample_rate + 1))>2, % | T(end)>100,
			end_of_file_reached = 1;
		end;
		
		% perform median filter, if necessary

		if MEDIAN_FILTER_ACROSS_CHANNELS,
			D = D - repmat(median(D,2),1,length(filtermap(i).channel_list));
		end;

		% find threshold crossings on each channel
		locs = {};
		for j=1:length(filtermap(i).channel_list),
			% calculate the standard deviation in case any of our thresholds need it
			if isempty(find([channel_standard_deviations.channel]==filtermap(i).channel_list(j))),
				stddev = std(D(j,:)); % calculate standard deviation of the channel
				channel_standard_deviations = cat(1,channel_standard_deviations,struct('channel',filtermap(i).channel_list(j),'stddev',stddev));
			end;

			% now extract the spike waveforms
			%   what is the threshold we should use for this channel?
			z = find([threshold_instruction.channel]==filtermap(i).channel_list(j));
			if length(z)~=1,
				error(['Could not find a threshold, or found ambiguous threshold, for channel ' int2str(filtermap(i).channel_list(j)) ' from file ' threshold_filename  '.']);
			end;
			if length(threshold_instruction(z).threshold)==1,
				% it is a multiple of the standard deviation
				z2 = find([channel_standard_deviations.channel]==filtermap(i).channel_list(j));
				if isempty(z2),
					error(['Could not find record of standard deviation for channel ' int2str(filtermap(i).channel_list(j)) '. This should NEVER happen.']);
				end;
				mydot = [threshold_instruction(z).threshold * channel_standard_deviations(z2).stddev sign(threshold_instruction(z).threshold) 0];
			else, % assume it is a dot
				mydot = threshold_instruction(z).threshold;
			end;
			
			locs{j} = dotdisc(double(D(:,j)),mydot); % need to make sure doubles go in, or dotdisc mex file will crash
			locs{j} = refractory(locs{j},refractory_period_samples);
			locs{j} = locs{j}(find(locs{j}>-samples(1) & locs{j}<=length(D(:,j))-samples(2))); % trim any spike for which we can't grab a full wave

		end; % for loop over channels using j

		% now need to extract waveforms from these locations
		% to do this, we need to examine the channel groupings

		for k=1:length(channelgrouping),
			my_locations = [];
			my_chan_list = [];
			channel_intersection = intersect(channelgrouping(k).channel_list,filtermap(i).channel_list);
			if ~isempty(channel_intersection),
				if eqlen(channelgrouping(k).channel_list,channel_intersection),
					for j=1:length(channelgrouping(k).channel_list),
						my_chan_list(j) = find(filtermap(i).channel_list==channelgrouping(k).channel_list(j));
						my_locations = [my_locations; locs{my_chan_list(j)}(:)];
					end;
					my_locations = sort(refractory(my_locations,refractory_period_samples));
				else,
					error(['Could not map electrode unit onto channel grouping in directory ' dirname '.']);
				end;

			% now that we have the locations, let's read the waveforms

				wavetimes{k} = cat(1,wavetimes{k},-t0__+T(my_locations));

				sample_offsets = repmat([samples(1):samples(2)],1,length(channelgrouping(k).channel_list));
				channel_offsets = repmat(my_chan_list(:)',diff(samples)+1,1);
				single_spike_selection = sample_offsets + (channel_offsets(:)'-1)*size(D,1);
				spike_selections = repmat(single_spike_selection,length(my_locations),1)+repmat(my_locations,1,size(single_spike_selection,2));
				my_waveforms = single(D(spike_selections));
				my_waveforms = reshape(my_waveforms,length(my_locations), diff(samples)+1, length(channelgrouping(k).channel_list));
				my_waveforms = centerspikes_neg(my_waveforms,CENTER_RANGE);
				my_waveforms = permute(my_waveforms,[2 3 1]);
				if changrouping_created(k)==0,
					myp = struct;
					myp.numchannels = length(channelgrouping(k).channel_list);
					myp.S0 = samples(1);
					myp.S1 = samples(2);
					myp.name = channelgrouping(k).name;
					myp.ref = channelgrouping(k).ref;
					myp.comment = dirname;
					myp.samplingrate = header.frequency_parameters.amplifier_sample_rate;
					myfid = newvhlspikewaveformfile(changrouping_wavefname{k},myp);
					changrouping_created(k) = 1;
					fclose(myfid);
				end;
				addvhlspikewaveformfile(changrouping_wavefname{k},my_waveforms);
			end; % isempty intersection
		end; % for loop over channelgrouping

		start_time = start_time + READSIZE - OVERLAP;
	end; % while loop over file length
end;  % for loop

for k=1:length(channelgrouping), % reshape to have the right shape/order
	%spiketimes = wavetimes{k};
	fid=fopen([dirname filesep 'vhspike2_spiketimes_' int2str(k) '.vst'],'w','b');
	if fid<0,
		error(['Could not open file ' dirname filesep 'vhspike2_spiketimes_' int2str(k) '.vst']);
	end;
	fwrite(fid,wavetimes{k},'float64');
	fclose(fid);
	%save([dirname filesep 'vhspike2_spiketimes_' int2str(k) '.mat'],'spiketimes');
end;

if VERBOSE_GRAPHICAL&hasprogbar,
	progressbar(1);
end;

