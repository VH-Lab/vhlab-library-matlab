function testcell2modifiedvectorDI(cells)

di_real = []; di_new = [];

for i=1:length(cells),
	A = findassociate(cells{i},'TP Ach OT Fit Direction index blr','','');
	B = findassociate(cells{i},'TP Ach OT vec varies p','','');
	if ~isempty(B),
		if B.data<0.05,
			di_real(end+1) = A.data;
			di_new(end+1) = cell2modifiedvectorDI(cells{i},'TP Ach');
		end;
	end;
end;

figure;
plot(di_real,di_new,'o');

axis([0 1 0 1]);

