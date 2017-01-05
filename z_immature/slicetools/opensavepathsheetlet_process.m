function [varargout]=opensavepathsheetlet_process(fig, typeName, ds, command, varargin)

 % var input argument order list: nameref, selectedcellnames, fnameextra
 %   
 % 

command = command(length(typeName)+1:end);

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [directoryname]=opensavepathsheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}),
                set(findobj(fig,'tag',[typeName 'OpenBt']),'userdata',varargin{1});
		[pathname,filename] = fileparts(varargin{1});
		set(findobj(fig,'tag',[typeName 'FilePathTxt']),'string',filename,'horizontalalignment','left','fontweight','bold');
        end;
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'OpenBt']),'userdata'); end;
    case 'RestoreVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty directoryname for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['opensavepathsheet' typeName],'-mat');g=getfield(g,['opensavepathsheet' typeName]);
        opensavepathsheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{:});
    case 'SaveVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata'),
        if isempty(fname), error(['Empty directoryname for ' typeName 'SaveVarsBt']); end;
        eval(['opensavepathsheet' typeName '={directoryname};']);
        eval(['save ' fname ' opensavepathsheet' typeName ' -append -mat']);
    case 'SaveBt',
	if isempty(directoryname)|strcmp(class(directoryname),'double'),
        	directoryname = uigetdir;
		ds = dirstruct(directoryname);
		ud = setfield(get(fig,'userdata'),'ds',ds);
		set(fig,'userdata',ud);
		if ischar(directoryname),
			opensavepathsheetlet_process(fig,typeName,ds,[typeName 'SetVars'],directoryname);
		else, directoryname = '';
		end;
	end;
	if ~isempty(directoryname)&~strcmp(class(directoryname),'double'),
		filename = fullfile(getscratchdirectory(ds),[typeName 'sheet.mat']);
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
	else, warning(['Could not save because there is no directoryname.']);
        end;
    case 'OpenBt',
        directoryname = uigetdir;
	ds = dirstruct(directoryname);
	ud = setfield(get(fig,'userdata'),'ds',ds);
	set(fig,'userdata',ud);
	opensavepathsheetlet_process(fig,typeName,ds,[typeName 'SetVars'],directoryname);
	filename = fullfile(getscratchdirectory(ds),[typeName 'sheet.mat']);
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
