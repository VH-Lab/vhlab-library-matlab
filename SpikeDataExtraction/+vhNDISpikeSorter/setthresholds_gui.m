function varargout = setthresholds_gui(args)
% SETTHRESHOLDS_GUI - Select thresholds based on multichannel data
%
%   THRESHOLDS = SETTHRESHOLDS_GUI('ndiSession', NDISESSION, 'params', PARAMS, ...)
%
%   A graphical user interface for selecting and confirming threshold selection
%   for multichannel data acquired with the VHlab LabView interface.
%
%   NDISESSION is an ndi.session object.
%   PARAMS is a vhNDISpikeSorter.parameters object.
%

    arguments
        args.ndiSession = []
        args.params = []
        args.dirinfo = []
        args.dirlist = []
        args.channelhold = 0
        args.channelmenu_lastvalue = 0;
        args.dirmenu_lastvalue = 0;
        args.success = 0;
        args.datafile = ''
        args.headerfile = ''
        args.windowheight = 800;
        args.windowwidth = 1000;
        args.windowrow = 35;
        args.start = 0;
        args.windowsize = 10;
        args.threshold_update_list = []
        args.MAX_SPIKE_SHAPES = 200;
        args.command = 'Main'
        args.fig = []
        args.verbose = true;
    end

    % Unpack
    ndiSession = args.ndiSession;
    params = args.params;
    dirinfo = args.dirinfo;
    dirlist = args.dirlist;
    channelhold = args.channelhold;
    channelmenu_lastvalue = args.channelmenu_lastvalue;
    dirmenu_lastvalue = args.dirmenu_lastvalue;
    success = args.success;
    datafile = args.datafile;
    headerfile = args.headerfile;
    windowheight = args.windowheight;
    windowwidth = args.windowwidth;
    windowrow = args.windowrow;
    start = args.start;
    windowsize = args.windowsize;
    threshold_update_list = args.threshold_update_list;
    MAX_SPIKE_SHAPES = args.MAX_SPIKE_SHAPES;
    command = args.command;
    fig = args.fig;
    verbose = args.verbose;

    varargout = cell(1,nargout);

    varlist = {'ndiSession','params','dirinfo','dirlist','channelhold','channelmenu_lastvalue','dirmenu_lastvalue','success',...
            'datafile','headerfile','windowheight','windowwidth','windowrow','start','windowsize',...
            'threshold_update_list','MAX_SPIKE_SHAPES','verbose'};


if isempty(fig)
	fig = figure;
end

 % initialize user data field

if strcmp(command,'Main')
	for i=1:length(varlist)
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end
    ud.probes = {}; % To store probes
    ud.epochs = {}; % To store epochs of selected probe
else
	ud = get(fig,'userdata');
end

if ud.verbose
    disp(['setthresholds_gui Command: ' command]);
end

switch command
	case 'Main'
		set(fig,'userdata',ud);
		vhNDISpikeSorter.setthresholds_gui('command','NewWindow','fig',fig);
		vhNDISpikeSorter.setthresholds_gui('command','UpdateBt','fig',fig);
	case 'NewWindow'
		% this callback was a nasty puzzle in quotations:
		callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);'];
		ud.voltagebuttondownfcn = [  'eval([get(gcf,''Tag'') ''(''''command'''','''''' ''VoltageAxesClick'' '''''' ,''''fig'''',gcf);'']);'];

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
		cb = txt; cb.Style = 'Checkbox';
		cb.Callback = callbackstr;
		cb.fontsize = 12;

		% feature list:

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrow;

		set(fig,'position',[50 50 right top],'tag','vhNDISpikeSorter.setthresholds_gui');

        dsname = 'Session';
        if ~isempty(ud.ndiSession)
            dsname = ud.ndiSession.path;
        end

		uicontrol(txt,'position',[5 top-row*1 600 30],'string',['Threshold selection / spike extraction for ' dsname],'fontweight','bold','tag','InstructionTxt');
		uicontrol(button,'position',[5 top-row*2 100 30],'string','DONE','fontweight','bold','tag','DoneBt');
		uicontrol(button,'position',[5+100+10 top-row*2 100 30],'string','Extract','fontweight','bold','tag','ExtractBt');
		uicontrol(button,'position',[5+100+10+5+100+50 top-row*2 125 30],'string','Match Y Axes','tag','MatchYAxisBt');
		%uicontrol(button,'position',[5+100+10+5+100+50+125+5 top-row*2 125 30],'string','Match Y Axes','tag','MatchYAxisBt');
		uicontrol(txt,'position',[5+100+10+5+100+50+125+5+125+5-50 top-row*2-4 150 30],'string','Start (s):','tag','StartTxt','horizontalalignment','right');
		uicontrol(edit,'position',[5+100+10+5+100+50+125+5+125+5+100+5 top-row*2 100 30],'string',num2str(ud.start),'tag','StartEdit','callback',callbackstr);
		uicontrol(txt,'position',[5+100+10+5+100+50+125+5+125+5+100+5+105 top-row*2-4 100 30],'string','Duration (s)','tag','DurationTxt');
		uicontrol(edit,'position',[5+100+10+5+100+50+125+5+125+5+100+5+105+105 top-row*2 100 30],'string',num2str(ud.windowsize),'tag','DurationEdit','callback',callbackstr);

        % Probes popup
        uicontrol(txt,'position',[5 top-row*3-5 120 30],'string','Probe:','tag','ProbeLabelTxt');
		uicontrol(popup,'position',[5+120+5 top-row*3-3 150 30],'string',{''},'tag','ProbePopup');

        % Epochs popup
        uicontrol(txt,'position',[5+120+5+150+5 top-row*3-5 120 30],'string','Epoch:','tag','DirectoryLabelTxt');
		uicontrol(popup,'position',[5+120+5+150+5+120+5 top-row*3-3 150 30],'string',{''},'tag','EpochPopup');

        uicontrol(button,'position',[5+120+5+150+5+120+5+150+5 top-row*3 100 30],'string','Update','tag','UpdateBt');
		uicontrol(button,'position',[5+120+5+150+5+120+5+150+5+100+5 top-row*3 275 30],'string','Copy last thresholds to new epochs','tag','CopyThresholdsBt');

		set(fig,'userdata',ud);
	case 'UpdateBt'
		% Populate Probes list
        if ~isempty(ud.ndiSession)
            ud.probes = ud.ndiSession.getprobes('type', 'n-trode');
            probe_labels = {};
            for i=1:numel(ud.probes)
                probe_labels{i} = ud.probes{i}.elementstring();
            end
            if isempty(probe_labels), probe_labels = {' '}; end
            set(findobj(fig,'tag','ProbePopup'),'string',probe_labels,'value',1);
        end
		set(fig,'userdata',ud);
		vhNDISpikeSorter.setthresholds_gui('command','ProbePopup','fig',fig);

    case 'ProbePopup'
        % Update Epochs list based on selected probe
        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        if ~isempty(ud.probes) && probe_idx <= numel(ud.probes)
            probe = ud.probes{probe_idx};
            et = probe.epochtable();
            epoch_labels = {};
            for i=1:numel(et)
                epoch_labels{i} = et(i).epoch_id;
            end
            ud.epochs = epoch_labels;
            if isempty(epoch_labels), epoch_labels = {' '}; end
            set(findobj(fig,'tag','EpochPopup'),'string',epoch_labels,'value',1);
        else
            set(findobj(fig,'tag','EpochPopup'),'string',{' '},'value',1);
            ud.epochs = {};
        end
        set(fig,'userdata',ud);
        vhNDISpikeSorter.setthresholds_gui('command','UpdateChannelMenu','fig',fig);

	case 'CopyThresholdsBt'
        % Get current probe
        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        if isempty(ud.probes) || probe_idx > numel(ud.probes)
            msgbox('No probe selected.');
            return;
        end
        probe = ud.probes{probe_idx};

        % Get all epochs and sort
        et = probe.epochtable();
        epochIDs = sort({et.epoch_id});

        if isempty(epochIDs)
            msgbox('No epochs found for this probe.');
            return;
        end

        % Path for threshold files
        settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ud.ndiSession);
        pName = probe.elementstring();
        pName = char(pName); pName(isspace(pName)) = '_'; pName = replace(pName, '|', '_');

        last_valid_epoch = '';
        copied_count = 0;

        for i = 1:length(epochIDs)
            currEpoch = epochIDs{i};

            % Check if threshold files exist for this epoch (any channel)
            % Pattern: pName_epochID_ch*.txt
            filePattern = fullfile(settingsDir, [pName '_' currEpoch '_ch*.txt']);
            existingFiles = dir(filePattern);

            if ~isempty(existingFiles)
                % This epoch has thresholds, update last valid
                last_valid_epoch = currEpoch;
            elseif ~isempty(last_valid_epoch)
                % No thresholds here, copy from last valid

                % List source files
                srcPattern = fullfile(settingsDir, [pName '_' last_valid_epoch '_ch*.txt']);
                srcFiles = dir(srcPattern);

                for k = 1:length(srcFiles)
                    srcFile = srcFiles(k).name;
                    % Construct dest filename by replacing epoch ID
                    % Be careful with replace if epoch IDs are substrings of each other.
                    % Better to parse channel number and reconstruct.

                    % Expected format: pName_epochID_chN.txt
                    % We know pName and last_valid_epoch.
                    % Suffix starts after pName_last_valid_epoch
                    prefix = [pName '_' last_valid_epoch];
                    if startsWith(srcFile, prefix)
                        suffix = srcFile(length(prefix)+1:end); % _chN.txt
                        destFile = [pName '_' currEpoch suffix];

                        copyfile(fullfile(settingsDir, srcFile), fullfile(settingsDir, destFile));
                    end
                end
                copied_count = copied_count + 1;
            end
        end

		uiwait(msgbox(['Copied thresholds to ' int2str(copied_count) ' epochs.'],'Copy thresholds result'));

	case 'UpdateChannelMenu'
        vhNDISpikeSorter.setthresholds_gui('command','Load','fig',fig);

	case 'EpochPopup'
		% Just reload
        vhNDISpikeSorter.setthresholds_gui('command','Load','fig',fig);

	case 'DrawAxes'
		top_axis = ud.windowheight - 3.5*ud.windowrow;
		left_axis = 25;
		right_axis = ud.windowwidth - 200;
		spike_left_axis = ud.windowwidth-200+25;
		spike_right_axis = ud.windowwidth - 25;
		bottom_axis = 50;

		oldaxes = findobj(fig,'-regexp','tag','VoltageAxes*');
		try, delete(oldaxes); end
		oldaxes = findobj(fig,'-regexp','tag','SpikeAxes*');
		try, delete(oldaxes); end

		ax_spaces = linspace(top_axis,bottom_axis,size(ud.D,2)+1);
		ax_voltage = [];
		ax_spike = [];
		chans = 1;
		ymin_voltage = Inf;
		ymax_voltage = -Inf;
		for i=2:length(ax_spaces)
			ax_voltage(chans) = axes('units','pixels','position',[left_axis ax_spaces(i) right_axis-left_axis ax_spaces(i-1)-ax_spaces(i)-5],'tag',['VoltageAxes' int2str(i-1)]);
			plot(ud.T,ud.D(:,chans),'k');
			A = axis;
			axis([ud.start ud.start+ud.windowsize A(3) A(4)]);
			if A(3)<ymin_voltage, ymin_voltage = A(3); end
			if A(4)>ymax_voltage, ymax_voltage = A(4); end
			ylabel('Volts');
			box off;
			if i==length(ax_spaces), xlabel('Time(s)'); end
			set(ax_voltage(chans),'tag',['VoltageAxes' int2str(i-1)],'buttondownfcn',ud.voltagebuttondownfcn);
			ax_spike(chans)=axes('units','pixels','position',[spike_left_axis ax_spaces(i) spike_right_axis-spike_left_axis ax_spaces(i-1)-ax_spaces(i)-5],...
				'tag',['SpikeAxes' int2str(i-1)]);
			axis off;
			chans = chans + 1;
		end

        if ~isempty(ax_voltage)
            linkaxes(ax_voltage, 'x');
        end

		for i=1:chans-1
			axes(ax_voltage(i));
			axis([ud.start ud.start+ud.windowsize ymin_voltage ymax_voltage]);
		end

		vhNDISpikeSorter.setthresholds_gui('command','DrawThresholds','fig',fig);

	case 'DrawThresholds'  % draw threshold AND update spike axes
        % Load thresholds for the current probe/epoch
        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        epoch_idx = get(findobj(fig,'tag','EpochPopup'),'value');

        if isempty(ud.probes) || isempty(ud.epochs), return; end
        probe = ud.probes{probe_idx};
        epochID = ud.epochs{epoch_idx};

        settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ud.ndiSession);

        num_channels = size(ud.D, 2);

		chans_to_update = 1:num_channels;
		if ~isempty(ud.threshold_update_list)
			chans_to_update = chans_to_update(ud.threshold_update_list);
		end
		currentAx = gca;
		for i=chans_to_update
			myaxes = findobj(fig,'tag',['VoltageAxes' int2str(i)]);
			if ~isempty(myaxes)
                % Read thresholds for this channel
                chanID = i; % Assuming 1:N
                filename = vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID, chanID);
                fullPath = fullfile(settingsDir, filename);

                if exist(fullPath, 'file')
                    thresholds = loadStructArray(fullPath);
                else
                    thresholds = [];
                end

				axes(myaxes);
				myoldplot = findobj(myaxes,'tag','threshold_plot');
				if ~isempty(myoldplot), delete(myoldplot); end
				myoldplot = findobj(myaxes,'tag','threshold_dot_plot');
				if ~isempty(myoldplot), delete(myoldplot); end
				A=axis;

				if ~isempty(thresholds) && isfield(thresholds, 'threshold')
                    % Thresholds struct for this channel
                    z = 1; % Only one entry per file ideally
					if thresholds(z).threshold(2)<0, % if no negative threshold
						col = 'g'; % plot negative thresholds in green
					else
						col = 'b'; % plot positive thresholds in blue
					end
					hold on;
					plot([-10000 10000],thresholds(z).threshold(1)*[1 1],col,'tag','threshold_plot');
					AA = axis;
					set(myaxes,'tag',['VoltageAxes' int2str(i)]);
					% now detect spikes
                    % Need ud.SAMPLES, ud.REFRACTORY_SAMPLES from params
                    samples = ud.params.spikeSortingParameters.events.samples;
                    ref_samples = ud.params.spikeSortingParameters.events.refractoryPeriodSamples;

					locs = dotdisc(double(ud.D(:,i)),thresholds(z).threshold);
					locs = refractory(locs, ref_samples);
					plot(ud.T(locs),ud.D(locs,i),['o' col],'tag','threshold_dot_plot');
					if length(locs)>ud.MAX_SPIKE_SHAPES, locs = locs(1:ud.MAX_SPIKE_SHAPES); end
					locs = locs(find(locs<(length(ud.D(:,i))-samples(2))));
					locs = locs(find(locs>1-samples(1)));
					myspike = findobj(fig,'tag',['SpikeAxes' int2str(i)]);
					axes(myspike);
					cla;
					if length(locs)>0
						v1 = repmat(samples(1):samples(2),length(locs),1);
						v2 = repmat(locs,1,diff([samples(1) samples(2)])+1);
						dt = ud.T(2)-ud.T(1);
						waves = reshape(ud.D(v1+v2,i),length(locs),size(v2,2));
						plot([samples(1):samples(2)]*dt, waves');
						hold on;
						plot([samples(1) samples(2)]*dt,thresholds(z).threshold(1)*[1 1],col);
						Az = axis;
						axis([ dt*samples([1 2]) AA(3) AA(4)]);
						axis off;
					end
					set(myspike,'tag',['SpikeAxes' int2str(i)]);
				end
			else
				% error(['Cannot find VoltageAxes VoltageAxes' int2str(i) ]);
			end
		end
		axes(currentAx);
		ud.threshold_update_list = [];
		set(fig,'userdata',ud);
	case 'VoltageAxesClick'  % this sets the threshold for a given channel
		% find which axes is current, and get its number
		ax = gca;
		axesname = get(ax,'tag');
		axnumber = str2num(axesname(length('VoltageAxes')+1:end));

		% get the point that was clicked
		pt = get(ax,'CurrentPoint');
		pt = pt(1,2);

        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        epoch_idx = get(findobj(fig,'tag','EpochPopup'),'value');
        probe = ud.probes{probe_idx};
        epochID = ud.epochs{epoch_idx};

		channel_value = axnumber; % Assuming 1-based index

		% now specify the new threshold
		newthreshold = struct('channel',channel_value,'threshold',[pt -1 0]);

        filename = vhNDISpikeSorter.parameters.getThresholdLevelFilename(probe, epochID, channel_value);
        settingsDir = vhNDISpikeSorter.parameters.spikeSortingPath(ud.ndiSession);
        fullPath = fullfile(settingsDir, filename);

        if exist(fullPath, 'file')
            existing_thresholds = loadStructArray(fullPath);
        else
            existing_thresholds = struct('channel',{},'threshold',{});
        end

		if isempty(existing_thresholds)
			existing_thresholds = newthreshold;
		else
			z = find([existing_thresholds.channel]==channel_value);
			if isempty(z)
				existing_thresholds(end+1) = newthreshold;
			elseif length(z)==1
				existing_thresholds(z) = newthreshold;
			else
                % Handle duplicates or error
				existing_thresholds(z(1)) = newthreshold;
			end
			[sorted_values,sorted_indexes] = sort([existing_thresholds.channel]);
			existing_thresholds = existing_thresholds(sorted_indexes);
		end

		% Save to disk
        if ~exist(settingsDir, 'dir'), mkdir(settingsDir); end
		saveStructArray(fullPath, existing_thresholds);

		% now re-draw only the channel that was modified
		ud.threshold_update_list = axnumber;
		ud.channelhold = 1;
		set(fig,'userdata',ud);
		% vhNDISpikeSorter.setthresholds_gui('fig',fig,'command','UpdateChannelMenu'); % Not needed?
		vhNDISpikeSorter.setthresholds_gui('fig',fig,'command','DrawThresholds');
	case 'Load'
        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        epoch_idx = get(findobj(fig,'tag','EpochPopup'),'value');

        if isempty(ud.probes) || isempty(ud.epochs)
            return;
        end

        probe = ud.probes{probe_idx};
        epochID = ud.epochs{epoch_idx};

        % Read data using readtimeseries
        try
            [ud.D, ud.T] = probe.readtimeseries(epochID, ud.start, ud.start + ud.windowsize);
        catch err
            errordlg(['Error reading data: ' err.message]);
            return;
        end

        % Filter
        try
            sr = probe.samplerate(epochID);
        catch
            sr = 1; % Should error?
        end
        f_params = ud.params.spikeSortingParameters.filter;

        if f_params.cheby1Order > 0
            [B,A] = cheby1(f_params.cheby1Order, f_params.cheby1Rolloff, f_params.cheby1Cutoff / (0.5 * sr), 'high');
            ud.D = filtfilt(B, A, ud.D);
        end

        if f_params.medianFilterAcrossChannels
            ud.D = ud.D - repmat(median(ud.D, 2), 1, size(ud.D, 2));
        end

        % Normalize time
        if ~isempty(ud.T)
            ud.T = ud.T - ud.T(1);
        end

		set(findobj(fig,'tag','StartTxt'),'string',['Start (s)']);
		ud.D = single(ud.D);
		set(fig,'userdata',ud);
		vhNDISpikeSorter.setthresholds_gui('fig',fig,'command','DrawAxes');

	case 'MatchYAxisBt'
        % Match Y limits of all voltage axes to the current axis
		ax = gca;
		A = axis;
		theaxes = findobj(fig,'-regexp','tag','VoltageAxes*');
		for i=1:length(theaxes)
			axes(theaxes(i));
			A2 = axis;
            % Set Y limits to A(3:4), keep X limits (which are linked anyway)
			axis([A2(1) A2(2) A(3) A(4)]);
		end
		axes(ax);

	case {'StartEdit','DurationEdit'}
		newstartstring  = get(findobj(fig,'tag','StartEdit'),'string');
		newdurationstring  = get(findobj(fig,'tag','DurationEdit'),'string');
		newstartvalue = str2num(newstartstring);
		newdurationvalue = str2num(newdurationstring);
		if newstartvalue~=ud.start | newdurationvalue~=ud.windowsize
			ud.start = newstartvalue;
			ud.windowsize = newdurationvalue;
			set(fig,'userdata',ud);
			vhNDISpikeSorter.setthresholds_gui('fig',fig,'command','Load');
		end
	case 'DoneBt'
		b = 1;
		if b
			ud.success = 1;
			set(fig,'userdata',ud);
			%uiresume(fig);
			close(fig);
		else
			%errordlg(['Please make sure a quality label has been assigned to all clusters.'],'Assign quality label');
		end
	case 'CancelBt'  % there is no cancel button anymore, but we'll leave this here in case it comes back
		ud.success = 0;
		set(fig,'userdata',ud);
		uiresume(fig);
	case 'ExtractBt'
        probe_idx = get(findobj(fig,'tag','ProbePopup'),'value');
        epoch_idx = get(findobj(fig,'tag','EpochPopup'),'value');
        if ~isempty(ud.probes) && ~isempty(ud.epochs)
            probe = ud.probes{probe_idx};
            epochID = ud.epochs{epoch_idx};
            msgbox('Extracting from GUI not fully adapted to NDI epochs yet. Please use main menu Extract button.');
        end
		ud.channelhold = 1;
		set(fig,'userdata',ud);

end % switch command
