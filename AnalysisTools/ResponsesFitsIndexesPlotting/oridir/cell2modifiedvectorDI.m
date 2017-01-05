function di = cell2modifiedvectorDI(cell, assoc_prefix)

% CELL2MODIFIEDVECTORDI - Modified vector direction index


if 0,
	A = findassociate(cell,[assoc_prefix ' OT Pref Vec'],'','');
	B = findassociate(cell,[assoc_prefix ' OT Mag Vec'],'','');
	C = findassociate(cell,[assoc_prefix ' OT Dir Pref Vec'],'','');
	D = findassociate(cell,[assoc_prefix ' OT Dir Ind Vec'],'','');

	ot_vec = exp(sqrt(-1)*A.data*pi/180);

	dir_vec = min(D.data,1) * exp(sqrt(-1)*C.data*pi/180);

	di = sqrt(abs([real(ot_vec) imag(ot_vec)] * [real(dir_vec) imag(dir_vec)]'));

elseif 1,

	A = findassociate(cell, [assoc_prefix ' OT Response curve'],'','');
	B = findassociate(cell, [assoc_prefix ' OT Blank Response'],'','');

	if ~isempty(B),
	        A.data(2,:) = A.data(2,:) -B.data(1);
	end;

	angles = A.data(1,:);

	ot_vec = A.data(2,:)*transpose(exp(sqrt(-1)*2*mod(angles*pi/180,pi)));

	dir_vec = A.data(2,:)*transpose(exp(sqrt(-1)*mod(angles*pi/180,2*pi)));

	dir_vec = dir_vec / max(A.data(2,:));

	di = sqrt(abs([real(ot_vec) imag(ot_vec)] * [real(dir_vec) imag(dir_vec)]'));

	if di>1, di = 1; end;

else,
	A = findassociate(cell, [assoc_prefix ' OT Response curve'],'','');
	B = findassociate(cell, [assoc_prefix ' OT Blank Response'],'','');

	if ~isempty(B),
	        A.data(2,:) = A.data(2,:) -B.data(1);
	end;

	angles = A.data(1,:);

	dir_vec = A.data(2,:)*transpose(exp(sqrt(-1)*mod(angles*pi/180,2*pi)));

	dir_vec = dir_vec / max(A.data(2,:));

	di = abs(dir_vec);

	if di>1, di = 1; end;


end;

