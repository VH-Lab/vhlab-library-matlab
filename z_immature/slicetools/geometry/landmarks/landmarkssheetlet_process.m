function [varargout]=landmarkssheetlet_process(fig, typeName, ds, command, varargin)
 % var input argument order list: lmsname, landmarklist, cfTypeName
 % 

 % if number of input arguments is 3
 %   then process a command
 % if number of arguments is 7, then set variables
 %   

command = command(length(typeName)+1:end);

command,

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [lmsname,landmarklist,cfTypeName]=landmarkssheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}), set(findobj(fig,'tag',[typeName 'LMtxt']),'userdata',varargin{1}); end;
        if length(varargin)>1&~isempty(varargin{2}), set(findobj(fig,'tag',[typeName 'LMList']),'userdata',varargin{2}); end;
        if length(varargin)>2&~isempty(varargin{3}), set(findobj(fig,'tag',[typeName 'Sorttxt']),'userdata',varargin{3}); end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'LMtxt']),'userdata'); end;
        if nargout>1, varargout{2}=get(findobj(fig,'tag',[typeName 'LMList']),'userdata'); end;
        if nargout>2, varargout{3}=get(findobj(fig,'tag',[typeName 'Sorttxt']),'userdata'); end;
    case 'AddPop',
	str = get(findobj(fig,'tag',[typeName 'AddPop']),'string');
	val = get(findobj(fig,'tag',[typeName 'AddPop']),'value');
	set(findobj(fig,'style','popup'),'visible','off');
	type = str{val};lmsname,
	coordframeslist=coordframesheetlet_process(fig,cfTypeName,[],[cfTypeName 'GetVars']);
	eval(['global ' lmsname '; ' lmsname '=setfield(' lmsname ', ''coordframeslist'',coordframeslist);']);
	eval([lmsname ',']);
	lm = landmark_new(lmsname,type,[],'1',[]);
	if ~isempty(lm),
		if isempty(landmarklist),
			landmarklist = lm;
		else,
                        % first check for duplicates
                        for i=1:length(landmarklist),
                                if strcmp(landmarklist(i).name,lm.name),
                                        error(['Duplicate landmark name ' lm.name '.']);
                                end;
                        end;
			landmarklist(end+1) = lm;
		end;
		landmarkssheetlet_process(fig,typeName,ds,[typeName 'SetVars'],[],landmarklist,[]);
		landmarkssheetlet_process(fig,typeName,ds,[typeName 'Update']);
	end;
	set(findobj(fig,'style','popup'),'visible','on');
    case 'Update',  % adding or deleting
        [mycfname,myCF] = coordframesheetlet_process(fig,cfTypeName,ds,[cfTypeName 'CurrCFName']);
	str = {}; val = [];
	for i=1:length(landmarklist),
		str{end+1} = landmark_command(landmarklist(i),'printname');
		landmarklist(i) = landmark_command(landmarklist(i),'draw',myCF,0);
	end;
	set(findobj(fig,'tag',[typeName 'LMList']),'string',str,'value',val,'max',2);
	set(findobj(fig,'tag',[typeName 'LMList']),'userdata',landmarklist); % bad form
	eval(['global ' lmsname ';']);
	eval([lmsname '=landmark_aligncf(' lmsname ', landmarklist);']);
    case 'DeleteBt',
	val = get(findobj(fig,'tag',[typeName 'LMList']),'value');
	if ~isempty(val),
		if val>0,
			for i=val,
				landmark_command(landmarklist(i),'undraw');
				landmark_command(landmarklist(i),'delete');
			end;
			landmarklist = landmarklist(setdiff(1:length(landmarklist),val));
	        	set(findobj(fig,'tag',[typeName 'LMList']),'userdata',landmarklist); % bad form
			landmarkssheetlet_process(fig,typeName,ds,[typeName 'Update']);
		end;
	end;
    case 'ShowHideBt',
	val = get(findobj(fig,'tag',[typeName 'LMList']),'value'),
	if ~isempty(val),
		if val>0,
			for i=val, if strcmp(landmarklist(i).show,'1'), landmarklist(i).show='0'; else, landmarklist(i).show = '1'; end; end;
			landmarkssheetlet_process(fig,typeName,ds,[typeName 'SetVars'],[],landmarklist,[]);
			landmarkssheetlet_process(fig,typeName,ds,[typeName 'LMList']);
		end;
	end;
    case 'SortPop',
	% update str, value, landmarklist
    case 'LMList', % change in selection
        [mycfname,myCF] = coordframesheetlet_process(fig,cfTypeName,ds,[cfTypeName 'CurrCFName']);
        currStr = get(findobj(fig,'tag',[typeName 'LMList']),'string');
        currVal = get(findobj(fig,'tag',[typeName 'LMList']),'val');
        if ~isempty(currVal)&~isempty(currStr),
                currValStr = currStr(currVal);
        else, currValStr = {};
        end;

        str = {}; val = [];
        for i=1:length(landmarklist),
                str{end+1} = landmark_command(landmarklist(i),'printname');
		A = ~isempty(intersect(currValStr,str{end}));
		if ~A, A = ~isempty(intersect(currValStr,['*' str{end}])); end;
		if ~A, A = ~isempty(intersect(currValStr,str{end}(2:end))); end;
                if A,
			val(end+1) = i;
                	landmarklist(i) = landmark_command(landmarklist(i),'draw',myCF,1);
		else,
                	landmarklist(i) = landmark_command(landmarklist(i),'draw',myCF,0);
		end;
        end;
        set(findobj(fig,'tag',[typeName 'LMList']),'string',str,'value',val,'max',2);
        set(findobj(fig,'tag',[typeName 'LMList']),'userdata',landmarklist); % bad form
    case 'RestoreVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['landmarkssheet' typeName],'-mat'); g=getfield(g,['landmarkssheet' typeName]);
	eval(['global ' g{1}]);
	eval([g{1} '=g{4};']);
        landmarkssheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{1:3});
	set(findobj(fig,'tag',[g{3} 'RestoreVarsBt']),'userdata',fname);
	coordframesheetlet_process(fig,g{3},ds,[g{3} 'RestoreVarsBt']);
        landmarkssheetlet_process(fig,typeName,ds,[typeName 'Update']);
    case 'SaveVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'SaveVarsBt']); end;
	eval(['global ' lmsname ';']);
	mylms = eval([lmsname ';']);
	% strip off all graphics handles
	for i=1:length(mylms.coordframeslist), mylms.coordframeslist(i) = coordframe_command(mylms.coordframeslist(i), 'strip'); end;
	for i=1:length(landmarklist), landmmarklist(i) = landmark_command(landmarklist(i),'strip'); end;
        eval(['landmarkssheet' typeName '={lmsname,landmarklist,cfTypeName,mylms};']);
        eval(['save ' fname ' landmarkssheet' typeName ' -append -mat']);
end;
