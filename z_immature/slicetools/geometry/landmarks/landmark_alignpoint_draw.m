function nlm = landmark_point_draw(lm,cf, mode)

fail = 1;
if strcmp(lm.show,'1'),
	fail = 0;
	eval(  ['global ' lm.lmsname ';']);
	eval(  ['lms=' lm.lmsname ';']);

	% translate current point to current coordinate frame
	newcoords1 = landmark_project_point(lms, lm.data.point1, lm.data.coordframe1name, cf.name);
	newcoords2 = landmark_project_point(lms, lm.data.point2, lm.data.coordframe2name, cf.name);
	if ~isempty(newcoords1),
		% make sure handles are good
		A = isempty(lm.data.handle);
		B = 1;
		if ~A, B = any(~ishandle(lm.data.handle(1:2)))|any(lm.data.handle(1:2)==0); end;
		if A|B,
			hold on;
			for i=1:2, try, delete(lm.data.handle(i)); end; end;
			lm.data.handle(1) = plot([0],[0]);
			lm.data.handle(2) = text(0,0,'','visible','off');
		end;
		if lm.data.colorscheme.showlabel, visstr = 'on'; else, visstr = 'off'; end;
		if ~isempty(lm.data.colorscheme.customlabel),
			thelmname = lm.data.colorscheme.customlabel;
		else,
			thelmname = [landmark_command(lm,'printname') lm.data.colorscheme.customlabelappend];
		end;
		newtextpt = landmark_project_point(lms, mean(lm.data.point1)+lm.data.colorscheme.labeloffset,lm.data.coordframe1name,cf.name);
		if mode==1,
			set(lm.data.handle(1),'marker',lm.data.colorscheme.selectmarker,...
				'markersize',lm.data.colorscheme.selectmarkersize,...
				'linestyle',lm.data.colorscheme.selectlinestyle,...
				'color',lm.data.colorscheme.selectcolor,'xdata',newcoords1(:,1),'ydata',newcoords1(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.selectcolor,'position',newtextpt);
		elseif ~strcmp(lm.data.coordframe1name,cf.name),
			set(lm.data.handle(1),'marker',lm.data.colorscheme.projectcfmarker,...
				'markersize',lm.data.colorscheme.projectcfmarkersize,...
				'linestyle',lm.data.colorscheme.projectcflinestyle,...
				'color',lm.data.colorscheme.projectcfcolor,'xdata',newcoords1(:,1),'ydata',newcoords1(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.projectcfcolor,'position',newtextpt);
		else,
			set(lm.data.handle(1),'marker',lm.data.colorscheme.homecfmarker,...
				'markersize',lm.data.colorscheme.homecfmarkersize,...
				'linestyle',lm.data.colorscheme.homecflinestyle,...
				'color',lm.data.colorscheme.homecfcolor,'xdata',newcoords1(:,1),'ydata',newcoords1(:,2));
			set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.homecfcolor,'position',newtextpt);
		end;
	else, % if nothing to draw, delete it
		for i=1:2, try, delete(lm.data.handle(i)); end; end;
	end;
	if ~isempty(newcoords2),
		% make sure handles are good
		A = isempty(lm.data.handle);
		if ~A, B = length(lm.data.handle)>2; end;
		if B, B = any(~ishandle(lm.data.handle(3:4)))&any(lm.data.handle(3:4)==0); else, B = 1; end;
		if A|B,
			hold on;
			for i=3:4, try, delete(lm.data.handle(i)); end; end;
			lm.data.handle(3) = plot([0],[0]);
			lm.data.handle(4) = text(0,0,'','visible','off');
		end;
		if lm.data.colorscheme.showlabel, visstr = 'on'; else, visstr = 'off'; end;
		if ~isempty(lm.data.colorscheme.customlabel),
			thelmname = lm.data.colorscheme.customlabel;
		else,
			thelmname = [landmark_command(lm,'printname') lm.data.colorscheme.customlabelappend];
		end;
		newtextpt = landmark_project_point(lms, mean(lm.data.point2)+lm.data.colorscheme.labeloffset,lm.data.coordframe2name,cf.name);
		if mode==1,
			set(lm.data.handle(3),'marker',lm.data.colorscheme.selectmarker,...
				'markersize',lm.data.colorscheme.selectmarkersize,...
				'linestyle',lm.data.colorscheme.selectlinestyle,...
				'color',lm.data.colorscheme.selectcolor,'xdata',newcoords2(:,1),'ydata',newcoords2(:,2));
			set(lm.data.handle(4),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.selectcolor,'position',newtextpt);
		elseif ~strcmp(lm.data.coordframe2name,cf.name),
			set(lm.data.handle(3),'marker',lm.data.colorscheme.projectcfmarker,...
				'markersize',lm.data.colorscheme.projectcfmarkersize,...
				'linestyle',lm.data.colorscheme.projectcflinestyle,...
				'color',lm.data.colorscheme.projectcfcolor,'xdata',newcoords2(:,1),'ydata',newcoords2(:,2));
			set(lm.data.handle(4),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.projectcfcolor,'position',newtextpt);
		else,
			set(lm.data.handle(3),'marker',lm.data.colorscheme.homecfmarker,...
				'markersize',lm.data.colorscheme.homecfmarkersize,...
				'linestyle',lm.data.colorscheme.homecflinestyle,...
				'color',lm.data.colorscheme.homecfcolor,'xdata',newcoords2(:,1),'ydata',newcoords2(:,2));
			set(lm.data.handle(4),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.homecfcolor,'position',newtextpt);
		end;
	else,
		for i=3:4, try, delete(lm.data.handle(i)); end; end;
	end;
end;

nlm = lm;

if fail,
	 nlm = landmark_command(lm,'undraw');
end;
