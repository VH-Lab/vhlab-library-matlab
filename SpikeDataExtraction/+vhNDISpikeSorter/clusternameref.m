function clusternameref(ndiSession, probe)
% CLUSTERNAMEREF - Cluster spikes for a probe
%
%   CLUSTERNAMEREF(NDISESSION, PROBE)
%
%  Prompts user to cluster spike waveforms for the PROBE in the NDI session.
%  Reads extracted waveforms and times from the spike sorting directory.
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
    % Use epoch IDs as "dirlist" equivalent
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
                % Dimension mismatch or empty?
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
    % Where to write?
    % Previous: intan_st_name_ref_00M.txt in epoch dir.
    % Now: We should probably write to settingsDir using consistent naming?
    % The prompt for `import_sorted_units` expected `intan_st_...`
    % If we want to maintain compatibility or update:
    % Prompt said: "Update the clustering method so it reads from these locations, too"
    % It didn't explicitly say where to write, but `import` step relies on output.
    % I will write to `settingsDir` with filenames: `intan_st_PROBENAME_EPOCHID_CLUSTER.txt`?
    % Or if `clusternameref` writes per epoch...
    % The previous `clusternameref` wrote separate files per epoch.
    % I should maintain that but maybe locate them in `settingsDir`.
    % Filename pattern: `sorted_spikes_PROBENAME_EPOCHID_CLUSTER.txt`?
    % The `import` function I wrote looks for `intan_st_NAME_REF_*.txt`.
    % That pattern assumes per-probe (name_ref) files, not per-epoch?
    % Wait, my `import` function looped over epochs and looked for `intan_st_NAME_REF_*.txt` inside `epochDir`.
    % If `epochDir` is now `settingsDir`? No, `settingsDir` is centralized.
    % If I write all files to `settingsDir`, they need to be distinguished by EpochID.
    % The legacy `intan_st_NAME_REF_CLUSTER.txt` naming convention assumes it's inside an epoch directory.
    % If I put them in `settingsDir`, I must include `EpochID` in filename.
    % `intan_st_NAME_REF_EPOCHID_CLUSTER.txt`.
    % AND I must update `import` to look for that pattern in `settingsDir`.

    % Let's update naming to be:
    % `sorted_spikes_ELEMENTSTRING_EPOCHID_CLUSTER.txt`
    % (Sanitized elementstring).
    % Or use `getSpikeTimesFilename` base?

    pName = probe.elementstring();
    pName = char(pName); pName(isspace(pName)) = '_'; pName = replace(pName, '|', '_');

    fname_prefix = ['sorted_st_' pName '_'];
    infofname_prefix = ['sorted_ci_' pName '_'];

    for i=1:length(epochIDs)
        epochID = epochIDs{i};

        epochinds_here = find(epochinds==i);

        % Clean existing?
        % Pattern: sorted_st_PNAME_EPOCHID_*.txt
        existing = dir(fullfile(settingsDir, [fname_prefix epochID '_*.txt']));
        for k=1:length(existing)
            delete(fullfile(settingsDir, existing(k).name));
        end
        % Info files
        existingInfo = dir(fullfile(settingsDir, [infofname_prefix epochID '_*.mat']));
        for k=1:length(existingInfo)
            delete(fullfile(settingsDir, existingInfo(k).name));
        end

        for j=1:length(clusterlist)
            clusterinds = find(clusterids(epochinds_here)==clusterlist(j));
            timeshere = times(epochinds_here(clusterinds));

            % Filename: sorted_st_PNAME_EPOCHID_00M.txt
            fname = [fname_prefix epochID '_' sprintf('%0.3d', clusterlist(j)) '.txt'];
            dlmwrite(fullfile(settingsDir, fname), timeshere, 'delimiter', ' ', 'precision', 10);

            clusterinfo = CI(j);
            infofname = [infofname_prefix epochID '_' sprintf('%0.3d', clusterlist(j)) '.mat'];
            save(fullfile(settingsDir, infofname), 'clusterinfo', '-mat');
        end
    end
end
