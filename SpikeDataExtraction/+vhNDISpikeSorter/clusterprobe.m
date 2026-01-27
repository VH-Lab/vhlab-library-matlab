function clusterprobe(ndiSession, probe)
% CLUSTERPROBE - Cluster spikes for a probe
%
%   CLUSTERPROBE(NDISESSION, PROBE)
%
%  Prompts user to cluster spike waveforms for the PROBE in the NDI session.
%  Reads extracted waveforms and times from the spike sorting directory.
%  Saves sorted spike times per epoch and cluster info per probe.
%
%  NDISESSION is an ndi.session object.
%  PROBE is an ndi.probe object.

    arguments
        ndiSession {mustBeA(ndiSession, 'ndi.session')}
        probe {mustBeA(probe, 'ndi.probe')}
    end

    % step 1 - load in the spikes

    settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ndiSession);

    et = probe.epochtable();
    epochIDs = {et.epoch_id};

    waves = [];
    epochinds = [];
    times = [];

    EpochStartSamples = [];
    EpochNames = epochIDs;

    header = [];

    for i=1:length(epochIDs)
        epochID = epochIDs{i};

        EpochStartSamples(end+1) = length(times)+1;

        wfile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getSpikeWaveformFilename(probe, epochID));
        tfile = fullfile(settingsDir, vhNDISpikeSorter.parameters.getSpikeTimesFilename(probe, epochID));

        if exist(wfile, 'file') && exist(tfile, 'file')
            [spikewaveforms, h] = readvhlspikewaveformfile(wfile);
            if isempty(header), header = h; end

            try
                waves = cat(3, waves, spikewaveforms);
            catch
                % Dimension mismatch or empty
            end

            fid = fopen(tfile, 'r', 'ieee-le');
            if fid > 0
                spiketimes = fread(fid, 'float64');
                fclose(fid);
                times = [times; spiketimes];
                epochinds = [epochinds; i*ones(size(spiketimes))];
            end
        end
    end

    if isempty(waves)
        msgbox('No extracted waveforms found for this probe.');
        return;
    end

    % step 2 - cluster the spikes
    [clusterids,CI] = cluster_spikewaves_gui('waves',waves,'waveparameters',header,'windowlabel',['Sort spikes for ' probe.elementstring()],...
        'ClusterRightAway',0,'EpochStartSamples',EpochStartSamples,'EpochNames',EpochNames);

    clusterlist = unique(clusterids);
    if any(isnan(clusterlist)), clusterlist = clusterlist(1:find(isnan(clusterlist),1,'first')); end;

    % step 3 - write the spike times back to disk

    % Clean existing per-probe cluster files?
    % We should clean existing files for THIS probe.
    % Maybe list all cluster info files for this probe and delete.
    % Pattern: clusterinfo_PNAME_*.mat
    pName = probe.elementstring();
    pName = char(pName); pName(isspace(pName)) = '_'; pName = replace(pName, '|', '_');

    existingInfo = dir(fullfile(settingsDir, ['clusterinfo_' pName '_*.mat']));
    for k=1:length(existingInfo)
        delete(fullfile(settingsDir, existingInfo(k).name));
    end

    % Also clean existing sorted times files for this probe across all epochs
    % Pattern: sorted_spiketimes_PNAME_EPOCHID_*.txt
    % This is harder to glob if EPOCHID varies.
    % We can loop epochs and clean.
    for i=1:length(epochIDs)
        eID = epochIDs{i};
        existingTimes = dir(fullfile(settingsDir, ['sorted_spiketimes_' pName '_' eID '_*.txt']));
        for k=1:length(existingTimes)
            delete(fullfile(settingsDir, existingTimes(k).name));
        end
    end

    for j=1:length(clusterlist)
        clusterID = clusterlist(j);

        % Save Cluster Info (Per Probe)
        clusterinfo = CI(j);
        infoFname = vhNDISpikeSorter.parameters.getClusterInfoFilename(probe, clusterID);
        save(fullfile(settingsDir, infoFname), 'clusterinfo', '-mat');

        % Save Spike Times (Per Epoch)
        for i=1:length(epochIDs)
            epochID = epochIDs{i};
            epochinds_here = find(epochinds==i);

            clusterinds = find(clusterids(epochinds_here)==clusterID);
            timeshere = times(epochinds_here(clusterinds));

            % Filename: sorted_spiketimes_PNAME_EPOCHID_00M.txt
            fname = vhNDISpikeSorter.parameters.getClusterSpikeTimesFilename(probe, clusterID, epochID);
            dlmwrite(fullfile(settingsDir, fname), timeshere, 'delimiter', ' ', 'precision', 10);
        end
    end
end
