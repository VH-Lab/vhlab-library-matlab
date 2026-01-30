function autothreshold_all(ndiSession, params)
% AUTOTHRESHOLD_ALL - Perform automatic spike threshold determination on all records
%
%   AUTOTHREHSOLD_ALL(NDISESSION, PARAMS)
%
%   Perform automatic spike threshold determination on all records in
%   the NDI session. 
%
%   NDISESSION is an ndi.session object.
%   PARAMS is a vhNDISpikeSorter.parameters object.
%

    arguments
        ndiSession {mustBeA(ndiSession, 'ndi.session')}
        params {mustBeA(params, 'vhNDISpikeSorter.parameters')}
    end
    
    % Get all n-trode probes
    probes = ndiSession.getprobes('type', 'n-trode');

    % Loop over probes
    for i = 1:numel(probes)
        probe = probes{i};
        et = probe.epochtable();
        
        % Loop over epochs
        for j = 1:numel(et)
            epochID = et(j).epoch_id;
            vhNDISpikeSorter.autothreshold_epoch(probe, epochID, params);
        end
    end
