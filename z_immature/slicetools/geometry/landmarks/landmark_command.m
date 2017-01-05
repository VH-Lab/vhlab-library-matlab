function varargout = landmark_command(lm, command, varargin)

pth1 = which(['landmark_' lm.type '_' command]);

pth2 = which(['landmark_' command]);

if ~isempty(pth1),
	varargout = eval(['{landmark_' lm.type '_' command '(lm,varargin{:})};']);
elseif ~isempty(pth2),
	varargout = eval(['{landmark_' command '(lm,varargin{:})};']);
end;
