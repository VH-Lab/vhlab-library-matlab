function varargout = coordframe_command(cf, command, varargin)

pth1 = which(['coordframe_' cf.type '_' command]),

pth2 = which(['coordframe_' command]),

if ~isempty(pth1),
	varargout = eval(['{coordframe_' cf.type '_' command '(cf,varargin{:})};']);
elseif ~isempty(pth2),
	varargout = eval(['{coordframe_' command '(cf,varargin{:})};']);
end;
