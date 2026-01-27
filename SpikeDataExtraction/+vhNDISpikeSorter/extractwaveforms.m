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

    % Prepare output files
    waveFile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getSpikeWaveformFilename(probe, epochID));
    timeFile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getSpikeTimesFilename(probe, epochID));

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

    et = probe.epochtable();

    % Loop through data in chunks
    end_of_data = false;

    if progressBar
        disp(['Extracting waveforms for ' probe.elementstring() ' epoch ' epochID]);
    end

    % Ensure files are fresh
    if exist(waveFile, 'file'), delete(waveFile); end
    if exist(timeFile, 'file'), delete(timeFile); end

    while ~end_of_data
        t0 = start_time;
        t1 = start_time + chunkTime;

        try
            [data, time] = probe.readtimeseries(epochID, t0, t1);
        catch
            end_of_data = true;
            break;
        end

        if isempty(data)
            end_of_data = true;
            break;
        end

        % Filter
        if filter_params.cheby1Order > 0
            data = filtfilt(B, A, data);
        end

        if filter_params.medianFilterAcrossChannels
            data = data - repmat(median(data, 2), 1, size(data, 2));
        end

        numChannels = size(data, 2);

        % Load thresholds
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
        locs_all = [];
        for j=1:numChannels
            if ~isempty(channel_thresholds(j).threshold)
                locs = dotdisc(double(data(:,j)), channel_thresholds(j).threshold);
                locs = refractory(locs, refractory_period_samples);
                locs_all = [locs_all; locs(:)];
            end
        end

        locs_all = sort(locs_all);
        locs_all = refractory(locs_all, refractory_period_samples);

        % Trim locs
        valid_indices = find(locs_all + samples(1) >= 1 & locs_all + samples(2) <= size(data, 1));
        locs_all = locs_all(valid_indices);

        if isempty(locs_all)
            start_time = t1 - overlap;
            continue;
        end

        % Extract
        nSpikes = length(locs_all);
        nSamples = diff(samples) + 1;
        window = samples(1):samples(2);
        idx_base = locs_all + window;

        my_waveforms = zeros(nSpikes, nSamples, numChannels, 'single');

        for c = 1:numChannels
            chan_data = data(:,c);
            my_waveforms(:,:,c) = chan_data(idx_base);
        end

        try
            my_waveforms = centerspikes_neg(my_waveforms, center_range);
        catch
        end

        my_waveforms = permute(my_waveforms, [2 3 1]);

        % Save
        if ~created_wavefile
            myp = struct;
            myp.numchannels = numChannels;
            myp.S0 = samples(1);
            myp.S1 = samples(2);
            myp.name = probe.name; % or probe.elementstring?
            myp.ref = 1;
            myp.comment = ['Extracted from ' epochID];
            myp.samplingrate = sr;

            newvhlspikewaveformfile(waveFile, myp);
            created_wavefile = true;

            fid = fopen(timeFile, 'w', 'ieee-le');
            fclose(fid);
        end

        addvhlspikewaveformfile(waveFile, my_waveforms);

        current_times = time(locs_all);
        fid = fopen(timeFile, 'a', 'ieee-le');
        fwrite(fid, current_times, 'float64');
        fclose(fid);

        start_time = t1 - overlap;

        if size(data,1) < (chunkTime*sr - 10)
            end_of_data = true;
        end
    end

    if progressBar
        disp('Extraction complete.');
    end

end
