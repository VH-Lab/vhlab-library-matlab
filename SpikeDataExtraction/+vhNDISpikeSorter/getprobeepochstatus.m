function status = getprobeepochstatus(ndiSession)
% GETPROBEEPOCHSTATUS - Get the status of probe/epochs in the session
%
%    STATUS = GETPROBEEPOCHSTATUS(NDISESSION)
%
%  Examines the NDI session to see which probe/epochs have thresholding
%  and spike extraction data.
%
%  STATUS is a struct array with fields:
%    probe                :  the ndi_probe
%    epoch_id             :  the epoch id
%    thresholds           :  Is there a thresholds file for every channel? (boolean)
%    spikewaveforms_file  :  Is there a spikewaveforms_probeName_epochId.vsw file? (boolean)
%    spiketimes_file      :  Are there spiketimes_probeName_epochId.vst file? (boolean)
%

    arguments
        ndiSession {mustBeA(ndiSession, 'ndi.session')}
    end

    status = struct('probe', {}, 'epoch_id', {}, 'thresholds', {}, ...
                    'spikewaveforms_file', {}, 'spiketimes_file', {});
                
    probes = ndiSession.getprobes('type', 'n-trode');
    settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ndiSession);
    
    for i = 1:numel(probes)
        probe = probes{i};
        et = probe.epochtable();
        
        % How many channels?
        % Assuming we can get channel count from probe.
        % probe should have method to get channels or read data to check.
        % Assuming N channels if it's an n-trode? n-trode usually has specific number?
        % No, n-trode is generic.
        % We can try to read a small snippet to get channel count if not available as prop.
        try
            % Check first epoch for channel count
            if ~isempty(et)
                [d, t] = probe.readtimeseries(et(1).epoch_id, 0, 0.001);
                numChannels = size(d, 2);
            else
                numChannels = 0; 
            end
        catch
            numChannels = 0; % Cannot determine
        end
        
        for j = 1:numel(et)
            epochID = et(j).epoch_id;
            
            s = struct();
            s.probe = probe;
            s.epoch_id = epochID;
            
            % Check thresholds
            all_thresholds = true;
            if numChannels > 0
                for k = 1:numChannels
                    fname = vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID, k);
                    if ~exist(fullfile(settingsDir, fname), 'file')
                        all_thresholds = false;
                        break;
                    end
                end
            else
                all_thresholds = false; % If we don't know channels, we can't verify "every" channel
            end
            s.thresholds = all_thresholds;
            
            % Check waveforms
            wname = vhNDISpikeSorter.parameters.getSpikeWaveformFilename(probe, epochID);
            s.spikewaveforms_file = exist(fullfile(settingsDir, wname), 'file') == 2;
            
            % Check times
            tname = vhNDISpikeSorter.parameters.getSpikeTimesFilename(probe, epochID);
            s.spiketimes_file = exist(fullfile(settingsDir, tname), 'file') == 2;
            
            status(end+1) = s;
        end
    end
end
