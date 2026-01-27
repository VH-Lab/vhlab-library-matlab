classdef parameters < handle
    properties
        settingsFile (1,1) string = ""

        % Filter parameters
        filter_cheby1Order (1,1) double {mustBeNonnegative, mustBeInteger} = 4
        filter_cheby1Rolloff (1,1) double {mustBeGreaterThan(filter_cheby1Rolloff, 0), mustBeLessThan(filter_cheby1Rolloff, 1)} = 0.8
        filter_cheby1Cutoff (1,1) double {mustBePositive} = 300
        filter_medianFilterAcrossChannels (1,1) logical = false

        % Autothreshold parameters
        autothreshold_sigma (1,1) double {mustBePositive} = 4
        autothreshold_readTime (1,1) double {mustBePositive} = 100
        autothreshold_useMedian (1,1) logical = false

        % Events parameters
        events_samples (1,2) double {mustBeInteger} = [-10 25]
        events_refractoryPeriodSamples (1,1) double {mustBeNonnegative, mustBeInteger} = 15
        events_centerRange (1,1) double {mustBeNonnegative, mustBeInteger} = 10

        % Process parameters
        process_chunkTime (1,1) double {mustBePositive} = 20
        process_overlap (1,1) double {mustBeNonnegative} = 0.05
        process_progressBar (1,1) logical = true
    end

    properties (Dependent)
        spikeSortingParameters
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

            % Assign arguments to properties
            obj.settingsFile = args.settingsFile;

            obj.filter_cheby1Order = args.filter_cheby1Order;
            obj.filter_cheby1Rolloff = args.filter_cheby1Rolloff;
            obj.filter_cheby1Cutoff = args.filter_cheby1Cutoff;
            obj.filter_medianFilterAcrossChannels = args.filter_medianFilterAcrossChannels;

            obj.autothreshold_sigma = args.autothreshold_sigma;
            obj.autothreshold_readTime = args.autothreshold_readTime;
            obj.autothreshold_useMedian = args.autothreshold_useMedian;

            obj.events_samples = args.events_samples;
            obj.events_refractoryPeriodSamples = args.events_refractoryPeriodSamples;
            obj.events_centerRange = args.events_centerRange;

            obj.process_chunkTime = args.process_chunkTime;
            obj.process_overlap = args.process_overlap;
            obj.process_progressBar = args.process_progressBar;
        end

        function s = get.spikeSortingParameters(obj)
            s.settingsFile = obj.settingsFile;
            s.filter.cheby1Order = obj.filter_cheby1Order;
            s.filter.cheby1Rolloff = obj.filter_cheby1Rolloff;
            s.filter.cheby1Cutoff = obj.filter_cheby1Cutoff;
            s.filter.medianFilterAcrossChannels = obj.filter_medianFilterAcrossChannels;

            s.autothreshold.sigma = obj.autothreshold_sigma;
            s.autothreshold.readTime = obj.autothreshold_readTime;
            s.autothreshold.useMedian = obj.autothreshold_useMedian;

            s.events.samples = obj.events_samples;
            s.events.refractoryPeriodSamples = obj.events_refractoryPeriodSamples;
            s.events.centerRange = obj.events_centerRange;

            s.process.chunkTime = obj.process_chunkTime;
            s.process.overlap = obj.process_overlap;
            s.process.progressBar = obj.process_progressBar;
        end

        function set.spikeSortingParameters(obj, s)
            if isfield(s, 'settingsFile'), obj.settingsFile = s.settingsFile; end
            if isfield(s, 'filter')
                f = s.filter;
                if isfield(f, 'cheby1Order'), obj.filter_cheby1Order = f.cheby1Order; end
                if isfield(f, 'cheby1Rolloff'), obj.filter_cheby1Rolloff = f.cheby1Rolloff; end
                if isfield(f, 'cheby1Cutoff'), obj.filter_cheby1Cutoff = f.cheby1Cutoff; end
                if isfield(f, 'medianFilterAcrossChannels'), obj.filter_medianFilterAcrossChannels = f.medianFilterAcrossChannels; end
            end
            if isfield(s, 'autothreshold')
                a = s.autothreshold;
                if isfield(a, 'sigma'), obj.autothreshold_sigma = a.sigma; end
                if isfield(a, 'readTime'), obj.autothreshold_readTime = a.readTime; end
                if isfield(a, 'useMedian'), obj.autothreshold_useMedian = a.useMedian; end
            end
            if isfield(s, 'events')
                e = s.events;
                if isfield(e, 'samples'), obj.events_samples = e.samples; end
                if isfield(e, 'refractoryPeriodSamples'), obj.events_refractoryPeriodSamples = e.refractoryPeriodSamples; end
                if isfield(e, 'centerRange'), obj.events_centerRange = e.centerRange; end
            end
            if isfield(s, 'process')
                p = s.process;
                if isfield(p, 'chunkTime'), obj.process_chunkTime = p.chunkTime; end
                if isfield(p, 'overlap'), obj.process_overlap = p.overlap; end
                if isfield(p, 'progressBar'), obj.process_progressBar = p.progressBar; end
            end
        end

        function jsonStr = toJson(obj)
            % Encode only obj.spikeSortingParameters (dependent property)
            jsonStr = jsonencode(obj.spikeSortingParameters, 'PrettyPrint', true);
        end

        function obj = fromJson(obj, jsonStr)
            data = jsondecode(jsonStr);
            % Use dependent property setter
            obj.spikeSortingParameters = data;
        end

        function saveToJson(obj, filename)
            if nargin < 2
                filename = obj.settingsFile;
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
        function p = spikeSortingPath(ndiSession)
            if nargin < 1
                error('ndiSession argument is required.');
            end
            p = fullfile(ndiSession.path, 'vhNDISorter');
        end

        function filename = getThresholdLevelFilename(probe, epochID)
            % Use elementstring and sanitize
            if ischar(probe) || isstring(probe)
                pName = probe;
            elseif ismethod(probe, 'elementstring')
                pName = probe.elementstring();
            elseif isprop(probe, 'elementstring')
                pName = probe.elementstring;
            elseif isprop(probe, 'name')
                pName = probe.name;
            else
                % Fallback or error
                pName = 'unknown_probe';
            end

            % Sanitize pName: replace whitespace and '|'
            pName = char(pName); % Ensure char for manipulation
            pName(isspace(pName)) = '_';
            pName = replace(pName, '|', '_');

            filename = [pName '_' char(epochID) '.txt'];
        end

        function filename = getSpikeWaveformFilename(probe, epochID)
             if ischar(probe) || isstring(probe)
                pName = probe;
            elseif ismethod(probe, 'elementstring')
                pName = probe.elementstring();
            elseif isprop(probe, 'elementstring')
                pName = probe.elementstring;
            elseif isprop(probe, 'name')
                pName = probe.name;
            else
                pName = 'unknown_probe';
            end

            pName = char(pName);
            pName(isspace(pName)) = '_';
            pName = replace(pName, '|', '_');

            filename = [pName '_' char(epochID) '.vsw'];
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
