function spikesorting(args)
% SPIKESORTING - A gui to guide a user through spikesorting multichannel LabView data
%
%   SPIKESORTING('ndiSession', ndiSession);
%
%   Brings up a graphical user interface to allow the user to set
%   thresholds/extract spikes and then cluster spikes from different name/reference
%   records.

    arguments
        args.ndiSession = [];
        args.command = 'Main';
        args.fig = [];
        args.windowheight = 380;
        args.windowwidth = 450;
        args.windowrowheight = 35;
        args.windowlabel = 'VHINTAN Spike sorting';
        args.spikesortingprefs = struct('sigma',4,'pretime',20,'usemedian',0,'MEDIAN_FILTER_ACROSS_CHANNELS',0,'SAMPLES',[-10 25],'REFRACTORY_PERIOD_SAMPLES',15);
        args.spikesortingprefs_help = {'Number of standard deviations away to set automatic threshold (default 4)',...
			'Number of seconds of data to examine to determine threshold (default 20)',...
			'0/1 Should we use the median method to determine standard deviation, or standard method? (default 0)',...
			'0/1 Should we perform a median filter across all channels? (default 0)' ...
			'What range of samples should we examine around each threshold crossing? (eg, [-10 25] is 10 before threshold until 25 after)',...
			'What is threshold crossing refractory period in samples? (default 15)' ...
};
    end

    % Unpack arguments
    ndiSession = args.ndiSession;
    command = args.command;
    fig = args.fig;
    windowheight = args.windowheight;
    windowwidth = args.windowwidth;
    windowrowheight = args.windowrowheight;
    windowlabel = args.windowlabel;
    spikesortingprefs = args.spikesortingprefs;
    spikesortingprefs_help = args.spikesortingprefs_help;

   % internal variables, for the function only
   success = 0; % although it was not used in varlist

   varlist = {'ndiSession','windowheight','windowwidth','windowrowheight','windowlabel','spikesortingprefs','spikesortingprefs_help'};

if isempty(fig),
	z = findobj(allchild(0),'flat','tag','vhNDISpikeSorter.spikesorting');
	if isempty(z),
		fig = figure('name','VHINTAN Spike Sorting','NumberTitle','off'); % we need to make a new figure
	else,
		fig = z;
		figure(fig);
		vhNDISpikeSorter.spikesorting('fig',fig,'command','UpdateNameRefList');
		return; % just pop up the existing window after updating
	end;
end;

 % initialize userdata field
if strcmp(command,'Main'),
	for i=1:length(varlist),
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end;

    % Check for preferences file
    if ~isempty(ud.ndiSession)
        prefsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ud.ndiSession);
        if ~exist(prefsDir, 'dir')
            mkdir(prefsDir);
        end
        prefsPath = fullfile(prefsDir, 'preferences.json');

        if exist(prefsPath, 'file')
            ud.params = vhNDISpikeSorter.parameters();
            ud.params = ud.params.fromJson(fileread(prefsPath));
            ud.params.spikeSortingParameters.settingsFile = prefsPath; % Ensure path is set
        else
            ud.params = vhNDISpikeSorter.parameters('settingsFile', prefsPath);
            ud.params.saveToJson();
        end
    else
        ud.params = vhNDISpikeSorter.parameters();
    end

else,
	ud = get(fig,'userdata');
end;

%command,

switch command,
	case 'Main',
		set(fig,'userdata',ud);
		vhNDISpikeSorter.spikesorting('command','NewWindow','fig',fig);
		vhNDISpikeSorter.spikesorting('fig',fig,'command','UpdateNameRefList');
	case 'NewWindow',
		% control object defaults

		% this callback was a nasty puzzle in quotations:
		callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);'];

        figcolor = get(fig, 'Color');

		button.Units = 'pixels';
                button.BackgroundColor = [0.8 0.8 0.8];
                button.HorizontalAlignment = 'center';
                button.Callback = callbackstr;
                txt.Units = 'pixels'; txt.BackgroundColor = figcolor;
                txt.fontsize = 12; txt.fontweight = 'normal';
                txt.HorizontalAlignment = 'left';txt.Style='text';
                edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
                popup = txt; popup.style = 'popupmenu';
                popup.Callback = callbackstr;
		list = txt; list.style = 'list';
        list.BackgroundColor = [1 1 1];
		list.Callback = callbackstr;
                cb = txt; cb.Style = 'Checkbox';
                cb.Callback = callbackstr;
                cb.fontsize = 12;

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrowheight;

        set(fig,'position',[50 50 right top],'tag','vhNDISpikeSorter.spikesorting');
		uicontrol(txt,'position',[5 top-row*1 600 30],'string',ud.windowlabel,'horizontalalignment','left','fontweight','bold');
        if ~isempty(ud.ndiSession)
		    uicontrol(txt,'position',[5 top-row*2 600 30],'string',ud.ndiSession.path);
        else
            uicontrol(txt,'position',[5 top-row*2 600 30],'string','No Session');
        end
		uicontrol(button,'position',[5 top-row*3 200 30],'string','Auto threshold','tag','AutoThresholdsBt');
		uicontrol(button,'position',[5 top-row*4 200 30],'string','Set/Edit thresholds/extract','tag','ThresholdsBt');
		uicontrol(list,'position',[5+210 top-row*3-200+row 200 200],'string',{' ', ' '},'Max',2, 'value',[],'tag','NameRefList');
		uicontrol(button,'position',[5 top-row*5 200 30],'string','Choose epochs to extract','tag','ExtractSelectBt');
		uicontrol(button,'position',[5 top-row*6 200 30],'string','Cluster','tag','ClusterBt');
		uicontrol(button,'position',[5 top-row*7 200 30],'string','Update','tag','UpdateBt');
		uicontrol(button,'position',[5 top-row*9 200 30],'string','Import extracted cells','tag','ImportBt');
		uicontrol(button,'position',[5 top-row*10 200 30],'string','Preferences','tag','PreferencesBt');
		set(fig,'userdata',ud);
	case 'UpdateBt',
		vhNDISpikeSorter.spikesorting('fig',fig,'command','UpdateNameRefList');
	case 'ImportBt',
		vhintan_importcells(dirstruct(ud.ndiSession.path));
	case 'ClusterBt',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		for i=1:length(v),
            p = ud.probes{v(i)};
            % Note: clusternameref now accepts (ndiSession, probe)
            vhNDISpikeSorter.clusternameref(ud.ndiSession, p);
		end;
	case 'NameRefList',
		vhNDISpikeSorter.spikesorting('fig',fig,'command','EnableDisable');
	case 'UpdateNameRefList',
        if ~isempty(ud.ndiSession)
            ud.probes = ud.ndiSession.getprobes('type', 'n-trode');

            % Get status for labeling
            status = vhNDISpikeSorter.getprobeepochstatus(ud.ndiSession);

            % Generate labels
            p_string = vhNDISpikeSorter.probestatus2labels(ud.probes, status);

            set(findobj(fig,'tag','NameRefList'),'string',p_string,'value',[]);
        else
            set(findobj(fig,'tag','NameRefList'),'string',{' '},'value',[]);
        end
		set(fig,'userdata',ud);
		vhNDISpikeSorter.spikesorting('fig',fig,'command','EnableDisable');
	case 'ThresholdsBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
        % setthresholds_gui still expects ds? No, updated to ndiSession
		vhNDISpikeSorter.setthresholds_gui('ndiSession',ud.ndiSession, 'params', ud.params);
	case 'AutoThresholdsBt',
        vhNDISpikeSorter.autothreshold_all(ud.ndiSession, ud.params);
		msgbox('Auto thresholding completed successfully.');
	case 'ExtractSelectBt',
		vhNDISpikeSorter.extractselected(ud.ndiSession, ud.params);
	case 'EnableDisable',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		if isempty(v),
			set(findobj(fig,'tag','ClusterBt'),'enable','off');
		else,
			set(findobj(fig,'tag','ClusterBt'),'enable','on');
		end;
	case 'PreferencesBt',
        p_struct = ud.params.spikeSortingParameters;
        fields = {'filter', 'autothreshold', 'events', 'process'};

        prompt = {};
        definput = {};
        map = {};

        for k=1:length(fields)
            f = fields{k};
            subfields = fieldnames(p_struct.(f));
            for j=1:length(subfields)
                sf = subfields{j};
                prompt{end+1} = [f '.' sf];
                val = p_struct.(f).(sf);
                if isnumeric(val) || islogical(val)
                    definput{end+1} = mat2str(val);
                else
                    definput{end+1} = char(val);
                end
                map{end+1} = struct('field', f, 'subfield', sf);
            end
        end

		name = 'VHNDI Spikesorter preferences';
		numlines = 1;

		answer = inputdlg(prompt,name,numlines,definput);

		try
			if ~isempty(answer)
				for i=1:length(answer)
                    f = map{i}.field;
                    sf = map{i}.subfield;
                    val = eval(answer{i});
                    ud.params.spikeSortingParameters.(f).(sf) = val;
				end
                ud.params.saveToJson();
			end
			set(fig,'userdata',ud);
		catch me
			errordlg(['Preferences were not updated due to a syntax error: ' me.message ], 'Preferences update error');
		end
end;
