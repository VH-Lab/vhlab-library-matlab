function spikesorting(args)
% SPIKESORTING - A gui to guide a user through spikesorting multichannel LabView data
%
%   SPIKESORTING('S', S);
%
%   Brings up a graphical user interface to allow the user to set
%   thresholds/extract spikes and then cluster spikes from different name/reference
%   records.

    arguments
        args.S = [];
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
    S = args.S;
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

   varlist = {'S','windowheight','windowwidth','windowrowheight','windowlabel','spikesortingprefs','spikesortingprefs_help'};

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

		button.Units = 'pixels';
                button.BackgroundColor = [0.8 0.8 0.8];
                button.HorizontalAlignment = 'center';
                button.Callback = callbackstr;
                txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
                txt.fontsize = 12; txt.fontweight = 'normal';
                txt.HorizontalAlignment = 'left';txt.Style='text';
                edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
                popup = txt; popup.style = 'popupmenu';
                popup.Callback = callbackstr;
		list = txt; list.style = 'list';
		list.Callback = callbackstr;
                cb = txt; cb.Style = 'Checkbox';
                cb.Callback = callbackstr;
                cb.fontsize = 12;

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrowheight;

        set(fig,'position',[50 50 right top],'tag','vhNDISpikeSorter.spikesorting');
		uicontrol(txt,'position',[5 top-row*1 600 30],'string',ud.windowlabel,'horizontalalignment','left','fontweight','bold');
        if ~isempty(ud.S)
		    uicontrol(txt,'position',[5 top-row*2 600 30],'string',ud.S.path);
        else
            uicontrol(txt,'position',[5 top-row*2 600 30],'string','No Session');
        end
		uicontrol(button,'position',[5 top-row*3 200 30],'string','Auto threshold','tag','AutoThresholdsBt');
		uicontrol(button,'position',[5 top-row*4 200 30],'string','Set/Edit thresholds/extract','tag','ThresholdsBt');
		uicontrol(list,'position',[5+210 top-row*3-200+row 200 200],'string',{' ', ' '},'Max',2, 'value',[],'tag','NameRefList');
		uicontrol(button,'position',[5 top-row*5 200 30],'string','Choose directories to extract','tag','ExtractSelectBt');
		uicontrol(button,'position',[5 top-row*6 200 30],'string','Cluster','tag','ClusterBt');
		uicontrol(button,'position',[5 top-row*7 200 30],'string','Update','tag','UpdateBt');
		uicontrol(button,'position',[5 top-row*9 200 30],'string','Import extracted cells','tag','ImportBt');
		uicontrol(button,'position',[5 top-row*10 200 30],'string','Preferences','tag','PreferencesBt');
		set(fig,'userdata',ud);
	case 'UpdateBt',
		vhNDISpikeSorter.spikesorting('fig',fig,'command','UpdateNameRefList');
	case 'ImportBt',
		vhintan_importcells(dirstruct(ud.S.path));
	case 'ClusterBt',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		for i=1:length(v),
            % Convert probes to ds/name/ref if needed or update clusternameref to accept probes
            % For now, pass dirstruct and probe name/ref if possible.
            % But S.getprobes returns probe objects.
            % 'clusternameref' expects (ds, name, ref).
            % We can reconstruct ds from S.path.
            % What is name/ref for a probe? probe.name and probe.reference?
            % Assuming probe objects have these properties.

            p = ud.probes{v(i)};
            % Assuming probe.name and probe.reference exist or equivalent
            % If strictly following prompt "use NDI sessions (S)", downstream might need update.
            % But prompt specifically targeted spikesorting.
            % I'll try to adapt arguments for clusternameref using probe info.
            % S.getprobes() returns cell array of probes.
            % p is a probe object.

            % If p has elementstring(), maybe I can parse it or it has properties.
            % NDI probes usually have 'name' and 'reference' properties or methods.
            % Let's assume standard NDI probe structure or check valid properties if I could.
            % I will assume p.name and p.reference.

            % Note: clusternameref expects a dirstruct as first arg.
            ds = dirstruct(ud.S.path);
            vhNDISpikeSorter.clusternameref(ds, p.name, p.reference);
		end;
	case 'NameRefList',
		vhNDISpikeSorter.spikesorting('fig',fig,'command','EnableDisable');
	case 'UpdateNameRefList',
		% ud.ds = dirstruct(getpathname(ud.ds)); % Old
        % ud.nr = getallnamerefs(ud.ds); % Old

        ud.probes = ud.S.getprobes();

		p_string = {};
		for i=1:numel(ud.probes),
			p_string{i} = ud.probes{i}.elementstring();
		end;
		set(findobj(fig,'tag','NameRefList'),'string',p_string,'value',[]);
		set(fig,'userdata',ud);
		vhNDISpikeSorter.spikesorting('fig',fig,'command','EnableDisable');
	case 'ThresholdsBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
        % setthresholds_gui still expects ds.
        ds = dirstruct(ud.S.path);
		vhNDISpikeSorter.setthresholds_gui('ds',ds,prefs{:});
	case 'AutoThresholdsBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
        ds = dirstruct(ud.S.path);
		vhNDISpikeSorter.autothreshold_all(ds,prefs{:});
		msgbox('Auto thresholding completed successfully.');
	case 'ExtractSelectBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
		vhNDISpikeSorter.extractselected(ud.S.path,prefs{:});
	case 'EnableDisable',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		if isempty(v),
			set(findobj(fig,'tag','ClusterBt'),'enable','off');
		else,
			set(findobj(fig,'tag','ClusterBt'),'enable','on');
		end;
	case 'PreferencesBt',
		name = 'VHINTAN Spikesorting preferences';
		prompt = ud.spikesortingprefs_help;
		numlines = 1;
		values = {};
		fn = fieldnames(ud.spikesortingprefs);
		for i=1:length(fn),
			values{i} = mat2str(getfield(ud.spikesortingprefs,fn{i}));
		end;
		answer = inputdlg(prompt,name,numlines,values);
		try,
			if ~isempty(answer),
				for i=1:length(answer),
					ud.spikesortingprefs = setfield(ud.spikesortingprefs,fn{i},eval(answer{i}));
				end;
			end;
			set(fig,'userdata',ud);
		catch,
			errordlg(['Preferences were not updated due to a syntax error: ' lasterr ], 'Preferences update error');
		end;
end;
