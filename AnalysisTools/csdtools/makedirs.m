function makedirs(pathname, dirprefix, varargin)

for i=1:length(varargin),
	for j=1:length(dirprefix),
		mkdir([pathname filesep dirprefix{j} varargin{i}]);
	end;
end;
