function [varargout]=opensave_process(fig, typeName, ds, command, varargin)

 % var input argument order list: nameref, selectedcellnames, fnameextra
 %   
 % 

command = command(length(typeName)+1:end);

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [filename]=opensavesheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}),
                set(findobj(fig,'tag',[typeName 'OpenBt']),'userdata',varargin{1});
        end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'OpenBt']),'userdata'); end;
    case 'RestoreVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty filename for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['opensavesheet' typeName],'-mat');g=getfield(g,['opensavesheet' typeName]);
        opensavesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{:});
    case 'SaveVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata'),
        if isempty(fname), error(['Empty filename for ' typeName 'SaveVarsBt']); end;
        eval(['opensavesheet' typeName '={filename};']);
        eval(['save ' fname ' opensavesheet' typeName ' -append -mat']);
    case 'SaveBt',
	if isempty(filename)|strcmp(class(filename),'double'),
        	[filename,pathname] = uiputfile('*.mat','');
		if ischar(filename),
			filename = fullfile(pathname,filename);
			opensavesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],filename);
		else, filename = '';
		end;
	end;
	if ~isempty(filename)&~strcmp(class(filename),'double'),
	        save(filename,'fig','-mat');
		bts = findobj(fig,'style','push');
		btnstr = 'SaveVars';
		for i=1:length(bts),
		if findstr(get(bts(i),'tag'),btnstr),
			set(bts(i),'userdata',filename);
			str=get(bts(i),'callback');
			quotes = findstr(str,'''');
			funcname = str(quotes(1)+1:quotes(2)-1);
			typename = str(quotes(3):quotes(4));
			eval([funcname '(fig,' typename ', ds, ' typename(1:end-1) 'SaveVarsBt'');']);
		end;
            end;
	else, warning(['Could not save because there is no filename.']);
        end;
    case 'OpenBt',
        [filename,pathname] = uigetfile('*.mat','');
	filename = fullfile(pathname,filename);
	opensavesheetlet_process(fig,typeName,ds,[typeName 'SetVars'],filename);
	if strcmp(class(filename),'double'), return; end;
        bts = findobj(fig,'style','push');
        btnstr = 'RestoreVars';
        for i=1:length(bts),
            if findstr(get(bts(i),'tag'),btnstr),
                set(bts(i),'userdata',filename);
                str=get(bts(i),'callback');
                quotes = findstr(str,'''');
                funcname = str(quotes(1)+1:quotes(2)-1);
                typename = str(quotes(3):quotes(4));
                eval([funcname '(fig,' typename ', ds, ' typename(1:end-1) 'RestoreVarsBt'');']);
            end;
        end;       
end;
