function labels = probestatus2labels(probes, status)
% PROBESTATUS2LABELS Converts probe status to a label
%
%   LABELS = PROBESTATUS2LABELS(PROBES, STATUS)
%
%   Converts PROBES (cell array of ndi.probe) with accompanying 
%   STATUS (struct array from GETPROBEEPOCHSTATUS) to strings that can
%   appear in a menu or listbox.
%
%   t or T - indicates thresholding has been done (t is incomplete, T is complete)
%   e or E - indicates spike extraction has been done (e is incomplete, E is complete)
%   c or C - indicates that spike clustering has been done (c is incomplete, C is complete)

    arguments
        probes
        status
    end

    labels = {};

    for i = 1:numel(probes)
        probe = probes{i};
        
        % Filter status for this probe
        % We can compare probe objects or names/refs?
        % Assuming status struct has 'probe' field which is the object.
        % Object comparison might fail if handles differ but same underlying.
        % Safer to match by name and reference.
        
        pName = probe.name;
        pRef = probe.reference;
        
        % Find indices in status
        inds = [];
        for j=1:numel(status)
            sp = status(j).probe;
            if strcmp(sp.name, pName) && isequal(sp.reference, pRef)
                inds(end+1) = j;
            end
        end
        
        if isempty(inds)
            % No status found (maybe no epochs?)
            labels{i} = [probe.elementstring() ' |       '];
            continue;
        end
        
        probe_status = status(inds);
        num_epochs = numel(probe_status);
        
        % Thresholds
        % T if ALL epochs have thresholds=true
        % t if SOME epochs have thresholds=true
        % space if NONE
        t_count = sum([probe_status.thresholds]);
        if t_count == num_epochs && num_epochs > 0
            t_char = 'T';
        elseif t_count > 0
            t_char = 't';
        else
            t_char = ' ';
        end
        
        % Extractions (spikewaveforms_file)
        e_count = sum([probe_status.spikewaveforms_file]);
        if e_count == num_epochs && num_epochs > 0
            e_char = 'E';
        elseif e_count > 0
            e_char = 'e';
        else
            e_char = ' ';
        end
        
        % Clustering (clustered)
        % Check if field exists (I will add it to getprobeepochstatus)
        if isfield(probe_status, 'clustered')
            c_count = sum([probe_status.clustered]);
            if c_count == num_epochs && num_epochs > 0
                c_char = 'C';
            elseif c_count > 0
                c_char = 'c';
            else
                c_char = ' ';
            end
        else
            c_char = ' ';
        end
        
        % Construct label
        % "there is a space and then either a t or a T ..., and e and E ..., and C ..."
        % Format: "ProbeString | T E C"
        
        labels{i} = [probe.elementstring() ' | ' t_char ' ' e_char ' ' c_char];
    end
end
