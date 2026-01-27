classdef parameters
    properties
        spikeSortingParameters = struct('settingsFile', "", ...
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

                % Filter parameters
                args.filter_cheby1Order (1,1) double {mustBeNonnegative, mustBeInteger} = 4
                args.filter_cheby1Rolloff (1,1) double {mustBeGreaterThan(args.filter_cheby1Rolloff, 0), mustBeLessThan(args.filter_cheby1Rolloff, 1)} = 0.8
                args.filter_cheby1Cutoff (1,1) double {mustBePositive} = 300
                args.filter_medianFilterAcrossChannels (1,1) logical = false

                % Autothreshold parameters
                args.autothreshold_sigma (1,1) double {mustBePositive} = 4
                args.autothreshold_readTime (1,1) double {mustBePositive} = 100
                args.autothreshold_useMedian (1,1) logical = false

                % Events parameters
                args.events_samples (1,2) double {mustBeInteger} = [-10 25]
                args.events_refractoryPeriodSamples (1,1) double {mustBeNonnegative, mustBeInteger} = 15
                args.events_centerRange (1,1) double {mustBeNonnegative, mustBeInteger} = 10

                % Process parameters
                args.process_chunkTime (1,1) double {mustBePositive} = 20
                args.process_overlap (1,1) double {mustBeNonnegative} = 0.05
                args.process_progressBar (1,1) logical = true
            end

            % Assign arguments to structure
            obj.spikeSortingParameters.settingsFile = args.settingsFile;

            obj.spikeSortingParameters.filter.cheby1Order = args.filter_cheby1Order;
            obj.spikeSortingParameters.filter.cheby1Rolloff = args.filter_cheby1Rolloff;
            obj.spikeSortingParameters.filter.cheby1Cutoff = args.filter_cheby1Cutoff;
            obj.spikeSortingParameters.filter.medianFilterAcrossChannels = args.filter_medianFilterAcrossChannels;

            obj.spikeSortingParameters.autothreshold.sigma = args.autothreshold_sigma;
            obj.spikeSortingParameters.autothreshold.readTime = args.autothreshold_readTime;
            obj.spikeSortingParameters.autothreshold.useMedian = args.autothreshold_useMedian;

            obj.spikeSortingParameters.events.samples = args.events_samples;
            obj.spikeSortingParameters.events.refractoryPeriodSamples = args.events_refractoryPeriodSamples;
            obj.spikeSortingParameters.events.centerRange = args.events_centerRange;

            obj.spikeSortingParameters.process.chunkTime = args.process_chunkTime;
            obj.spikeSortingParameters.process.overlap = args.process_overlap;
            obj.spikeSortingParameters.process.progressBar = args.process_progressBar;
        end

        function jsonStr = toJson(obj)
            % Encode only obj.spikeSortingParameters
            jsonStr = jsonencode(obj.spikeSortingParameters, 'PrettyPrint', true);
        end

        function obj = fromJson(obj, jsonStr)
            data = jsondecode(jsonStr);

            % We expect data to map to fields of obj.spikeSortingParameters
            if isfield(data, 'settingsFile')
                 obj.spikeSortingParameters.settingsFile = data.settingsFile;
            end

            if isfield(data, 'filter')
                obj.spikeSortingParameters.filter = vhNDISpikeSorter.parameters.mergeStructs(obj.spikeSortingParameters.filter, data.filter);
            end
            if isfield(data, 'autothreshold')
                obj.spikeSortingParameters.autothreshold = vhNDISpikeSorter.parameters.mergeStructs(obj.spikeSortingParameters.autothreshold, data.autothreshold);
            end
            if isfield(data, 'events')
                obj.spikeSortingParameters.events = vhNDISpikeSorter.parameters.mergeStructs(obj.spikeSortingParameters.events, data.events);
            end
            if isfield(data, 'process')
                obj.spikeSortingParameters.process = vhNDISpikeSorter.parameters.mergeStructs(obj.spikeSortingParameters.process, data.process);
            end
        end

        function saveToJson(obj, filename)
            if nargin < 2
                filename = obj.spikeSortingParameters.settingsFile;
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
