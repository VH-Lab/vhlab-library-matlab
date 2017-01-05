function [varargout]=analyzestimlineplotsheetlet_process(fig, typeName, ds, command, varargin)
 % var input argument order list: analyzeslicecelltype
 %   
 % 

command = command(length(typeName)+1:end);

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    analyzeslicecelltype=analyzestimlineplotsheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;


switch command,
   case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}), set(findobj(fig,'tag',[typeName 'GetLineBt']),'userdata',varargin{1}); end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'GetLineBt']),'userdata'); end;
    case 'RestoreVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['analyzestimlineplotsheet' typeName],'-mat');g=getfield(g,['analyzestimlineplotsheet' typeName]);
        analyzestimlineplotsheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{:});
    case 'SaveVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata'),
        if isempty(fname), error(['Empty filename for ' typeName 'SaveVarsBt']); end;
        eval(['analyzestimlineplotsheet' typeName '={analyzeslicecelltype};']);
        eval(['save ' fname ' analyzestimlineplotsheet' typeName ' -append -mat']);
    case 'GetLineBt',
	
	[celldata,modes,conditions,sites,lmsname,lmlist,cflist,lmtype,cftype] = analyzeslicecellsheetlet_process(fig,analyzeslicecelltype,...
			ds,[analyzeslicecelltype 'GetSelection']);
	eval(['global ' lmsname '; ' lmsname '=setfield(' lmsname ', ''coordframeslist'',cflist);']);
	lm_proj = landmark_new(lmsname,'border','projectionline','1',[]);
	analyzestimlineplot(celldata,modes,conditions,sites,lmsname,lmlist,cflist,lm_proj);
	
	
    case 'Show',
	syms = {[typeName 'GetLineBt']};
	for i=1:length(syms), set(findobj(fig,'Tag',syms{i}),'visible','on'); end;
    case 'Hide',
	syms = {[typeName 'GetLineBt']};
	for i=1:length(syms), set(findobj(fig,'Tag',syms{i}),'visible','off'); end;
end;
