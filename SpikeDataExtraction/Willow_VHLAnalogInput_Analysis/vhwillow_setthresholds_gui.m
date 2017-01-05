function varargout = vhwillow_setthresholds_gui(varargin)
% VHWILLOW_SETTHRESHOLDS_GUI - Select thresholds based on multichannel data
%
%   THRESHOLDS = VHWILLOW_SETTHRESHOLDS_GUI('datafile',FILENAME,'header',HEADER,...
%      'channel_list',CHANNEL_LIST);
%
%   A graphical user interface for selecting and confirming threshold selection
%   for multichannel data acquired with the VHlab LabView interface.
%
%   FILENAME should be the filename to open, HEADER is the header of that file
%   (as returned by READVHWILLOWHEADERFILE), and CHANNEL_LIST should be the list of
%   channels to examine.
%
%   THRESHOLDS is a structure that can be written to the file vhwillow_threshold.txt
%   (see 'help vhwillow_threshold')
%  
%  Additional parameters can be adjusted by passing name/value pairs at the
%  end of the function:
%
%   NAME (type):              DESCRIPTION
%   ----------------------------------------------------------------
%   'ds' (dirstruct)          the directory where data should be read
%   'start' (double)          the start time to examine (default 0)
%   'windowsize' (double)     the windowsize (default 10 seconds)
%   'MEDIAN_FILTER_ACROSS_CHANNELS' 0/1 : Should we perform a median
%                             filter across channels? (default 1)
%   'REFRACTORY_SAMPLES'      default 15 
%   'SAMPLES'                 Default [-10 25]
%   'MAX_SPIKE_SHAPES'        Maximum number of spikes to plot, default 200

 % internal variables, for the function only
command = 'Main';   % the command
fig = ''; % the figure
success = 0;
datafile   = '';  % needs to be determined dynamically
headerfile = '';

windowheight = 800;
windowwidth = 1000;
windowrow = 35;

 % user-specified variables
ds = [];
start = 0;
windowsize = 10;
dirinfo = [];
dirlist = [];
channelhold = 0;
channelmenu_lastvalue = 0;
dirmenu_lastvalue = 0;
threshold_update_list = [];
MEDIAN_FILTER_ACROSS_CHANNELS = 0;
REFRACTORY_SAMPLES = 15;
SAMPLES = [-8 15];
MAX_SPIKE_SHAPES = 200;

varlist = {'ds','dirinfo','dirlist','channelhold','channelmenu_lastvalue','dirmenu_lastvalue','success',...
		'datafile','headerfile','windowheight','windowwidth','windowrow','start','windowsize',...
		'MEDIAN_FILTER_ACROSS_CHANNELS','threshold_update_list','REFRACTORY_SAMPLES','SAMPLES','MAX_SPIKE_SHAPES'};

assign(varargin{:});

if isempty(fig),
	fig = figure;
end;

 % initialize user data field

if strcmp(command,'Main'),
	if ischar(ds),
		ds = dirstruct(ds);
	end;
	for i=1:length(varlist),
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end;
else,
	ud = get(fig,'userdata');
end;

command,

switch command,
	case 'Main',
		set(fig,'userdata',ud);
		vhwillow_setthresholds_gui('command','NewWindow','fig',fig);
		vhwillow_setthresholds_gui('command','UpdateBt','fig',fig);
		%uiwait(fig);
		%ud = get(fig,'userdata');
		%if nargout>=1,
		%	if ud.success, varargout{1} = ud.thresholds;
		%	else, varargout{1} = [];
		%	end;
		%end;
		%close(fig);
	case 'NewWindow',
		% this callback was a nasty puzzle in quotations:
		callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);'];
		ud.voltagebuttondownfcn = [  'eval([get(gcf,''Tag'') ''(''''command'''','''''' ''VoltageAxesClick'' '''''' ,''''fig'''',gcf);'']);'];

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
		cb = txt; cb.Style = 'Checkbox';
		cb.Callback = callbackstr;
		cb.fontsize = 12;

		% feature list:

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrow;

		set(fig,'position',[50 50 right top],'tag','vhwillow_setthresholds_gui');

		[dspath,dsname] = fileparts(getpathname(ud.ds));

		uicontrol(txt,'position',[5 top-row*1 600 30],'string',['Threshold selection / spike extraction for ' dsname],'fontweight','bold','tag','InstructionTxt');
		uicontrol(button,'position',[5 top-row*2 100 30],'string','DONE','fontweight','bold','tag','DoneBt');
		uicontrol(button,'position',[5+100+10 top-row*2 100 30],'string','Extract','fontweight','bold','tag','ExtractBt');
		uicontrol(button,'position',[5+100+10+5+100+50 top-row*2 125 30],'string','Match Axes','tag','MatchXYAxisBt');
		%uicontrol(button,'position',[5+100+10+5+100+50+125+5 top-row*2 125 30],'string','Match Y Axes','tag','MatchYAxisBt');
		uicontrol(txt,'position',[5+100+10+5+100+50+125+5+125+5-50 top-row*2-4 150 30],'string','Start (s):','tag','StartTxt','horizontalalignment','right');
		uicontrol(edit,'position',[5+100+10+5+100+50+125+5+125+5+100+5 top-row*2 100 30],'string',num2str(ud.start),'tag','StartEdit','callback',callbackstr);
		uicontrol(txt,'position',[5+100+10+5+100+50+125+5+125+5+100+5+105 top-row*2-4 100 30],'string','Duration (s)','tag','DurationTxt');
		uicontrol(edit,'position',[5+100+10+5+100+50+125+5+125+5+100+5+105+105 top-row*2 100 30],'string',num2str(ud.windowsize),'tag','DurationEdit','callback',callbackstr);
		uicontrol(txt,'position',[5 top-row*3-5 120 30],'string','Directory:','tag','DirectoryLabelTxt');
		uicontrol(popup,'position',[5+120+5 top-row*3-3 150 30],'string',{''},'tag','DirectoryPopup');
		uicontrol(txt,'position',[5+120+5+150+5 top-row*3-5 120 30],'string','Channel list:','tag','ChannelLabelTxt');
		uicontrol(popup,'position',[5+120+5+150+5+120+5 top-row*3-3 150 30],'string',{''},'tag','ChannelPopup');
		uicontrol(button,'position',[5+120+5+150+5+120+5+150+5 top-row*3 100 30],'string','Update','tag','UpdateBt');
		uicontrol(button,'position',[5+120+5+150+5+120+5+150+5+100+5 top-row*3 275 30],'string','Copy last thresholds to new directories','tag','CopyThresholdsBt');

		set(fig,'userdata',ud);
	case 'UpdateBt',
		% could check to see if dirname has a real directory; save it if so
		dirstr = get(findobj(fig,'tag','DirectoryPopup'),'string');
		dirvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		chanstr = get(findobj(fig,'tag','ChannelPopup'),'string');
		chanvalue = get(findobj(fig,'tag','ChannelPopup'),'value');

		% build the directory list
		ud.ds = dirstruct(getpathname(ud.ds));
		[newdirlist, newdirinfo] = vhwillow_getdirectorystatus(ud.ds);
			% this is the place to ask the user if they want to apply thresholds
		labels = vhwillow_directorystatus2labels(newdirlist,newdirinfo);

		set(findobj(fig,'tag','DirectoryPopup'),'string',labels,'value',1);
		ud.dirlist = newdirlist;
		ud.dirinfo = newdirinfo;
		set(fig,'userdata',ud);
		vhwillow_setthresholds_gui('command','UpdateChannelMenu','fig',fig);
	case 'CopyThresholdsBt',
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		outputstr = vhwillow_copythresholds(ud.ds,ud.dirlist{dirmenu_currentvalue});
		uiwait(msgbox(outputstr,'Copy thresholds result'));
		vhwillow_setthresholds_gui('command','UpdateBt','fig',fig);
	case 'UpdateChannelMenu',
		dirstr = get(findobj(fig,'tag','DirectoryPopup'),'string');
		dirvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		chanstr = get(findobj(fig,'tag','ChannelPopup'),'string');
		chanvalue = get(findobj(fig,'tag','ChannelPopup'),'value');

		channelmenustring = vhwillow_thresholdchannellabels(ud.dirinfo(dirvalue));
		set(findobj(fig,'tag','ChannelPopup'),'string',channelmenustring,'value',1);

		if ud.channelhold, % we're just updating the popup labels, we don't want to update the values
			set(findobj(fig,'tag','ChannelPopup'),'value',chanvalue);
			[newdirlist,newdirinfo] = vhwillow_getdirectorystatus(ud.ds);
			labels = vhwillow_directorystatus2labels(newdirlist,newdirinfo);
			ud.dirlist = newdirlist;
			ud.dirinfo = newdirinfo;
			set(findobj(fig,'tag','DirectoryPopup'),'string',labels);
			ud.channelhold = 0;
			set(fig,'userdata',ud);
		else, % we need to call as if the menu were clicked to update the view
			set(fig,'userdata',ud);
			vhwillow_setthresholds_gui('command','ChannelPopup','fig',fig);
		end;
	case 'DirectoryPopup',
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		b = ud.dirmenu_lastvalue ~= dirmenu_currentvalue;
		ud.dirmenu_lastvalue = dirmenu_currentvalue;
		if b,
			ud.channelhold = 0;
			ud.channelmenu_lastvalue = -Inf;
		end;
		set(fig,'userdata',ud);
		if b,
			vhwillow_setthresholds_gui('command','UpdateChannelMenu','fig',fig); % will call ChannelPopup, which calls Load
		end;
	case 'ChannelPopup',
		channelmenu_currentvalue = get(findobj(fig,'tag','ChannelPopup'),'value');
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		b = channelmenu_currentvalue~=ud.channelmenu_lastvalue | dirmenu_lastvalue~=dirmenu_currentvalue;
		ud.channelmenu_lastvalue = get(findobj(fig,'tag','ChannelPopup'),'value');
		ud.dirmenu_lastvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		set(fig,'userdata',ud);
		if b,
			vhwillow_setthresholds_gui('command','Load','fig',fig);
		end;
	case 'DrawAxes',
		top_axis = ud.windowheight - 3.5*ud.windowrow;
		left_axis = 25;
		right_axis = ud.windowwidth - 200;
		spike_left_axis = ud.windowwidth-200+25;
		spike_right_axis = ud.windowwidth - 25;
		bottom_axis = 50;

		oldaxes = findobj(fig,'-regexp','tag','VoltageAxes*');
		try, delete(oldaxes); end;
		oldaxes = findobj(fig,'-regexp','tag','SpikeAxes*');
		try, delete(oldaxes); end;

		ax_spaces = linspace(top_axis,bottom_axis,size(ud.D,2)+1);
		ax_voltage = {};
		ax_spike = {};
		chans = 1;
		ymin_voltage = Inf;
		ymax_voltage = -Inf;
		for i=2:length(ax_spaces),
			ax_voltage{chans} = axes('units','pixels','position',[left_axis ax_spaces(i) right_axis-left_axis ax_spaces(i-1)-ax_spaces(i)-5],'tag',['VoltageAxes' int2str(i-1)]);
			plot(ud.T,ud.D(:,chans),'k');
			A = axis;
			axis([ud.start ud.start+ud.windowsize A(3) A(4)]);
			if A(3)<ymin_voltage, ymin_voltage = A(3); end;
			if A(4)>ymax_voltage, ymax_voltage = A(4); end;
			ylabel('Volts');
			box off;
			if i==length(ax_spaces), xlabel('Time(s)'); end;
			set(ax_voltage{chans},'tag',['VoltageAxes' int2str(i-1)],'buttondownfcn',ud.voltagebuttondownfcn);
			ax_spike{chans}=axes('units','pixels','position',[spike_left_axis ax_spaces(i) spike_right_axis-spike_left_axis ax_spaces(i-1)-ax_spaces(i)-5],...
				'tag',['SpikeAxes' int2str(i-1)]);
			axis off;
			chans = chans + 1;
		end;

		for i=1:chans-1,
			axes(ax_voltage{i});
			axis([ud.start ud.start+ud.windowsize ymin_voltage ymax_voltage]);
		end;

		vhwillow_setthresholds_gui('command','DrawThresholds','fig',fig);

	case 'DrawThresholds',  % draw threshold AND update spike axes
		channelmenu_currentvalue = get(findobj(fig,'tag','ChannelPopup'),'value');
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		% examine ud.threshold_update_list to see if it is non-empty; if so, just update those thresholds
		channels_here = ud.dirinfo(dirmenu_currentvalue).vhwillow_filtermap_values(channelmenu_currentvalue).channel_list;
		thresholds = ud.dirinfo(dirmenu_currentvalue).vhwillow_thresholds_values;
		if isempty(thresholds),
			return;  % nothing to do
		end;
		chans_to_update = 1:length(channels_here); % these are index values
		if ~isempty(ud.threshold_update_list),
			chans_to_update = chans_to_update(ud.threshold_update_list); % these are indexes to the list
		end;
		currentAx = gca; % we'll make sure not to change the "current" axes
		for i=chans_to_update,  % these are the index values in channel_list
			myaxes = findobj(fig,'tag',['VoltageAxes' int2str(i)]);
			if ~isempty(myaxes),
				axes(myaxes);
				myoldplot = findobj(myaxes,'tag','threshold_plot');
				if ~isempty(myoldplot), delete(myoldplot); end;
				myoldplot = findobj(myaxes,'tag','threshold_dot_plot');
				if ~isempty(myoldplot), delete(myoldplot); end;
				A=axis;
				[dummy,z] = intersect([thresholds.channel],channels_here(i));
				if ~isempty(z),
					if thresholds(z).threshold(2)<0, % if no negative threshold
						col = 'g'; % plot negative thresholds in green
					else,
						col = 'b'; % plot positive thresholds in blue
					end;
					hold on;
					plot([-10000 10000],thresholds(z).threshold(1)*[1 1],col,'tag','threshold_plot');
					AA = axis;
					set(myaxes,'tag',['VoltageAxes' int2str(i)]);
					% now detect spikes; would be better to write a function for this; in fact, this will cause a problem at some point, but it's got to get done today
					locs = dotdisc(double(ud.D(:,i)),thresholds(z).threshold);
					locs = refractory(locs,ud.REFRACTORY_SAMPLES);
					plot(ud.T(locs),ud.D(locs,i),['o' col],'tag','threshold_dot_plot');
					if length(locs)>ud.MAX_SPIKE_SHAPES, locs = locs(1:ud.MAX_SPIKE_SHAPES); end;
					locs = locs(find(locs<(length(ud.D(:,i))-ud.SAMPLES(2))));
					locs = locs(find(locs>1-ud.SAMPLES(1)));
					myspike = findobj(fig,'tag',['SpikeAxes' int2str(i)]);
					axes(myspike);
					cla;
					if length(locs)>0,
						v1 = repmat(ud.SAMPLES(1):ud.SAMPLES(2),length(locs),1);
						v2 = repmat(locs,1,diff([ud.SAMPLES(1) ud.SAMPLES(2)])+1);
						dt = ud.T(2)-ud.T(1);
						waves = reshape(ud.D(v1+v2,i),length(locs),size(v2,2));
						plot([ud.SAMPLES(1):ud.SAMPLES(2)]*dt, waves');
						hold on;
						plot([ud.SAMPLES(1) ud.SAMPLES(2)]*dt,thresholds(z).threshold(1)*[1 1],col);
						Az = axis;
						axis([ dt*ud.SAMPLES([1 2]) AA(3) AA(4)]);
						axis off;
					end;
					set(myspike,'tag',['SpikeAxes' int2str(i)]);
				end;
			else,
				error(['Cannot find VoltageAxes VoltageAxes' int2str(i) ]);
			end;
		end;
		axes(currentAx);
		ud.threshold_update_list = [];
		set(fig,'userdata',ud);
	case 'VoltageAxesClick',  % this sets the threshold for a given channel
		% find which axes is current, and get its number
		ax = gca;
		axesname = get(ax,'tag');
		axnumber = str2num(axesname(length('VoltageAxes')+1:end));

		% get the point that was clicked
		pt = get(ax,'CurrentPoint');
		pt = pt(1,2);

		% identify the actual channel number, which may be different from the axis number
		channelmenu_currentvalue = get(findobj(fig,'tag','ChannelPopup'),'value');
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		channels_here = ud.dirinfo(dirmenu_currentvalue).vhwillow_filtermap_values(channelmenu_currentvalue).channel_list;
		channel_value = channels_here(axnumber);

		% now specify the new threshold
		newthreshold = struct('channel',channel_value,'threshold',[pt -1 0]);
		% now update the vhwillow_thresholds_value and save it
			% we may be replacing a current value, or adding a new value to an existing or empty structure
			% when we update, we should re-sort the list
		existing_thresholds = ud.dirinfo(dirmenu_currentvalue).vhwillow_thresholds_values;
		if isempty(existing_thresholds),
			existing_thresholds = newthreshold;
		else,
			z = find([existing_thresholds.channel]==channel_value);
			if isempty(z),
				existing_thresholds(end+1) = newthreshold;
			elseif length(z)==1,
				existing_thresholds(z) = newthreshold;
			else,
				error(['More than one threshold for channel ' int2str(channel_value) ' in directory ' ud.dirlist{dirmenu_currentvalue}  ', file vhwillow_thresholds.txt.']);
			end;
			[sorted_values,sorted_indexes] = sort([existing_thresholds.channel]);
			existing_thresholds = existing_thresholds(sorted_indexes);
		end;
		ud.dirinfo(dirmenu_currentvalue).vhwillow_thresholds_values = existing_thresholds;

		% at this point, our data structure is updated, but we must save to disk
		saveStructArray([getpathname(ud.ds) filesep ud.dirlist{dirmenu_currentvalue} filesep 'vhwillow_thresholds.txt'],ud.dirinfo(dirmenu_currentvalue).vhwillow_thresholds_values);

		% now re-draw only the channel that was modified
		ud.threshold_update_list = axnumber;
		ud.channelhold = 1;
		set(fig,'userdata',ud);
		vhwillow_setthresholds_gui('fig',fig,'command','UpdateChannelMenu');
		vhwillow_setthresholds_gui('fig',fig,'command','DrawThresholds');
	case 'Load',
		channelmenu_currentvalue = get(findobj(fig,'tag','ChannelPopup'),'value');
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		channel_list =ud.dirinfo(dirmenu_currentvalue).vhwillow_filtermap_values(channelmenu_currentvalue).channel_list;
		pathname = [getpathname(ud.ds) filesep ud.dirlist{dirmenu_currentvalue} filesep];
		header_filename = vhwillow_getdirfilename(pathname);
		data_filename = header_filename;
		headerstruct = read_Willow_headerfile(header_filename);
		[ud.D,dummy,total_time] = read_Willow_datafile(data_filename,headerstruct,'amp',channel_list,ud.start,ud.start+ud.windowsize);
		[B,A]=cheby1(4,0.8,300/(0.5*headerstruct.frequency_parameters.amplifier_sample_rate),'high');
		ud.D = filtfilt(B,A,ud.D);
		t0 = read_Willow_datafile(data_filename,headerstruct,'time',1,0,0);
		[ud.T,dummy,total_time] = read_Willow_datafile(data_filename,headerstruct,'time',1,ud.start,ud.start+ud.windowsize);
		ud.T = ud.T - t0;
		set(findobj(fig,'tag','StartTxt'),'string',['Start (s, 0.. ' num2str(total_time-ud.windowsize) ')']);
		if ud.MEDIAN_FILTER_ACROSS_CHANNELS,
			ud.D = ud.D - repmat(median(ud.D,2),1,length(channel_list));
		end;
		ud.D = single(ud.D);
		%ud.T = ud.T;  % this has to stay a double
		set(fig,'userdata',ud);
		vhwillow_setthresholds_gui('fig',fig,'command','DrawAxes');
	case {'MatchXYAxisBt'},
		ax = gca;
		A = axis;
		theaxes = findobj(fig,'-regexp','tag','VoltageAxes*');
		for i=1:length(theaxes),
			axes(theaxes(i));
			axis(A);
		end;
		theaxes = findobj(fig,'-regexp','tag','SpikeAxes*');
		for i=1:length(theaxes),
			axes(theaxes(i));
			A2 = axis;
			axis([A2([1 2]) A(3) A(4)]);
		end;
		axes(ax);
	case {'MatchXAxisBt','MatchYAxisBt'},
		ax = gca;
		A = axis;
		%get(ax,'tag'),
		theaxes = findobj(fig,'-regexp','tag','VoltageAxes*');
		for i=1:length(theaxes),
			axes(theaxes(i));
			A2 = axis;
			if strcmp(command,'MatchXAxisBt'),
				axis(([A(1) A(2) A2(3) A2(4)]));
			elseif strcmp(command,'MatchYAxisBt'),
				axis(([A2(1) A2(2) A(3) A(4)]));
			end;
		end;
		axes(ax);
	case {'StartEdit','DurationEdit'}
		newstartstring  = get(findobj(fig,'tag','StartEdit'),'string');
		newdurationstring  = get(findobj(fig,'tag','DurationEdit'),'string');
		newstartvalue = str2num(newstartstring);
		newdurationvalue = str2num(newdurationstring);
		if newstartvalue~=ud.start | newdurationvalue~=ud.windowsize,
			ud.start = newstartvalue;
			ud.windowsize = newdurationvalue;
			set(fig,'userdata',ud);
			vhwillow_setthresholds_gui('fig',fig,'command','Load');
		end;
	case 'DoneBt',
		b = 1;
		if b,
			ud.success = 1;
			set(fig,'userdata',ud);
			%uiresume(fig);
			close(fig);
		else,
			%errordlg(['Please make sure a quality label has been assigned to all clusters.'],'Assign quality label');
		end;
	case 'CancelBt',  % there is no cancel button anymore, but we'll leave this here in case it comes back
		ud.success = 0;
		set(fig,'userdata',ud);
		uiresume(fig);
	case 'ExtractBt',
		dirmenu_currentvalue = get(findobj(fig,'tag','DirectoryPopup'),'value');
		ans = 'Yes';
		if ud.dirinfo(dirmenu_currentvalue).vhwillow_thresholds~=1,
			ans = questdlg('Thresholds have not been assigned for all channels for this directory. Are you sure you want to continue?','Continue?','Yes','No','No');
		end;
		if strcmp(upper(ans),'YES'),
			vhwillow_extractwaveforms([getpathname(ud.ds) filesep ud.dirlist{dirmenu_currentvalue}], ud.SAMPLES, ud.REFRACTORY_SAMPLES, 'MEDIAN_FILTER_ACROSS_CHANNELS',ud.MEDIAN_FILTER_ACROSS_CHANNELS);
			vhwillow_sync2spike2([getpathname(ud.ds) filesep ud.dirlist{dirmenu_currentvalue}]);
		end;
		ud.channelhold = 1;
		set(fig,'userdata',ud);
		vhwillow_setthresholds_gui('fig',fig,'command','UpdateChannelMenu');

end; % switch command


