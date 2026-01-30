function extractselected(ndiSession, params)
% EXTRACTSELECTED - Extract spikes from user-specified epochs for a given session
%
%    EXTRACTSELECTED(NDISESSION, PARAMS)
%
%    Extracts spikes from user-specified epochs in the NDI session.
%    The user is presented with dialog boxes to choose probes and then epochs.
%
%    NDISESSION is an ndi.session object.
%    PARAMS is a vhNDISpikeSorter.parameters object.
%

    arguments
        ndiSession {mustBeA(ndiSession, 'ndi.session')}
        params {mustBeA(params, 'vhNDISpikeSorter.parameters')}
    end

    % Step 1: Select Probes
    probes = ndiSession.getprobes('type', 'n-trode');
    if isempty(probes)
        msgbox('No n-trode probes found in session.');
        return;
    end
    
    probe_names = {};
    for i=1:numel(probes)
        probe_names{i} = probes{i}.elementstring();
    end
    
    [s_probes, ok] = listdlg('PromptString', 'Select probes to extract', ...
                             'SelectionMode', 'multiple', ...
                             'ListString', probe_names);
    
    if ~ok || isempty(s_probes)
        return;
    end
    
    selected_probes = probes(s_probes);
    
    % Step 2: Select Epochs for each probe (or aggregate?)
    % The prompt says: "The user should first choose from a list of probes. Then the program should build up a list of epochs from those probes that the user selects. Then the program should loop over calls to extractwaveforms..."
    
    % Get all unique epoch IDs across selected probes? Or allow selecting epochs available to ALL?
    % Or list all [Probe - Epoch] combinations?
    % "build up a list of epochs from those probes that the user selects"
    % Often we want to extract the same epochs for all probes.
    % Let's get union of epochs or intersection?
    % Or list all epochs present in ANY of the probes?
    % Let's assume we list all unique epoch IDs found in the selected probes.
    
    all_epoch_ids = {};
    probe_map = struct(); % Map epochID to list of probes that have it
    
    for i=1:numel(selected_probes)
        et = selected_probes{i}.epochtable();
        for j=1:numel(et)
            eid = et(j).epoch_id;
            all_epoch_ids = [all_epoch_ids; eid];
            if ~isfield(probe_map, ['e_' eid]) % fields must be valid chars
                 % We can just store usage count or check existence later
            end
        end
    end
    all_epoch_ids = unique(all_epoch_ids);
    
    if isempty(all_epoch_ids)
        msgbox('No epochs found for selected probes.');
        return;
    end
    
    [s_epochs, ok] = listdlg('PromptString', 'Select epochs to extract', ...
                             'SelectionMode', 'multiple', ...
                             'ListString', all_epoch_ids);
                         
    if ~ok || isempty(s_epochs)
        return;
    end
    
    selected_epochs = all_epoch_ids(s_epochs);
    
    % Step 3: Loop and Extract
    % Loop over selected probes, and for each, loop over selected epochs IF the probe has that epoch.
    
    % Parallel processing?
    % Check preferences or assume serial for now unless specified.
    % "Then the program should loop over calls to extractwaveforms to get it done."
    
    % We can use parallel pool if available.
    use_parallel = false; % Make optional later?
    
    disp('Starting extraction...');
    
    for i=1:numel(selected_probes)
        p = selected_probes{i};
        et = p.epochtable();
        p_epochs = {et.epoch_id};
        
        for j=1:numel(selected_epochs)
            eid = selected_epochs{j};
            if ismember(eid, p_epochs)
                disp(['Extracting Probe: ' p.elementstring() ', Epoch: ' eid]);
                try
                    vhNDISpikeSorter.extractwaveforms(p, eid, params);
                catch err
                    warning('Extraction failed for %s / %s: %s', p.elementstring(), eid, err.message);
                end
            end
        end
    end
    
    disp('Extraction finished.');
end
