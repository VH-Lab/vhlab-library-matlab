function [oi_theory, ois,cvs,vecmags] = TestCircularVarianceVsOIVsVec

% TESTCIRCULARVARIANCEVSOIVSVEC - A head-to-head competition between 3 orientation measures
%
%
%

ois = [];
oi_theory = [];
cvs = [];
vecmags = [];

 % vary the amount of orientation selectivity systematically (looping over i),
 % and compute 5 repeated measurements for each amount (looping over j)

for i=1:20,
	for j=1:5,
		output = OriDirCurveDemo('Rp',i,'Rn',i,'Rsp',10-i/2,'sigma',20,'doplotting',0,'dofitting',0);
		pref_theory = i+10-i/2;
		orth_theory = 10-i/2;
		oi_theory(i,j) = (pref_theory - orth_theory)/pref_theory;
		ois(i,j) = compute_orientationindex(output.measured_angles,output.orimn);
		cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
		vecmags(i,j) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
	end;
end;

figure;

plot(oi_theory(:),ois(:),'go');
hold on
plot(oi_theory(:),1-cvs(:),'kx');
plot(oi_theory(:),vecmags(:),'rs');
plot(mean(oi_theory,2),mean(ois,2),'g-','linewidth',2);
plot(mean(oi_theory,2),mean(vecmags,2),'r-','linewidth',2);
plot(mean(oi_theory,2),mean(1-cvs,2),'k-','linewidth',2);
box off;

ylabel('Traditional OSI (Green), Vector magnitude (Red), 1-CircVar (Black)');
xlabel('Underlying orientation selectivity index value (theoretical OSI value)');

