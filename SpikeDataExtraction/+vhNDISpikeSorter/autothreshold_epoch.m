function autothreshold_epoch(probe, epochID, params)
% AUTOTHRESHOLD_EPOCH - Determine spike thresholds for a specific probe and epoch
%
%   AUTOTHRESHOLD_EPOCH(PROBE, EPOCHID, PARAMS)
%
%   Determines thresholds for the specified PROBE (ndi.probe) and EPOCHID (string).
%   PARAMS is a vhNDISpikeSorter.parameters object containing settings.
%   Thresholds are saved to a text file determined by PARAMS.getThresholdLevelFilename.

    arguments
        probe {mustBeA(probe, 'ndi.probe')}
        epochID (1,:) char
        params {mustBeA(params, 'vhNDISpikeSorter.parameters')}
    end

    % Extract parameters
    sigma = params.spikeSortingParameters.autothreshold.sigma;
    readTime = params.spikeSortingParameters.autothreshold.readTime;
    useMedian = params.spikeSortingParameters.autothreshold.useMedian;
    medianFilter = params.spikeSortingParameters.filter.medianFilterAcrossChannels;

    % Read data
    % Use readtimeseries. We read 'readTime' amount of data from the beginning (0).
    % Calling convention: data = readtimeseries(probe, epochID, t0, t1)

    % Note: readtimeseries returns [data, time] usually, or just data.
    % NDI readtimeseries: readtimeseries(probe, epoch, t0, t1)
    % Assuming t0=0, t1=readTime.

    try
        [data, t] = probe.readtimeseries(epochID, 0, readTime);
    catch err
        error('Could not read data for probe %s epoch %s: %s', probe.name, epochID, err.message);
    end

    % Filter data if needed (e.g. high pass).
    % The previous code used cheby1 filter.
    % Params has filter settings.
    % We need the sample rate.

    % Assuming probe has samplerate(epochID) method or property.
    try
        sr = probe.samplerate(epochID);
    catch err
        error('Could not determine sample rate for probe %s epoch %s: %s', probe.name, epochID, err.message);
    end

    % Design filter
    if params.spikeSortingParameters.filter.cheby1Order > 0
        [B,A] = cheby1(params.spikeSortingParameters.filter.cheby1Order, ...
                       params.spikeSortingParameters.filter.cheby1Rolloff, ...
                       params.spikeSortingParameters.filter.cheby1Cutoff / (0.5 * sr), ...
                       'high');
        data = filtfilt(B, A, data);
    end

    % Median filter across channels
    if medianFilter
        data = data - repmat(median(data, 2), 1, size(data, 2)); % Assuming data is Samples x Channels?
        % Wait, existing code: D = D - repmat(median(D,2),1,length(filtermap(i).channel_list));
        % Existing code D was (Channels x Samples) or (Samples x Channels)?
        % read_Intan_RHD2000_datafile usually returns Channels x Samples if 'amp'.
        % But let's check NDI readtimeseries convention. Usually Samples x Channels.
        % If Samples x Channels, median(data, 2) is median across channels for each sample.
        % So repmat(median(data, 2), 1, numChannels) matches size.

        % Let's verify dimension. If data is TxN (T samples, N channels).
        % median(data, 2) is Tx1.
        % repmat(..., 1, N) is TxN.
        % So data - median is correct for Common Average Reference (Median).
    end

    threshold_struct = struct('channel', [], 'threshold', []);
    threshold_struct = threshold_struct([]);

    % Calculate thresholds for each channel
    % NDI probe channels logic?
    % We just iterate over columns of data?
    numChannels = size(data, 2);

    % We need channel identifiers. probe usually handles mapping.
    % If we save thresholds, we need to know which channel.
    % Does NDI probe expose channel list?
    % probe.channel_id ?
    % Or just index?
    % The output file format expects 'channel' field.
    % Previous code used 'filtermap(i).channel_list(j)'.

    % For now, I'll use 1:numChannels unless probe gives specific channel IDs.
    % Assuming NDI readtimeseries returns channels in order of probe definition.

    for j = 1:numChannels
        if useMedian
            stddev = median(abs(data(:,j))) / 0.6745;
        else
            stddev = std(data(:,j));
        end
        thresh = sigma * stddev;

        % Channel ID?
        % If we can get it from probe, good.
        % For now assume 1-based index or try to fetch.
        chanID = j;

        threshold_struct(end+1) = struct('channel', chanID, 'threshold', [-thresh -1 0]);
    end

    % Save to file
    filename = vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID);

    % Determine full path using spikeSortingPath
    settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(probe.session);

    if isempty(settingsDir)
         error('Cannot determine directory to save thresholds.');
    end

    if ~exist(settingsDir, 'dir')
        mkdir(settingsDir);
    end

    fullPath = fullfile(settingsDir, filename);

    % Save struct array
    % Need a utility to save struct array as text?
    % Existing code used saveStructArray. I should use that if available.
    saveStructArray(fullPath, threshold_struct, 1);
end
