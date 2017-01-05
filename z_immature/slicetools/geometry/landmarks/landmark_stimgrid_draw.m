function nlm = landmark_stimgrid_draw(lm,cf,mode)

fail = 1;

if strcmp(lm.show,'1'),
	fail = 0;
        eval(  ['global ' lm.lmsname ';']);
        eval(  ['lms=' lm.lmsname ';']);

	pts = lm.data.pts;
	gridlocs = lm.data.gridlocs;

	if ~isfield(lm.data,'M'), mm =[];
	else, mm = min(lm.data.M,lm.data.N);
	end;
	if ~isempty(mm)&mm>1, grid = 1; else, grid = 0; end;

	if grid,
		newcoords=landmark_project_point(lms,lm.data.gridlocs,lm.data.coordframename,cf.name);
	else,
		newcoords=landmark_project_point(lms,lm.data.pts,lm.data.coordframename,cf.name);
	end;
	if ~isempty(newcoords),
		if any(~ishandle(lm.data.handle))|isempty(lm.data.handle),
			hold on;
			for i=1:length(lm.data.handle), try, delete(lm.data.handle(i)); end; end;
			lm.data.handle = [];
			if grid,
				for i=1:2:size(newcoords,1),
					lm.data.handle(end+1) = plot(newcoords(i:i+1,1),newcoords(i:i+1,2),'--');
					lm.data.handle(end+1) = text(0,0,'','visible','off','horizontalalignment','center');
				end;
			else,
				lm.data.handle(end+1) = plot(newcoords(:,1),newcoords(:,2),'x');
				lm.data.handle(end+1) = text(0,0,'','visible','off','horizontalalignment','center');
			end;
		end;
		if lm.data.colorscheme.showlabel, visstr = 'on'; else, visstr = 'off'; end;
		if ~isempty(lm.data.colorscheme.customlabel), thelmname = lm.data.colorscheme.customlabel;
                else, thelmname = [landmark_command(lm,'printname') lm.data.colorscheme.customlabelappend];
                end;
                newtextpt = landmark_project_point(lms, mean(lm.data.pts)+lm.data.colorscheme.labeloffset,lm.data.coordframename,cf.name);
       		if mode==1,
			if grid,
				for i=1:2:size(newcoords,1),
					set(lm.data.handle(i), 'linestyle','-', 'marker','none',...
						'color',lm.data.colorscheme.selectcolor,'xdata',newcoords(i:i+1,1),'ydata',newcoords(i:i+1,2));
                			newtextpt = landmark_project_point(lms, lm.data.pts((i+1)/2,:)+lm.data.colorscheme.labeloffset,lm.data.coordframename,cf.name);
					set(lm.data.handle(i+1),'string',int2str((i+1)/2),'visible',visstr,'color',lm.data.colorscheme.selectcolor,'position',newtextpt);
				end;
			else,
				set(lm.data.handle(1), 'marker','x', 'markersize', 2*lm.data.colorscheme.selectmarkersize, 'linestyle','none',...
					'color',lm.data.colorscheme.selectcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
				set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.selectcolor,'position',newtextpt);
			end;
		elseif ~strcmp(lm.data.coordframename,cf.name),
			if grid,
				for i=1:2:size(newcoords,1),
					set(lm.data.handle(i),'marker','none', 'linestyle','-',...
						'color',lm.data.colorscheme.projectcfcolor,'xdata',newcoords(i:i+1,1),'ydata',newcoords(i:i+1,2));
					set(lm.data.handle(i+1),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.projectcfcolor,'position',newtextpt);
				end;
			else,
				set(lm.data.handle(1),'marker','x','markersize',2*lm.data.colorscheme.projectcfmarkersize,'linestyle','none',...
					'color',lm.data.colorscheme.projectcfcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
				set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.projectcfcolor,'position',newtextpt);
			end;
		else,
			if grid,
				for i=1:2:size(newcoords,1),
					set(lm.data.handle(i),'marker','none', 'linestyle','-',...
						'color',lm.data.colorscheme.homecfcolor,'xdata',newcoords(i:i+1,1),'ydata',newcoords(i:i+1,2));
					set(lm.data.handle(i+1),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.homecfcolor,'position',newtextpt);
				end;
			else,
				set(lm.data.handle(1),'marker','x',...
					'markersize',2*lm.data.colorscheme.homecfmarkersize,...
					'linestyle','none',...
					'color',lm.data.colorscheme.homecfcolor,'xdata',newcoords(:,1),'ydata',newcoords(:,2));
				set(lm.data.handle(2),'string',thelmname,'visible',visstr,'color',lm.data.colorscheme.homecfcolor,'position',newtextpt);

			end;
		end;
	else, fail = 1;
	end;
end;

nlm = lm;

if fail, nlm = landmark_command(lm,'undraw'); end;
