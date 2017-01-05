function b = odicellinclude(cell, cellname, assoc_prefix, check_simple_complex)
% ODICELLINCLUDE - Examine whether a cell's ocular dominance data is significant
%
%  B = ODICELLINCLUDE(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Returns 1 if the ocular dominance data is significant

b = 0;

assoc_name_c = ['CONT Ach OT visual response p'];
assoc_name_i = ['IPSI Ach OT visual response p'];

if check_simple_complex,
	f1_f0f1 = extract_oridir_indexes(cell);
	if ~isempty(f1_f0f1),
		if 2*f1_f0f1>=1,
			F0 = findstr(assoc_prefix,'F0');
			assoc_prefix(F0:F0+1) = 'F1';
		end;
	end;
end;

A = findassociate(cell,[assoc_prefix ' ' assoc_name_c],'','');
B = findassociate(cell,[assoc_prefix ' ' assoc_name_i],'','');

if ~isempty(A) & ~isempty(B),
	b = (A.data<0.05) | (B.data<0.05);
end;


