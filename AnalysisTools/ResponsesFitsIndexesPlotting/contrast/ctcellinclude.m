function b = ctcellinclude(cell, cellname, assoc_prefix, check_simple_complex)
% CTCELLINCLUDE - Examine whether a cell's spatial frequency data is significant
%
%  B = CTCELLINCLUDE(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Returns 1 if the contrast data is significant.

b = 0;

assoc_name = ['CT visual response p'];

if check_simple_complex,
	f1_f0f1 = extract_oridir_indexes(cell);
	if ~isempty(f1_f0f1),
		if 2*f1_f0f1>=1,
			F0 = findstr(assoc_prefix,'F0');
			assoc_prefix(F0:F0+1) = 'F1';
		end;
	end;
end;

A = findassociate(cell,[assoc_prefix ' ' assoc_name],'','');

if ~isempty(A),
	b = A.data<0.05;
end;

