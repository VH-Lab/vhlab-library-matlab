function pos = get_stim_position(filename, position_label)

[filepath,name] = fileparts(filename);

try,
	G = load([fixpath(filepath) 'stimpositions.txt'],'-ascii');

	inds = find(position_label==G(:,1));

	if ~isempty(inds),
		pos = G(inds,[2 3]);
	else,
		pos = [NaN NaN];
	end;

catch,
	pos = [NaN NaN];
end;
