function trace = extract_caged_slice(dirname, analysis_window, baseline_window)

trace = '';

[pathstr, filename] = fileparts(dirname);

A = dir([fixpath([pathstr filesep filename]) '*.ABF']);  % get directory contents
gotone = 0;

for i=1:length(A),
	if findstr(A(i).name,'.ABF'),
		fullfile(pathstr,filename,A(i).name),
		if ~gotone,
			trace=extract_caged_traces(fullfile(pathstr,filename,A(i).name),analysis_window,baseline_window);
			gotone = 1;
		else,
			trace=[trace; ...
			extract_caged_traces(fullfile(pathstr,filename,A(i).name),analysis_window,baseline_window)];
		end;
	end;
end;

trace = reshape(trace,1,prod(size(trace)));
