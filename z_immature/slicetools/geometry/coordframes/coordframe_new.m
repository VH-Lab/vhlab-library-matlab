function cf = coordframe_new(typein,namein,datain);

type = []; name = []; data = [];

if nargin>0, type = typein; end;
if nargin>1, name = namein; end;
if nargin>2, data = datain; end;

if (nargin>0)&isempty(type)|nargin==0,
	types = coordframe_types;
	[s,v] = listdlg('PromptString','Select a coordinate frame type',...
		'SelectionMode','single','ListString',types);
	if v==0, cf = []; return; end;
	type = types{s};
elseif isempty(intersect(type,coordframe_types)),
	error(['coordframe type not known: ' type '.']);
%else, everything is okay
end;

if isempty(name),
	prompt={'Enter coordinate frame name:'};
	defaultanswer = {type};
	answer = inputdlg(prompt,'coordframe parameters',1,defaultanswer);
	if isempty(answer), cf = []; return; end;
	name = answer{1};
end;

cf = eval(['coordframe_' type '_new(type,name,data);']);
