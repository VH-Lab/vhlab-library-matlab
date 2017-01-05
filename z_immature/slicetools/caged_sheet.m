function caged_sheet(command, fig)

if nargin==0,
	command = 'init';
end;

if ishandle(command);
	fig = gcbf;
	command = get(command,'tag');
	userdata = get(fig,'userdata');
end;

switch(command),
	case 'init'
		fig = figure;
		set(gcf,'position',[100 100 900 700]);
		set(gcf,'tag','caged_sheet');
		axes('position',[0.05 0.05 .7 0.9]); axis off;
		topleft = [720-40 650];
		[h,lengthwidth]=opensavepathsheetlet('OpenSave','OpenSave',topleft);
		topleft(2) = topleft(2) - lengthwidth(2);
		[h,lengthwidth]=coordframesheetlet('CF','CF',topleft);
		topleft(2) = topleft(2) - lengthwidth(2);
		[h,lengthwidth]=landmarkssheetlet('LM','LM',topleft);
		topleft(2) = topleft(2) - lengthwidth(2)-10;
		actionMenuList = struct('typeName','AnalyzeStimLinePlot',...
			'functionName','analyzestimlineplotsheetlet_process',...
			'menuName','AnalyzeStimLinePlot');

		[h,lengthwidth]=switchmenusheetlet('Action','AM',topleft);

		topleft(2) = topleft(2) - lengthwidth(2);
		[h,lengthwidth]=analyzeslicecellsheetlet('','AnalyzeSliceCell',topleft);

		topleft(2) = topleft(2) - lengthwidth(2);
		analyzestimlineplotsheetlet('','AnalyzeStimLinePlot',topleft);

		lmsname = ['landmarkstruct' int2str(round(1000000*rand))];
		eval(['global ' lmsname]); eval([lmsname '=landmarkstruct;']);
		coordframesheetlet_process(fig,'CF',[],'LMSetVars',[],'LM');
		landmarkssheetlet_process(fig,'LM',[],'LMSetVars',lmsname,[],'CF');
		switchmenusheetlet_process(fig,'AM',[],'AMSetVars',actionMenuList);
		analyzeslicecellsheetlet_process(fig,'AnalyzeSliceCell',[],'AnalyzeSliceCellSetVars','CF','LM');
		analyzestimlineplotsheetlet_process(fig,'AnalyzeStimLinePlot',[],'AnalyzeStimLinePlotSetVars','AnalyzeSliceCell');
		
		caged_sheet('default',fig);
	case 'default',
		userdata.ds = [];
		set(fig,'userdata',userdata);
	otherwise,
		disp(['unknown command ' command ]);
end;
