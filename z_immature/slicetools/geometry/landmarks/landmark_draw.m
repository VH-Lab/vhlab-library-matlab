function nlm = landmark_draw(lm,cf, mode)

fail = 1;
if strcmp(lm.show,'1'),
	fail = 0;
	eval(  ['global ' lm.lmsname ';']);
	eval(  ['lms=' lm.lmsname ';']);

	% translate current point to current coordinate frame
	newcoords = landmark_project_point(lms, lm.data.point, lm.data.coordframename, cf.name);
	if isempty(newcoords), fail = 1;
	else,
		% make sure handles are good
		if any(~ishandle(lm.data.handle))|isempty(lm.data.handle),
			hold on;
			for i=1:length(lm.data.handle), try, delete(lm.data.handle(i)); end; end;
			lm.data.handle = [];
			lm.data.handle(1) = plot([0],[0]);
			lm.data.handle(2) = text(0,0,'','visible','off');
		end;
		if lm.data.colorscheme.showlabel, visstr = 'on'; else, visstr = 'off'; end;
		if ~isempty(lm.data.colorscheme.customlabel),
			thelmname = lm.data.colorscheme.customlabel;
		else,
			thelmname = [landmark_command(lm,'printname') lm.data.colorscheme.customlabelappend];
		end;
		newtextpt = landmark_project_point(lms, mean(lm.data.point)+lm.data.colorscheme.labeloffset,lm.data.coordframename,cf.name);
		if mode==1,
			set(lm.data.handle(1),'marker',lm.data.colorscheme.selectmarker,...
				'markersize',lm.data.colorscheme.selectmarkersize,...
				'linestyle',lm.data.colorscheme.selectlinestyle,...
				'color',lm.data.colorscheme.selectcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.selectcolor,'position',newtextpt);
		elseif ~strcmp(lm.data.coordframename,cf.name),
			set(lm.data.handle(1),'marker',lm.data.colorscheme.projectcfmarker,...
				'markersize',lm.data.colorscheme.projectcfmarkersize,...
				'linestyle',lm.data.colorscheme.projectcflinestyle,...
				'color',lm.data.colorscheme.projectcfcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.projectcfcolor,'position',newtextpt);
		else,
			set(lm.data.handle(1),'marker',lm.data.colorscheme.homecfmarker,...
				'markersize',lm.data.colorscheme.homecfmarkersize,...
				'linestyle',lm.data.colorscheme.homecflinestyle,...
				'color',lm.data.colorscheme.homecfcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.homecfcolor,'position',newtextpt);
		end;
	end;
end;

nlm = lm;

if fail,
	 nlm = landmark_command(lm,'undraw');
end;
