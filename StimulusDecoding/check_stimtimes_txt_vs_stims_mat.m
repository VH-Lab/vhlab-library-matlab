function [results,errorstring,has_error,has_warning,errors_fixed] = check_stimtimes_txt_vs_stims_mat(ds, varargin)
% CHECK_STIMTIMES_TXT_VS_STIMS_MAT - Compare output of Spike2 output file stimtimes.txt and stimulus computer output stims.mat
%
%   [RESULTS,ERRORSTRING,HAS_ERROR,HAS_WARNING,ERRORS_FIXED] = CHECK_STIMTIMES_TXT_VS_STIMS_MAT(DS, ...)
%
%   INPUTS:  DS should be a DIRSTRUCT object that manages the experimental directory
%   to be examined. One can pass additional name/value pairs to modify the behavior
%   of this function:
%   NAME (default value):      | Description:
%   ------------------------------------------------------------------------------
%   'verbose' (1)              | Print output to the command line
%   'graphical_output' (1)     | Also display output via graphical user interface
%   'generate_error' (0)       | Generate a function error if an error is found. This
%                              |   error will not be generated if errors are only found
%                              |   in inactive directories (those with no 'reference.txt' file).
%   'name' ('')                | Restrict work to directories that include a specific
%                              |   name/ref pair. Ignored if either is empty.
%   'ref' ([])                 | Restrict work to directories that include a specific
%                              |   name/ref pair. Ignored if either is empty.
%   'fixit' (0)                | Should we try to fix the errors we know how to fix?
%                              |   The original stimtimes.txt files are preserved
%                              |   as 'stimtimes_original.txt'.
%   
%   Outputs: RESULTS is a structure with 1 entry per folder in the
%   experiment directory that is managed by DIRSTRUCT DS. ERRORSTRING is a string list
%   that explains all of the notable errors. HAS_ERROR is 1 if there is an error. HAS_WARNING
%   is 1 if there is a warning. ERRORS_FIXED is 1 if all errors were fixed.
%
%   The fields of the RESULTS structure are the following:
%   Fieldname:                 | Description:
%   --------------------------------------------------------------------------------
%   dirname                    | The directory name
%   has_reference_txt          | 0/1 does the directory have a 'reference.txt' file?  
%   stimtimes_txt_stimcodelist | A list of stimulus ID codes extracted from the
%                              |    'stimtimes.txt' file
%   stims_mat_stimcodelist     | A list of stimulus ID codes extracted from the 
%                              |    'stims.mat' file 
%   error_code                 | An error code that describes whether there were
%                              |    any errors in comparing these results. 
%                              |    0 indicates no error. The following values are
%                              |    added to the error_code for each error (more than
%                              |    one of these errors can occur).
%                              |    1 - no stimtimes.txt file
%                              |    2 - stimtimes.txt not valid
%                              |    4 - no stims.mat file
%                              |    8 - stims.mat not valid
%                              |    16 - stimcode lists do not match
%                              |    32 - stimtimes.txt has more triggers than expected
%                              |    64 - stimtimes.txt triggers is bigger than expected but
%                              |           contains a record of stims.mat stimids in the right order
%                              |           exactly once
%                              |    128 - stimtimes.txt has fewer triggers than stims.mat (usually no recovery possible)
%                              |    256 - stimtimes.txt contains a stimid of 0
%   noteable_error             | 0/1 Is there a notable error? A notable error is one with
%                              |    code 2 (but not 1), 8 (but not 4), 16, or 32.
%                        
%  See also: REFERENCE_TXT, STIMTIMES_TXT
%

   % assign default variables, overwrite with any user-provided values
verbose = 1;
graphical_output = 1;
generate_error = 0;
name = '';
ref = [];
fixit = 0;

assign(varargin{:});

thepath = getpathname(ds);

if ~isempty(name) & ~isempty(ref),
	D = gettests(ds,name,ref);
else,
	D = dirlist_trimdots(dir(thepath));
end;

results = struct('dirname','','has_reference_txt',0,'stimtimes_txt_stimcodelist',0,'stims_mat_stimcodelist',0,'error_code',0,'notable_error',0);
results = results([]); % make it empty initially

for i=1:length(D),
	resultshere.dirname = D{i};
	resultshere.has_reference_txt = exist([thepath filesep D{i} filesep 'reference.txt'],'file');

	% examine stimtimes_txt
	resultshere.stimtimes_txt_stimcodelist = [];

	stimtimes_exists = exist([thepath filesep D{i} filesep 'stimtimes.txt'],'file');
	stimtimes_valid = 0;
	if stimtimes_exists,
		try,
			resultshere.stimtimes_txt_stimcodelist = read_stimtimes_txt([thepath filesep D{i}]);
			stimtimes_valid = 1;
		end;
	end;

	% examine stims.mat

	resultshere.stims_mat_stimcodelist = [];

	stimsmat_exists = exist([thepath filesep D{i} filesep 'stims.mat'],'file');
	stimsmat_valid = 0;

	if stimsmat_exists,
		try,
			z = load([thepath filesep D{i} filesep 'stims.mat'],'-mat');
			for j=1:length(z.MTI2),
				resultshere.stims_mat_stimcodelist(end+1) = z.MTI2{j}.stimid;
			end;
			stimsmat_valid = 1;
		end;
	end;

	error_code = 0;

	if ~stimtimes_exists, error_code = error_code + 1; end; % no stimtimes file
	if ~stimtimes_valid, error_code = error_code + 2; end; % not valid
	if ~stimsmat_exists, error_code = error_code + 4; end; % no stimsmat file
	if ~stimsmat_valid, error_code = error_code + 8; end; % not valid

	if ~eqlen(resultshere.stims_mat_stimcodelist,resultshere.stimtimes_txt_stimcodelist),
		error_code = error_code + 16; % stimcodes do not match
	end;

	if length(resultshere.stimtimes_txt_stimcodelist) > length(resultshere.stims_mat_stimcodelist),
		error_code = error_code + 32; % stimtimes_txt longer than stims_mat 
	end;

	K = strfind(resultshere.stimtimes_txt_stimcodelist, resultshere.stims_mat_stimcodelist);

	if length(K)==1 & bitget(error_code,6),
		error_code = error_code + 64; % stimtimes_txt containers stims_mat version exactly once
	end;

	if length(resultshere.stimtimes_txt_stimcodelist) < length(resultshere.stims_mat_stimcodelist),
		error_code = error_code + 128; % stimtimes_txt shorter than stims_mat 
	end;

	if any(find(resultshere.stimtimes_txt_stimcodelist==0)),
		error_code = error_code + 256; % stimtimes_txt contains a 0
	end;

	resultshere.error_code = error_code;

	resultshere.notable_error = (error_code>=16) | (bitget(error_code,2) & ~bitget(error_code,1)) | (bitget(error_code,4) & ~bitget(error_code,3));

	results(end+1) = resultshere;
end;

 % now make errorstring
errorstring = {};

has_error = 0;
has_warning = 0;

for i=1:length(results),
	mystr = '';
	if results(i).notable_error,
		if results(i).has_reference_txt,
			mystr = ['ERROR in active directory ' D{i} ': '];
			has_error = 1;
		else,
			mystr = ['Warning in inactive (no reference.txt) directory ' D{i} ': '];
			has_warning = 1;
		end;
		if bitget(results(i).error_code,1), mystr = [mystr ' no stimtimes.txt file; ']; end;
		if bitget(results(i).error_code,2), mystr = [mystr ' invalid stimtimes.txt file; ']; end;
		if bitget(results(i).error_code,3), mystr = [mystr ' no stims.mat file; ']; end;
		if bitget(results(i).error_code,4), mystr = [mystr ' invalid stims.mat file; ']; end;
		if bitget(results(i).error_code,5), mystr = [mystr ' stimcode lists do not match; ']; end;
		if bitget(results(i).error_code,6), mystr = [mystr ' stimtimes.txt has more triggers than stims.mat; ']; end;
		if bitget(results(i).error_code,7), mystr = [mystr ' stimtimes.txt stimcodes contain stims.mat stimcodes in correct order exactly once; ']; end;
		if bitget(results(i).error_code,8), mystr = [mystr ' stimtimes.txt stimcodes are smaller than stims.mat stimcodes; ']; end;
		if bitget(results(i).error_code,9), mystr = [mystr ' stimtimes.txt stimcodes contain a stimid of 0; ']; end;
		% assume we posted at least one error and have to remove the semicolon and space
		mystr = mystr(1:end-2);
		errorstring{end+1} = mystr;
	end;
end;

errors_fixed = has_error;

if fixit,
	we_fixed_all_errors = 1;

	for i=1:length(results),
		if results(i).notable_error,
			if results(i).has_reference_txt,
				ifixedthisone = 0;
				if bitget(results(i).error_code,8), % Spike2 did not acquire as long as it should have, we are screwed
						% this bit of code has no error handling now; is that okay?
					% move reference.txt to reference0.txt, make a note about it in a 'whyignored.txt' file
					if exist([thepath filesep results(i).dirname filesep 'reference0.txt'],'file'), delete([thepath filesep results(i).dirname filesep 'reference0.txt']); end;
					movefile([thepath filesep results(i).dirname filesep 'reference.txt'],[thepath filesep results(i).dirname filesep 'reference0.txt']);
					errorstring{end+1} = ['FIXED (sort of): Cannot reconcile directory ' results(i).dirname '; Spike2 did not record enough data. Rendering inactive (reference0.txt)'];
					fid = fopen([thepath filesep results(i).dirname filesep 'whyignored.txt'],'wt');
					if fid<0, error(['Could not open file ' results(i).dirname filesep 'whyignored.txt for writing.']); end;  % fix this
					fprintf(fid,'Spike2 did not record enough data to make any correspondence to the stims.mat file.\r\n');
					fclose(fid);
					ifixedthisone = 1;
				end;
				
				if ~ifixedthisone & bitget(results(i).error_code,6),
					canwefixit = 0;
					try,
						fix_stimtimes_txt_glitch([thepath filesep results(i).dirname], 'makenochanges',1);
						canwefixit = 1;
					end;
					if canwefixit,
						summary = fix_stimtimes_txt_glitch([thepath filesep results(i).dirname], 'makenochanges',0);
						errorstring{end+1} = ['FIXED: ' results(i).dirname '...'];
						errorstring = cat(2,errorstring,summary);
					end;
					we_fixed_all_errors = we_fixed_all_errors * canwefixit;
					ifixedthisone = 1;
				end;
	
				if ~ifixedthisone,
					errorstring{end+1} = ['***NOT FIXED: ' results(i).dirname '.'];
					we_fixed_all_errors = 0;
				end;
			end;
		end;
	end;
	errors_fixed = we_fixed_all_errors;
end;

if verbose & (has_warning|has_error)
	display(textwrap(errorstring,80));
end;

if graphical_output & (has_warning|has_error)
	textbox('Errors in corresondence between stimtimes.txt, stims.mat' ,errorstring);
end;

if generate_error & has_error,
	error(errorstring);
end;


