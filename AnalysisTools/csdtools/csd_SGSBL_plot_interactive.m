function varargout = csd_SGSBL_plot_interactive(varargin)
% CSD_SGSBL_PLOT_INTERACTIVE interactive plotting for LFP / CSD data
%
%   CSD_SGSBL_PLOT_INTERACTIVE('DS',DS)
%
%   Brings up a graphical user interface to manage plotting of 
%   LFP and CSD data that is derived from STOCHASTICGRIDSTIM or
%   BLINKINGSTIM responses.
%
%
            
command = 'Main';
fig = '';
success = 0;
windowheight = 500;
windowwidth = 1250;
windowrowheight = 35;

varargout = {};

 % user-specified variables
ds = [];
windowlabel = 'CSD SGSBL Interactive Plot';
gridlocation = 1;
gridparams = [];
t_int = [0.030 0.150];
t_int_default = [ 0.030 0.150 ];


csd_prefs = struct('ElectrodeMap','MCS_A1Poly32_right','SubtractMedian',1,'SubtractTimeRange',[-0.05 0],'NormalizeByNoise',0);
csd_prefs_help = {'Function to convert from MCS channels to the electrode map (default MCS_A1Poly32_right)',...
	'0/1 Should we subtract the median signal from before each pulse? (default 1)',...
	'Over what time range (in seconds) should we examine the signal for determining the median value to subtract? (default [-0.050 0]',...
	'0/1 Should we normalize by the estimated noise in the signal? (default 0)'};

varlist = {'ds','windowheight','windowwidth','windowrowheight','windowlabel','gridlocation',...
	'gridparams','t_int','t_int_default',...
	'csd_prefs','csd_prefs_help'};

assign (varargin{:});

if isempty(fig),
	z = findobj(allchild(0),'flat','tag','csd_SGSBL_plot_interactive');
	if isempty(z),
		fig = figure('name',windowlabel,'NumberTitle','off');
	else,
		fig = z;
		figure(fig);
		% issue update command
		csd_SGSBL_plot_interactive('fig',fig,'command','Update');
		return;
	end;
end;

if strcmp(command,'Main'), % set up variables
	for i=1:length(varlist),
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end;
else,
	ud = get(fig,'userdata');
end;

 % process commands

switch command,
	case 'Main', 
		set(fig,'userdata',ud);
		csd_SGSBL_plot_interactive('command','NewWindow','fig',fig);
		csd_SGSBL_plot_interactive('command','UpdateMenu','fig',fig);
	case 'NewWindow',
		% this callback was a nasty puzzle in quotations
		callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);'];

		%control object defaults 
		button.Units = 'pixels';
		button.BackgroundColor = get(fig,'Color');
		button.HorizontalAlignment = 'center';
		button.Callback = callbackstr;
		txt.Units = 'pixels';
		txt.BackgroundColor = get(fig,'Color'); 
		txt.fontsize = 12; txt.fontweight = 'normal';
		txt.HorizontalAlignment = 'left';
		txt.Style='text';
		edit = txt;
		edit.BackgroundColor = [ 1 1 1];
		edit.Style = 'Edit';
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

		set(fig,'position',[50 50 right top],'tag','csd_SGSBL_plot_interactive');
		uicontrol(txt,'position',[5 top-row*1 600 30],'string',ud.windowlabel,'horizontalalignment','left','fontweight','bold');
		uicontrol(txt,'position',[5 top-row*2 600 30],'string',getpathname(ud.ds));

		uicontrol(txt,'position',[5 top-row*3 100 30],'string','Data directory:');
		uicontrol(popup,'position',[5+100 top-row*3 100 30],'string',{''},'tag','dataPopup');
		uicontrol(txt,'position',[5+100+100 top-row*3 100 30],'string','Channel:');
		uicontrol(popup,'position',[5+100+100+100 top-row*3 100 30],'string',{''},'tag','channelPopup');
		uicontrol(txt,'position',[5+100+100+100+100 top-row*3 50 30],'string','T_int:');
		uicontrol(edit,'position',[5+100+100+100+100+50 top-row*3 100 30],'string',mat2str(ud.t_int),...
			'tag','t_intEdit','callback',callbackstr);
		uicontrol(popup,'position',[5+100+100+100+100+50+100 top-row*3 100 30],'string',{'On','Off'},'value',1,'tag','ONOFFPopup');
		uicontrol(button, 'position',[5+100+100+100+100+50+100+100+5 top-row*3 100 30],'string','Preferences','tag','PreferencesBt');

		axes('units','pixels','position',[5 top-row*4-300 300 300],'tag','gridAxes');
		axes('units','pixels','position',[5+300 top-row*4-300 300 300],'tag','singleChannelAxes');
		axes('units','pixels','position',[10+300+300+100 top-row*4-300 100 300],'tag','LFPAxes');
		axes('units','pixels','position',[5+300+300+200 top-row*4-300 100 300], 'tag','CSDAxes');
		axes('units','pixels','position',[5+300+300+200+100 top-row*4-300 200 300],'tag','CSD_falsecolor_Axes');

		set(fig,'userdata',ud);

	case 'UpdateMenu',
		t = getalltests(ud.ds);
		dataPopup = findobj(fig,'tag','dataPopup');
		set(dataPopup,'string',cat(1,{' '},t),'value',1);

	case 'getONOFFValue',
		ONOFFPopup = findobj(fig,'tag','ONOFFPopup');
		value = get(ONOFFPopup,'value');
		if value ~= 1, value = 0; end;
		varargout{1} = value;
	case 'getDataPopup',
		dataPopup = findobj(fig,'tag','dataPopup');
		s = get(dataPopup,'string');
		v = get(dataPopup,'value'); 
		varargout{1} = s{v}; % there should always be a blank entry first, so this should not error
	case 'getChannelPopup',
		channelPopup = findobj(fig,'tag','channelPopup');
		s = get(channelPopup,'string');
		v = get(channelPopup,'value'); 
		varargout{1} = str2num(s{v});
	case 't_intEdit',
		t_intEdit = findobj(fig,'tag','t_intEdit');
		t_int_string = get(t_intEdit,'string');
		try,
			ud.t_int = eval(t_int_string);
		catch,
			errordlg(['Syntax error in setting new time interval string "' t_int_string '"; it should be a matrix like [t0 t1].']);
			ud.t_int = ud.t_int_default;
		end;
		set(fig,'userdata',ud);
		csd_SGSBL_plot_interactive('command','UpdateForGridLocation','fig',fig);
		csd_SGSBL_plot_interactive('command','UpdateForTimeInterval','fig',fig);

	case {'ONOFFPopup','channelPopup'},
		csd_SGSBL_plot_interactive('command','UpdateForGridLocation','fig',fig);
		csd_SGSBL_plot_interactive('command','UpdateForTimeInterval','fig',fig);

	case 'dataPopup',
		tdir = csd_SGSBL_plot_interactive('command','getDataPopup','fig',fig);
		t = getalltests(ud.ds);
		ishere = find(ismember(t,tdir));
		if ~isempty(ishere),
	                prefs = struct2namevaluepair(ud.csd_prefs);
			try,
				csd_SGSBL_extract_lfp([getpathname(ud.ds) filesep tdir],prefs{:});
			catch, 
				errordlg(['Could not extract data in directory ' tdir ':' lasterr '.']);
				csd_SGSBL_plot_interactive('command','UpdateMenu','fig',fig);
				return;
			end;
		end;
		csd_SGSBL_plot_interactive('command','UpdateForNewData','fig',fig);

	case 'UpdateForNewData',
		% assume directory name validated
		tdir = csd_SGSBL_plot_interactive('command','getDataPopup','fig',fig);
		ud.gridlocation = 1;  % start out with gridlocation 1

		% load grid parameters
		mystimscript = getstimscript([getpathname(ud.ds) filesep tdir]);
		stim = get(mystimscript,1); % we assume all stims are the same dimensions, as ccd_SGSBL_extract_lfp checks
		[x,y,rect] = getgrid(stim);
		ud.gridparams = var2struct('x','y','rect');
		set(fig,'userdata',ud);

		% update channel menu

		channelPopup = findobj(fig,'tag','channelPopup');
		channelstr = {' '};
		LFP = load([getpathname(ud.ds) filesep tdir filesep 'LFPs.mat'],'-mat');
		for i=1:length(LFP.params.channels),
			channelstr{end+1} = num2str(i);
		end;
		set(channelPopup,'string',channelstr,'value',13);

		csd_SGSBL_plot_interactive('command','UpdateForGridLocation','fig',fig);
		csd_SGSBL_plot_interactive('command','UpdateForTimeInterval','fig',fig);

	case 'UpdateForGridLocation',
		tdir = csd_SGSBL_plot_interactive('command','getDataPopup','fig',fig);
		ch = csd_SGSBL_plot_interactive('command','getChannelPopup','fig',fig);
		LFP = load([getpathname(ud.ds) filesep tdir filesep 'LFPs.mat'],'-mat');
		ON = csd_SGSBL_plot_interactive('command','getONOFFValue','fig',fig);

		% plot selected channel on single channel axes
		channelaxes = findobj(fig,'tag','singleChannelAxes');
		axes(channelaxes);
		cla;
		for i=1:length(LFP.D_on),
			if ON,
				if i~=ud.gridlocation,
					plot(LFP.T,LFP.D_on{i}(:,ch),'k');
				else,
					plot(LFP.T,LFP.D_on{i}(:,ch),'m','linewidth',4,'tag','highlighted_line');
				end;
			else,
				if i~=ud.gridlocation,
					plot(LFP.T,LFP.D_off{i}(:,ch),'k');
				else,
					plot(LFP.T,LFP.D_off{i}(:,ch),'m','linewidth',4,'tag','highlighted_line');
				end;
			end;
			hold on;
		end;
		mylines = get(channelaxes,'children');
		index = 0;
		for i=1:length(mylines), if strcmp(get(mylines(i),'tag'),'highlighted_line'), index = i; end; end;
		if index>0,
			mylines = mylines([1:index-1 index+1:end index]);
			set(channelaxes,'children',mylines);
		end;
		
		hold on;
		A = axis;
		plot([ud.t_int(1) ud.t_int(1)],[A(3) A(4)],'b--','tag','time_interval_bounds');
		plot([ud.t_int(2) ud.t_int(2)],[A(3) A(4)],'b--','tag','time_interval_bounds');
		box off;
		set(channelaxes,'tag','singleChannelAxes');

                prefs = struct2namevaluepair(ud.csd_prefs);

		LFPaxes = findobj(fig,'tag','LFPAxes');
		axes(LFPaxes);
		csd_SGSBL_plot_lfp([getpathname(ud.ds) filesep tdir],ud.gridlocation,ON,prefs{:});
		set(LFPaxes,'tag','LFPAxes');

		CSDaxes = findobj(fig,'tag','CSDAxes');
		axes(CSDaxes);
		csd_SGSBL_plot_csd([getpathname(ud.ds) filesep tdir],ud.gridlocation,ON,prefs{:});
		set(CSDaxes,'tag','CSDAxes');

		CSD_FC_axes = findobj(fig,'tag','CSD_falsecolor_Axes');
		box off;
		set(CSD_FC_axes,'tag','CSD_falsecolor_Axes');

		csd_SGSBL_plot_interactive('command','PlotGridBoundary','fig',fig);
		
	case 'UpdateForTimeInterval',
		tdir = csd_SGSBL_plot_interactive('command','getDataPopup','fig',fig);
		ch = csd_SGSBL_plot_interactive('command','getChannelPopup','fig',fig);
		LFP = load([getpathname(ud.ds) filesep tdir filesep 'LFPs.mat'],'-mat');
		ON = csd_SGSBL_plot_interactive('command','getONOFFValue','fig',fig);

		% update the time interval bounds in singleChannelAxes
		channelaxes = findobj(fig,'tag','singleChannelAxes');
		axes(channelaxes);
		mylines = findobj(channelaxes,'tag','time_interval_bounds');
		if ~isempty(mylines), delete(mylines); end; 
		hold on;
		A = axis;
		plot([ud.t_int(1) ud.t_int(1)],[A(3) A(4)],'b--','tag','time_interval_bounds');
		plot([ud.t_int(2) ud.t_int(2)],[A(3) A(4)],'b--','tag','time_interval_bounds');
		box off;
		set(channelaxes,'tag','singleChannelAxes');

		% calculate the values for all grids

		v = [];
		s0 = findclosest(LFP.T,ud.t_int(1));
		s1 = findclosest(LFP.T,ud.t_int(2));
		if ON,
			for i=1:length(LFP.D_on),
				v(i) = mean(rectify(-LFP.D_on{i}(s0:s1,ch)));
			end;
		else,
			for i=1:length(LFP.D_off),
				v(i) = mean(rectify(-LFP.D_off{i}(s0:s1,ch)));
			end;
		end;

		% now plot this value in the grid
		gridAxes = findobj(fig,'tag','gridAxes');
		axes(gridAxes);
		cla;
			
		v = reshape(v,ud.gridparams.x,ud.gridparams.y);
		xx = ud.gridparams.rect(1):((ud.gridparams.rect(3)-ud.gridparams.rect(1))/ud.gridparams.x):ud.gridparams.rect(3);
		yy = ud.gridparams.rect(2):((ud.gridparams.rect(4)-ud.gridparams.rect(2))/ud.gridparams.y):ud.gridparams.rect(4);
		v_out = pcolordummyrowcolumn(v);
		mysurf = pcolor(xx,yy,255*v_out/max(v_out(:)));
		shading flat;
		colormap(gray(255));
		set(gridAxes,'ydir','reverse');
		set(mysurf,'ButtonDownFcn',['csd_SGSBL_plot_interactive(''command'',''PColorClick'',''fig'',gcf);']);
		csd_SGSBL_plot_interactive('command','PlotGridBoundary','fig',fig);
		set(gridAxes,'tag','gridAxes');

	case 'PlotGridBoundary',
		gridAxes = findobj(fig,'tag','gridAxes');
		axes(gridAxes);
		mylines = findobj(gridAxes,'tag','grid_boundary');
		if ~isempty(mylines), delete(mylines); end;
		
		xx = ud.gridparams.rect(1):((ud.gridparams.rect(3)-ud.gridparams.rect(1))/ud.gridparams.x):ud.gridparams.rect(3);
		yy = ud.gridparams.rect(2):((ud.gridparams.rect(4)-ud.gridparams.rect(2))/ud.gridparams.y):ud.gridparams.rect(4);
		gridloc_x = 1+floor((ud.gridlocation-1)/ud.gridparams.y);
		gridloc_y = 1+mod((ud.gridlocation-1),ud.gridparams.y);
		hold on;
		plot([xx(gridloc_x) xx(gridloc_x+1)],[yy(gridloc_y) yy(gridloc_y)],'y','tag','grid_boundary','linewidth',2);
		plot([xx(gridloc_x) xx(gridloc_x+1)],[yy(gridloc_y+1) yy(gridloc_y+1)],'y','tag','grid_boundary','linewidth',2);
		plot([xx(gridloc_x) xx(gridloc_x)],[yy(gridloc_y) yy(gridloc_y+1)],'y','tag','grid_boundary','linewidth',2);
		plot([xx(gridloc_x+1) xx(gridloc_x+1)],[yy(gridloc_y) yy(gridloc_y+1)],'y','tag','grid_boundary','linewidth',2);
		box off;
		set(gridAxes,'tag','gridAxes');
		
	case 'PColorClick',
		gridAxes = findobj(fig,'tag','gridAxes');

		pt = get(gridAxes,'CurrentPoint');
		pt = pt(1,1:2), % 2-d projection

		xx = ud.gridparams.rect(1):((ud.gridparams.rect(3)-ud.gridparams.rect(1))/ud.gridparams.x):ud.gridparams.rect(3);
		yy = ud.gridparams.rect(2):((ud.gridparams.rect(4)-ud.gridparams.rect(2))/ud.gridparams.y):ud.gridparams.rect(4);
		
		loc_x = find(xx(1:end-1)<=pt(1) & xx(2:end)>=pt(1));
		loc_y = find(yy(1:end-1)<=pt(2) & yy(2:end)>=pt(2));

		if ~isempty(loc_x) & ~isempty(loc_y),
			ud.gridlocation = loc_y + ud.gridparams.y * (loc_x-1),
			set(fig,'userdata',ud);
			csd_SGSBL_plot_interactive('command','UpdateForGridLocation','fig',fig);
		end;
        case 'PreferencesBt',
		name = 'CSD preferences';
		prompt = ud.csd_prefs_help;
		numlines = 1;
		values = {};
		fn = fieldnames(ud.csd_prefs);
		for i=1:length(fn),
			values{i} = mat2str(getfield(ud.csd_prefs,fn{i}));
		end;
		answer = inputdlg(prompt,name,numlines,values);
		try,
			if ~isempty(answer),
				for i=1:length(answer),
					ud.csd_prefs = setfield(ud.csd_prefs,fn{i},eval(answer{i}));
				end;
			end;
			set(fig,'userdata',ud);
			textbox('Preferences updated successfully...','Preferences will be applied when data directory view is switched.');
		catch,
			errordlg(['Preferences were not updated due to a syntax error: ' lasterr ], 'Preferences update error');
		end;
end;
