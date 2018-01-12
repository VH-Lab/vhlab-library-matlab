function vhspike2_spikesorting(varargin)
% VHSPIKE2_SPIKESORTING - A gui to guide a user through spikesorting multichannel LabView data
%
%   VHSPIKE2_SPIKESORTING('DS', DS);
%
%   Brings up a graphical user interface to allow the user to set 
%   thresholds/extract spikes and then cluster spikes from different name/reference
%   records.

  % add number of spikes to cluster info, compute mean waveforms
   
 % internal variables, for the function only

command = 'Main';    % internal variable, the command
fig = '';                 % the figure
success = 0;
windowheight = 380;
windowwidth = 450;
windowrowheight = 35;

 % user-specified variables
ds = [];               % dirstruct
windowlabel = 'VHSPIKE2 Spike sorting';

spikesortingprefs = struct('sigma',4,'pretime',20,'usemedian',0,'MEDIAN_FILTER_ACROSS_CHANNELS',0,'SAMPLES',[-10 25],'REFRACTORY_PERIOD_SAMPLES',15);

spikesortingprefs_help = {'Number of standard deviations away to set automatic threshold (default 4)',...
			'Number of seconds of data to examine to determine threshold (default 20)',...
			'0/1 Should we use the median method to determine standard deviation, or standard method? (default 0)',...
			'0/1 Should we perform a median filter across all channels? (default 0)' ...
			'What range of samples should we examine around each threshold crossing? (eg, [-10 25] is 10 before threshold until 25 after)',...
			'What is threshold crossing refractory period in samples? (default 15)' ...
};


varlist = {'ds','windowheight','windowwidth','windowrowheight','windowlabel','spikesortingprefs','spikesortingprefs_help'};

assign(varargin{:});

if isempty(fig),
	z = findobj(allchild(0),'flat','tag','vhspike2_spikesorting');
	if isempty(z),
		fig = figure('name','VHSPIKE2 Spike Sorting','NumberTitle','off'); % we need to make a new figure
	else,
		fig = z;
		figure(fig);
		vhspike2_spikesorting('fig',fig,'command','UpdateNameRefList');
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
		vhspike2_spikesorting('command','NewWindow','fig',fig);
		vhspike2_spikesorting('fig',fig,'command','UpdateNameRefList');
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

        set(fig,'position',[50 50 right top],'tag','vhspike2_spikesorting');
		uicontrol(txt,'position',[5 top-row*1 600 30],'string',ud.windowlabel,'horizontalalignment','left','fontweight','bold');
		uicontrol(txt,'position',[5 top-row*2 600 30],'string',getpathname(ud.ds));
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
		vhspike2_spikesorting('fig',fig,'command','UpdateNameRefList');
	case 'ImportBt',
		vhspike2_importcells(ud.ds);
	case 'ClusterBt',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		for i=1:length(v),
			vhspike2_clusternameref(ud.ds,ud.nr(v(i)).name,ud.nr(v(i)).ref);
		end;
	case 'NameRefList',
		vhspike2_spikesorting('fig',fig,'command','EnableDisable');
	case 'UpdateNameRefList',
		ud.ds = dirstruct(getpathname(ud.ds));
		ud.nr = getallnamerefs(ud.ds);
		str = {};
		for i=1:length(ud.nr),
			str{i} = [ud.nr(i).name ' | ' int2str(ud.nr(i).ref)];
		end;
		set(findobj(fig,'tag','NameRefList'),'string',str,'value',[]);
		set(fig,'userdata',ud);
		vhspike2_spikesorting('fig',fig,'command','EnableDisable');
	case 'ThresholdsBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
		vhspike2_setthresholds_gui('ds',ud.ds,prefs{:});
	case 'AutoThresholdsBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
		vhspike2_autothreshold_all(ud.ds,prefs{:});
		msgbox('Auto thresholding completed successfully.');
	case 'ExtractSelectBt',
		prefs = struct2namevaluepair(ud.spikesortingprefs);
		vhspike2_extractselected(getpathname(ud.ds),prefs{:});
	case 'EnableDisable',
		v = get(findobj(fig,'tag','NameRefList'),'value');
		if isempty(v),
			set(findobj(fig,'tag','ClusterBt'),'enable','off');
		else,
			set(findobj(fig,'tag','ClusterBt'),'enable','on');
		end;
	case 'PreferencesBt',
		name = 'VHSPIKE2 Spikesorting preferences';
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
