function [oi_theory, ois,cvs,vecmags] = TestCircularVarianceVsDIVsVec

% TESTCIRCULARVARIANCEVSOIVSVEC - A head-to-head competition between 3 orientation/direction measures
%
%
%


 % vary the amount of orientation selectivity systematically (looping over i),
 % and compute 5 repeated measurements for each amount (looping over j)

for k=1:3,
ois = [];
dis = [];
mdis = [];
oi_theory = [];
di_theory = [];
cvs = [];
dcvs = [];
for i=1:20,
	for j=1:5,
		output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',5*(k-1),'sigma',20,'doplotting',0,'dofitting',0);
		pref_theory = 10 + 5*(k-1);
		opposite_theory = 10-i/2 + 5*(k-1);
		orth_theory = 5*(k-1);
		oi_theory(i,j) = (pref_theory - orth_theory)/pref_theory;
		di_theory(i,j) = (pref_theory - opposite_theory)/pref_theory;
		cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
		dis(i,j) = compute_directionindex(output.measured_angles,output.orimn);
		dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.orimn);
	end;
end;

figure;

plot(di_theory(:),1-dcvs(:),'kx');
hold on
plot(di_theory(:),2*(1-cvs(:))-(1-dcvs(:)),'b^');
plot(mean(di_theory,2),mean(1-dcvs,2),'k-','linewidth',2);
plot(mean(di_theory,2),mean(2*(1-cvs)-(1-dcvs),2),'b-','linewidth',2);
box off;

ylabel('1-DCircVar (Black)');
xlabel('Underlying orientation selectivity index value (theoretical DSI  value)');
title(int2str(k));

end;
