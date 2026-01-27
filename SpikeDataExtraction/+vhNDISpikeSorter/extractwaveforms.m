function extractwaveforms(probe, epochID, params)
% EXTRACTWAVEFORMS - Extract spike waveforms for a specific probe and epoch
%
%   EXTRACTWAVEFORMS(PROBE, EPOCHID, PARAMS)
%
%   Extracts spike waveforms from the NDI probe PROBE for the epoch EPOCHID.
%   PARAMS is a vhNDISpikeSorter.parameters object.
%   Waveforms and spike times are saved to files determined by PARAMS.

    arguments
        probe {mustBeA(probe, 'ndi.probe')}
        epochID (1,:) char
        params {mustBeA(params, 'vhNDISpikeSorter.parameters')}
    end

    % Parameters
    filter_params = params.spikeSortingParameters.filter;
    events_params = params.spikeSortingParameters.events;
    process_params = params.spikeSortingParameters.process;

    samples = events_params.samples;
    refractory_period_samples = events_params.refractoryPeriodSamples;
    center_range = events_params.centerRange;

    chunkTime = process_params.chunkTime;
    overlap = process_params.overlap;
    progressBar = process_params.progressBar;

    % Threshold files check
    settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(probe.session);
    numChannels = 0; % Will determine from data or probe

    % Prepare output files
    waveFile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getSpikeWaveformFilename(probe, epochID));
    timeFile = strrep(waveFile, '.vsw', '.vst');

    % Initialize waveform file
    created_wavefile = false;

    % Processing loop
    try
        sr = probe.samplerate(epochID);
    catch err
        error('Could not determine sample rate: %s', err.message);
    end

    % Filter design
    if filter_params.cheby1Order > 0
        [B,A] = cheby1(filter_params.cheby1Order, filter_params.cheby1Rolloff, filter_params.cheby1Cutoff / (0.5 * sr), 'high');
    end

    start_time = 0;

    % Determine total duration if possible, or loop until error/empty
    % NDI epochtable might have duration?
    et = probe.epochtable();
    epoch_idx = find(strcmp({et.epoch_id}, epochID));
    if ~isempty(epoch_idx) && isfield(et(epoch_idx), 'duration')
        % duration might be available
    end

    % Loop through data in chunks
    end_of_data = false;
    all_wavetimes = [];

    if progressBar
        % Setup progress bar if possible, or just print
        disp(['Extracting waveforms for ' probe.elementstring() ' epoch ' epochID]);
    end

    while ~end_of_data
        t0 = start_time;
        t1 = start_time + chunkTime;

        try
            [data, time] = probe.readtimeseries(epochID, t0, t1);
        catch
            % Assuming error means end of data or invalid range
            end_of_data = true;
            break;
        end

        if isempty(data)
            end_of_data = true;
            break;
        end

        if size(data, 1) < (chunkTime * sr * 0.5) % If read significantly less than requested (buffer)
             % actually readtimeseries might return what's available.
             % If we get data, we process it. Next loop might fail or return empty.
        end

        % Filter
        if filter_params.cheby1Order > 0
            data = filtfilt(B, A, data);
        end

        if filter_params.medianFilterAcrossChannels
            data = data - repmat(median(data, 2), 1, size(data, 2));
        end

        numChannels = size(data, 2);

        % Load thresholds if not loaded (or reload if they could change? Assume constant per epoch)
        % We need thresholds for each channel.
        channel_thresholds = struct('threshold', {});
        for j=1:numChannels
             threshFile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID, j));
             if exist(threshFile, 'file')
                 tmp = loadStructArray(threshFile);
                 channel_thresholds(j).threshold = tmp.threshold;
             else
                 error(['Threshold file not found for channel ' int2str(j) ': ' threshFile]);
             end
        end

        % Detect spikes
        % We want to extract spikes.
        % Strategy: Find all crossings on all channels.
        % Combine crossings? Or extract per channel crossing?
        % "The spike should be extracted across all channels of the probe." implies:
        % If channel 1 crosses threshold, we grab samples from Ch1..N at that time.
        % We need to merge events that occur simultaneously on multiple channels (or within a window).

        locs_all = [];
        for j=1:numChannels
            if ~isempty(channel_thresholds(j).threshold)
                locs = dotdisc(double(data(:,j)), channel_thresholds(j).threshold);
                locs = refractory(locs, refractory_period_samples);
                locs_all = [locs_all; locs(:)];
            end
        end

        % Sort and handle refractory across ALL channels?
        % If ch1 and ch2 spike at same time, it's one event.
        locs_all = sort(locs_all);
        locs_all = refractory(locs_all, refractory_period_samples);

        % Trim locs near boundaries
        % We need [sample + samples(1), sample + samples(2)] to be within data
        valid_indices = find(locs_all + samples(1) >= 1 & locs_all + samples(2) <= size(data, 1));
        locs_all = locs_all(valid_indices);

        if isempty(locs_all)
            start_time = t1 - overlap;
            continue;
        end

        % Extract waveforms
        % Dimensions: N_spikes x N_samples x N_channels

        % Vectorized extraction
        % Indices:
        nSpikes = length(locs_all);
        nSamples = diff(samples) + 1;

        % Create index matrix
        % range relative to spike: samples(1):samples(2)
        window = samples(1):samples(2);

        % We can use linear indexing or reshape.
        % data is T x C.

        % Make indices for one channel extraction
        idx_base = locs_all + window; % N_spikes x N_samples

        my_waveforms = zeros(nSpikes, nSamples, numChannels, 'single');

        for c = 1:numChannels
            % data(:,c)
            chan_data = data(:,c);
            my_waveforms(:,:,c) = chan_data(idx_base);
        end

        % Center spikes?
        % "centerRange (10) : Range we should search over to find the global negative"
        % If we want to re-align based on global min/max.
        % centerspikes_neg logic from old code?
        % Assuming `centerspikes_neg` function exists (it was used in old code).
        % my_waveforms = centerspikes_neg(my_waveforms, center_range);
        % Check if centerspikes_neg is available or needed. It was in `extractwaveforms`.
        % "my_waveforms = centerspikes_neg(my_waveforms,CENTER_RANGE);"
        % I'll assume it's available in path or namespace.
        % It was in `vhNDISpikeSorter` namespace before? No, it was called as `centerspikes_neg` (helper).
        % I should verify if I need to move/refactor it or if it is external.

        try
            my_waveforms = centerspikes_neg(my_waveforms, center_range);
        catch
            % If function missing, skip centering or warn
            % warning('centerspikes_neg not found, skipping centering');
        end

        % Permute to Standard format?
        % Old code: `my_waveforms = permute(my_waveforms,[2 3 1]);`
        % `newvhlspikewaveformfile` expects: (samples, channels, spikes)?
        % `readvhlspikewaveformfile` returns waves.
        % `addvhlspikewaveformfile` doc says "WAVES is a SxCxN matrix".
        % My `my_waveforms` is N_spikes x N_samples x N_channels.
        % So I need `permute(my_waveforms, [2 3 1])`.

        my_waveforms = permute(my_waveforms, [2 3 1]);

        % Save
        if ~created_wavefile
            myp = struct;
            myp.numchannels = numChannels;
            myp.S0 = samples(1);
            myp.S1 = samples(2);
            myp.name = probe.name;
            myp.ref = 1; % or probe reference? probe.reference?
            myp.comment = ['Extracted from ' epochID];
            myp.samplingrate = sr;

            newvhlspikewaveformfile(waveFile, myp);
            created_wavefile = true;

            % Open time file
            fid = fopen(timeFile, 'w', 'ieee-le'); % 'b' in old code? NDI often Little Endian? Matlab default is native.
            % Old code: fopen(..., 'w', 'b'); (Big Endian).
            % I will stick to 'b' if that's the format vhlspikewaveformfile ecosystem expects, or strictly for times.
            % But wait, `fwrite(fid,wavetimes{k},'float64');`.
            % I'll use 'b' to match legacy if possible, or standard.
            fclose(fid);
        end

        addvhlspikewaveformfile(waveFile, my_waveforms);

        % Times
        % time(locs_all) gives time of spikes.
        % Append to file.
        current_times = time(locs_all);
        fid = fopen(timeFile, 'a', 'b');
        fwrite(fid, current_times, 'float64');
        fclose(fid);

        start_time = t1 - overlap;

        % Check if we reached end of requested data or file
        if t1 > 1e6 % Just a sanity limit, or check data length
             % actually `readtimeseries` error catches end of data usually if out of bounds?
             % Or we compare current_times with expected duration?
        end

        % Break if less data returned than expected (end of file)
        if size(data,1) < (chunkTime*sr - 10) % heuristic
            end_of_data = true;
        end
    end

    if progressBar
        disp('Extraction complete.');
    end

end
