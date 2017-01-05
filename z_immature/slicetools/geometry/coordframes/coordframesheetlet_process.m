function [varargout]=coordframesheetlet_process(fig, typeName, ds, command, varargin)
 % var input argument order list: coordframelist, landmarkTypeName
 % 

 % if number of input arguments is 3
 %   then process a command
 % if number of arguments is 7, then set variables
 %   revstim1, test1, revstim2, test2, ctrloc, cb1, cb2

command = command(length(typeName)+1:end);

command,

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [coordframelist,landmarkTypeName]=coordframesheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}), set(findobj(fig,'tag',[typeName 'CFList']),'userdata',varargin{1}); end;
        if length(varargin)>1&~isempty(varargin{2}), set(findobj(fig,'tag',[typeName 'CFtxt']),'userdata',varargin{2}); end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'CFList']),'userdata'); end;
        if nargout>1, varargout{2}=get(findobj(fig,'tag',[typeName 'CFtxt']),'userdata'); end;
    case 'AddPop',
	str = get(findobj(fig,'tag',[typeName 'AddPop']),'string');
	val = get(findobj(fig,'tag',[typeName 'AddPop']),'value');
	set(findobj(fig,'tag',[typeName 'AddPop']),'visible','off');
	type = str{val};
	cf = coordframe_new(type,[],[]);
	if ~isempty(cf),
		if isempty(coordframelist),
			coordframelist = cf;
		else,
			% first check for duplicates
			for i=1:length(coordframelist),
				if strcmp(coordframelist(i).name,cf.name),
					error(['Duplicate coordframe name ' cf.name '.']);
				end;
			end;
			coordframelist(end+1) = cf;
		end;
		coordframesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],coordframelist);
		coordframesheetlet_process(fig,typeName,ds,[typeName 'Update']);
	end;
	set(findobj(fig,'tag',[typeName 'AddPop']),'visible','on');
    case 'CFList',
	coordframesheetlet_process(fig,typeName,ds,[typeName 'Update']);
    case 'CurrCFName',
	newstr = get(findobj(fig,'tag',[typeName 'CFList']),'string');
	newval = get(findobj(fig,'tag',[typeName 'CFList']),'value');
	if ~isempty(newval)&~isempty(newstr),
		newvalstr = newstr{newval};
		CF = coordframelist(newval);
	else, newvalstr = ''; CF = [];
	end;
	if nargout>0, varargout{1} = newvalstr; end;
	if nargout>1, varargout{2} = CF; end;
    case 'Update',
	newstr = get(findobj(fig,'tag',[typeName 'CFList']),'string');
	newval = get(findobj(fig,'tag',[typeName 'CFList']),'value');
	if ~isempty(newval)&~isempty(newstr),
		newvalstr = newstr{newval};
	else, newvalstr = '';
	end;
	
	str = {};
	val = [];
	for i=1:length(coordframelist),
		str{end+1} = coordframelist(i).name;
		if i==newval&strcmp(str{end},newvalstr),
			val = i;
			coordframelist(i) = coordframe_command(coordframelist(i),'draw');
		else,
			coordframelist(i) = coordframe_command(coordframelist(i),'undraw');
		end;
	end;
	if length(str)~=0&isempty(val),
		val = 1;
		coordframelist(val) = coordframe_command(coordframelist(val),'draw');
	end;
	coordframesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],coordframelist);
	set(findobj(fig,'tag',[typeName 'CFList']),'string',str,'value',val);
	if ~isempty(landmarkTypeName), 
		disp('forcing landmark update.');
		landmarkssheetlet_process(fig,landmarkTypeName,ds,[landmarkTypeName 'LMList']);
	end;
	axis auto;
    case 'DeleteBt',
	val = get(findobj(fig,'tag',[typeName 'CFList']),'value');
	if ~isempty(val),
		if val>0,
			coordframe_command(coordframelist(val),'undraw');
			coordframelist = coordframelist(setdiff(1:length(coordframelist),val));
			coordframesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],coordframelist);
			coordframesheetlet_process(fig,typeName,ds,[typeName 'Update']);
		end;
	end;
    case 'SortPop',
	% must do all shuffling, set variables
    case 'RestoreVarsBt',
	for i=1:length(coordframelist), % delete all old variables
		coordframe_command(coordframelist(i), 'undraw');
		coordframe_command(coordframelist(i), 'delete');
	end;
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['coordframesheet' typeName],'-mat'); g=getfield(g,['coordframesheet' typeName]);
	cfs = g{1};
	for i=1:length(cfs), cfs(i) = coordframe_new(cfs(i).type,cfs(i).name,cfs(i).data); end;
        coordframesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],cfs);%,g{2});
        coordframesheetlet_process(fig,typeName,ds,[typeName 'Update']);
    case 'SaveVarsBt',
	for i=1:length(coordframelist), coordframelist(i) = coordframe_command(coordframelist(i),'strip'); end;
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'SaveVarsBt']); end;
        eval(['coordframesheet' typeName '={coordframelist,landmarkTypeName};']);
        eval(['save ' fname ' coordframesheet' typeName ' -append -mat']);
end;
