classdef parameters
    properties
        parameters = struct('settingsFile', "", ...
            'filter', struct('cheby1Order', 4, ...
                        'cheby1Rolloff', 0.8, ...
                        'cheby1Cutoff', 300, ...
                        'medianFilterAcrossChannels', false), ...
            'autothreshold', struct('sigma', 4, ...
                               'readTime', 100, ...
                               'useMedian', false), ...
            'events', struct('samples', [-10 25], ...
                        'refractoryPeriodSamples', 15, ...
                        'centerRange', 10), ...
            'process', struct('chunkTime', 20, ...
                         'overlap', 0.05, ...
                         'progressBar', true) ...
             )
    end

    methods
        function obj = parameters(args)
            arguments
                args.settingsFile (1,1) string = ""
                args.filter struct = struct('cheby1Order', 4, ...
                        'cheby1Rolloff', 0.8, ...
                        'cheby1Cutoff', 300, ...
                        'medianFilterAcrossChannels', false)
                args.autothreshold struct = struct('sigma', 4, ...
                               'readTime', 100, ...
                               'useMedian', false)
                args.events struct = struct('samples', [-10 25], ...
                        'refractoryPeriodSamples', 15, ...
                        'centerRange', 10)
                args.process struct = struct('chunkTime', 20, ...
                         'overlap', 0.05, ...
                         'progressBar', true)
            end

            % Update substructures merging with defaults
            obj.parameters.filter = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.filter, args.filter);
            obj.parameters.autothreshold = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.autothreshold, args.autothreshold);
            obj.parameters.events = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.events, args.events);
            obj.parameters.process = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.process, args.process);

            if args.settingsFile ~= ""
                obj.parameters.settingsFile = args.settingsFile;
            end
        end

        function jsonStr = toJson(obj)
            % Encode only obj.parameters
            jsonStr = jsonencode(obj.parameters, 'PrettyPrint', true);
        end

        function obj = fromJson(obj, jsonStr)
            data = jsondecode(jsonStr);

            % We expect data to map to fields of obj.parameters
            if isfield(data, 'settingsFile')
                 obj.parameters.settingsFile = data.settingsFile;
            end

            if isfield(data, 'filter')
                obj.parameters.filter = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.filter, data.filter);
            end
            if isfield(data, 'autothreshold')
                obj.parameters.autothreshold = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.autothreshold, data.autothreshold);
            end
            if isfield(data, 'events')
                obj.parameters.events = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.events, data.events);
            end
            if isfield(data, 'process')
                obj.parameters.process = vhNDISpikeSorter.parameters.mergeStructs(obj.parameters.process, data.process);
            end
        end

        function saveToJson(obj, filename)
            if nargin < 2
                filename = obj.parameters.settingsFile;
            end

            if filename == ""
                error('No filename specified and settingsFile is empty.');
            end

            % Ensure directory exists
            d = fileparts(filename);
            if ~isempty(d) && ~exist(d, 'dir')
                mkdir(d);
            end

            str = obj.toJson();

            fid = fopen(filename, 'w');
            if fid == -1
                error(['Could not open file ' filename ' for writing.']);
            end
            fprintf(fid, '%s', str);
            fclose(fid);
        end
    end

    methods (Static)
        function filename = getThresholdLevelFilename(probe, epochID)
            % probe is likely an object, we need its name?
            % The prompt says "probeName" in the description: [probeName ‘_’ epochID ‘.txt’]
            % If probe is an object, maybe probe.name? Or probe is a string?
            % "getThresholdLevelFilename (probe, epochID)"
            % Assuming probe is the name string or object with name.
            if ischar(probe) || isstring(probe)
                pName = probe;
            elseif isprop(probe, 'name')
                pName = probe.name;
            else
                % Fallback or error
                pName = 'unknown_probe';
            end
            filename = [char(pName) '_' char(epochID) '.txt'];
        end

        function filename = getSpikeWaveformFilename(probe, epochID)
             if ischar(probe) || isstring(probe)
                pName = probe;
            elseif isprop(probe, 'name')
                pName = probe.name;
            else
                pName = 'unknown_probe';
            end
            filename = [char(pName) '_' char(epochID) '.vsw'];
        end

        function s_out = mergeStructs(s_default, s_new)
            s_out = s_default;
            if isempty(s_new)
                return;
            end
            fields = fieldnames(s_new);
            for i = 1:length(fields)
                if isfield(s_out, fields{i})
                    s_out.(fields{i}) = s_new.(fields{i});
                end
            end
        end
    end
end
