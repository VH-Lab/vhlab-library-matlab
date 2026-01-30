function autothreshold_epoch(probe, epochID, params)
% AUTOTHRESHOLD_EPOCH - Determine spike thresholds for a specific probe and epoch
%
%   AUTOTHRESHOLD_EPOCH(PROBE, EPOCHID, PARAMS)
%
%   Determines thresholds for the specified PROBE (ndi.probe) and EPOCHID (string).
%   PARAMS is a vhNDISpikeSorter.parameters object containing settings.
%   Thresholds are saved to text files determined by PARAMS.getThresholdLevelFilename.

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
    
    try
        [data, t] = probe.readtimeseries(epochID, 0, readTime);
    catch err
        error('Could not read data for probe %s epoch %s: %s', probe.name, epochID, err.message);
    end
    
    % Filter data if needed (e.g. high pass). 
    % The previous code used cheby1 filter. 
    % Params has filter settings.
    % We need the sample rate.
    
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
        data = data - repmat(median(data, 2), 1, size(data, 2)); % Assuming data is Samples x Channels
    end
    
    numChannels = size(data, 2);
    
    % Determine settings directory
    settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(probe.session);
    
    if isempty(settingsDir)
         error('Cannot determine directory to save thresholds.');
    end
    
    if ~exist(settingsDir, 'dir')
        mkdir(settingsDir);
    end
    
    for j = 1:numChannels
        if useMedian
            stddev = median(abs(data(:,j))) / 0.6745;
        else
            stddev = std(data(:,j));
        end
        thresh = sigma * stddev;
        
        chanID = j; 
        
        % Create struct for this channel
        threshold_struct = struct('channel', chanID, 'threshold', [-thresh -1 0]);
        
        % Save to file for this channel
        filename = vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID, chanID);
        fullPath = fullfile(settingsDir, filename);
        
        saveStructArray(fullPath, threshold_struct, 1);
    end
end
