function [varargout]=analyzeslicecellsheetlet_process(fig, typeName, ds, command, varargin)
 % var input argument order list: cf, lm
 %   
 % 

command = command(length(typeName)+1:end);

if ~strcmp(command, 'GetVars')&~strcmp(command,'SetVars'),
    [cf,lm] = analyzeslicecellsheetlet_process(fig, typeName, ds, [typeName 'GetVars']);
end;

switch command,
    case 'SetVars',
        if length(varargin)>0&~isempty(varargin{1}), set(findobj(fig,'tag',[typeName 'CellTxt']),'userdata',varargin{1}); end;  % CF name
        if length(varargin)>1&~isempty(varargin{2}), set(findobj(fig,'tag',[typeName 'ModeTxt']),'userdata',varargin{2}); end;  % LM name
    case 'GetVars',
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'CellTxt']),'userdata'); end;
        if nargout>1, varargout{2}=get(findobj(fig,'tag',[typeName 'ModeTxt']),'userdata'); end;
    case 'RestoreVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'RestoreVarsBt']),'userdata');
        if isempty(fname), error(['Empty directoryname for ' typeName 'RestoreVarsBt']); end;
        g = load(fname,['analyzeslicecellsheet' typeName],'-mat');g=getfield(g,['analyzeslicecellsheet' typeName]);
        analyzeslicecellsheetlet_process(fig,typeName,ds,[typeName 'SetVars'],g{:});
        analyzeslicecellsheetlet_process(fig,typeName,ds,[typeName 'Update']);
    case 'SaveVarsBt',
        fname = get(findobj(fig,'tag',[typeName 'SaveVarsBt']),'userdata'),
        if isempty(fname), error(['Empty directoryname for ' typeName 'SaveVarsBt']); end;
        eval(['analyzeslicecellsheet' typeName '={cf,lm};']);
        eval(['save ' fname ' analyzeslicecellsheet' typeName ' -append -mat']);
    case 'Update',
        if ~isempty(ds),
                cn = {};
                nr = getallnamerefs(ds);
                for i=1:length(nr),
                        if strcmp(nr(i).type, 'slicepatch'), cn{end+1} = [nr(i).name ' | ' int2str(nr(i).ref) ]; end;
                end;
                set(findobj(fig,'tag',[typeName 'CellPopup']),'string',cn,'userdata',nr);
        end;
    case 'CellLoadBt',
	pn = getpathname(ds);
	str = get(findobj(fig,'tag',[typeName 'CellPopup']),'string');
	val = get(findobj(fig,'tag',[typeName 'CellPopup']),'value');
	if ~isempty(str)&val>0,
		s = findstr(str{val},' | ');
		dirs = gettests(ds, str{val}(1:s-1), str2num(str{val}(s+3:end)));
		disp(['Reading slice data....']);
		traces = extract_caged_slice([pn dirs{1}],[0 0.1],[-0.7 0.1]);
		for i=2:length(dirs),
			traces = cat(2,traces,...
				extract_caged_slice([pn dirs{i}],[0 0.1],[-0.7 0.1]));
		end;
		set(findobj(fig,'tag',[typeName 'CellLoadBt']),'userdata',traces);
		% extract, mode, condition, stim sites
		VhIh = [ [traces.Vh]' [traces.Ih]'];
		conditions = unique({traces.condition});
		sites = unique([traces.position_label]);
		set(findobj(fig,'Tag',[typeName 'ConditionList']),'string',conditions,'value',1,'max',2);
		set(findobj(fig,'Tag',[typeName 'SitesList']),'string',num2str(sites(:)),'value',1:length(sites),'max',2);
		strs = {};
		r = unique(VhIh,'rows');
		for i=1:size(r,1),
			strs{end+1} = ['Vh=' num2str(r(i,1)) ',Ih=' num2str(r(i,2)) ];
		end;
		set(findobj(fig,'Tag',[typeName 'ModeList']),'string',strs,'value',1,'max',2,'userdata',r);
	end;
    case 'GetSelection',
	modeVal = get(findobj(fig,'Tag',[typeName 'ModeList']),'value');
	modeUD =  get(findobj(fig,'Tag',[typeName 'ModeList']),'userdata');
	condVal = get(findobj(fig,'Tag',[typeName 'ConditionList']),'value');
	condStr = get(findobj(fig,'Tag',[typeName 'ConditionList']),'string');
	sitesVal = get(findobj(fig,'Tag',[typeName 'SitesList']),'value');
	sitesStr = get(findobj(fig,'Tag',[typeName 'SitesList']),'string');
	[lmname,landmarklist]=landmarkssheetlet_process(fig,lm,[],[lm 'GetVars']);
	coordframeslist=coordframesheetlet_process(fig,cf,[],[cf 'GetVars']);
        if nargout>0, varargout{1}=get(findobj(fig,'tag',[typeName 'CellLoadBt']),'userdata'); end;
	if nargout>1, varargout{2}=modeUD(modeVal,:); end;
	if nargout>2, varargout{3}=condStr(condVal); end;
	if nargout>3, varargout{4}=sitesStr(sitesVal); end;
	if nargout>4, varargout{5}=lmname; end;
	if nargout>5, varargout{6}=landmarklist; end;
	if nargout>6, varargout{7}=coordframeslist; end;
	if nargout>7, varargout{8}=lm; end;
	if nargout>8, varargout{9}=cf; end;
    case 'Show',
	sym = {'CellTxt','CellPopup','CellLoadBt','ModeTxt','ModeList','ConditionTxt','ConditionList','SitesTxt',...
			'SitesList'};
	for i=1:length(sym), set(findobj(fig,'tag',[typeName sym{i}]),'visible','on'); end;
        analyzeslicecellsheetlet_process(fig,typeName,ds,[typeName 'Update']);
    case 'Hide',
	sym = {'CellTxt','CellPopup','CellLoadBt','ModeTxt','ModeList','ConditionTxt','ConditionList','SitesTxt',...
			'SitesList'};
	for i=1:length(sym), set(findobj(fig,'tag',[typeName sym{i}]),'visible','off'); end;
end;
