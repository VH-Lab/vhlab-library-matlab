function [varargout]=switchmenusheetlet_process(fig, typeName, ds, command, varargin)
 % menulist
 % var input argument order list: nameref, selectedcellnames, fnameextra
 %   
 % 

command = command(length(typeName)+1:end);

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [menulist]=switchmenusheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}),
                set(findobj(fig,'tag',[typeName 'SwitchPopup']),'userdata',varargin{1},'string',{varargin{1}(:).menuName},'value',1);
		switchmenusheetlet_process(fig,typeName,ds,[typeName 'SwitchPopup']);
        end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'SwitchPopup']),'userdata'); end;
    case 'RestoreVarsBt',
	return; % these vars are not saved
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty directoryname for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['switchmenusheet' typeName],'-mat');g=getfield(g,['switchmenusheet' typeName]);
        switchmenusheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{:});
    case 'SaveVarsBt',
	return; % these vars are not saved
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata'),
        if isempty(fname), error(['Empty directoryname for ' typeName 'SaveVarsBt']); end;
        eval(['switchmenusheet' typeName '={directoryname};']);
        eval(['save ' fname ' switchmenusheet' typeName ' -append -mat']);
    case 'SwitchPopup',
	val = get(findobj(fig,'tag',[typeName 'SwitchPopup']),'value');
	for i=1:length(menulist),
		if i~=val, eval([menulist(i).functionName '(fig,''' menulist(i).typeName ''', ds, ''' menulist(i).typeName 'Hide'');']);
		else, eval([menulist(i).functionName '(fig,''' menulist(i).typeName ''', ds, ''' menulist(i).typeName 'Show'');']);
		end;
	end;
end;
