function cf = coordframe_image_new(type,name,datain)

% DATAIN should be a struct with the following parameters:
%
%   DATA --      the image data
%   CMAP --      the color map
%   HANDLE  --   an optional handle to the image
%   PARAMETERS - a struct with preferences
%       GetPointMethod  'Ask','Manually', or 'Graphically'
%	Filename - name of the file that contains graphical image

cf.type = type;
cf.name = name;

data = [];

if nargin>2, data = datain; end;

if ~isempty(data)&~isstruct(data), % error in format
	error(['Unknown data input to coordframe_image_new']); 
end;

if isempty(data), % start over
	data.data = [];
end;

if ~isfield(data,'data'), data.data = []; end;
if ~isfield(data,'cmap'), data.cmap = []; end;
if ~isfield(data,'handle'), data.handle = []; end;
if ~isfield(data,'parameters'),
	data.parameters = struct('GetPointMethod','Ask','Filename','');
end;

if isempty(data.data),
	if isempty(data.parameters.Filename),
		[filename,pathname] = uigetfile('*.*','Open an image file...');
		data.parameters.Filename = fullfile(pathname,filename);
	end;
	[data.data,data.cmap] = imread(data.parameters.Filename);
end;

cf.data = data;
