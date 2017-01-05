function d = landmark_new(lmsname,typein,namein,showin,datain)

type = []; name = []; show = []; data = [];

if nargin>0, type = typein; end;
if nargin>1, name = namein; end;
if nargin>2, show = showin; end;
if nargin>3, data = datain; end;

if (nargin>0&isempty(type))|(nargin==0),
	types = landmark_types;
	[s,v] = listdlg('PromptString','Select a landmark type',...
			'SelectionMode','single','ListString',types);
	if v==0, d = []; return; end;
	type = types{s};
elseif isempty(intersect(type,landmark_types)),
	error(['Landmark type not known: ' type '.']);
%else, everything is okay
end;

if isempty(name)|isempty(show),
	if isempty(show), show = '1'; end;
	if isempty(name), name = type; end;
	prompt={'Enter landmark name:','Visible? (0/1)'};
	defaultanswer = {name,show};
	answer = inputdlg(prompt,'Landmark parameters',1,defaultanswer);
	if isempty(answer), d = []; return; end;
	name = answer{1};
	if strcmp(answer{2},'0'), show = '0'; else, show = '1'; end;
end;

A = isempty(data);
if ~A, A = ~isfield(data,'colorscheme'); end;

if A,
	data.colorscheme = landmarkcolorscheme;
end;

A,data,

d = eval(['landmark_' type '_new(lmsname, type,name,show,data);']);

