function TestCircularVarianceDS

ois = [];
dis = [];
mdis = [];
oi_theory = [];
di_theory = [];
cvs = [];
dcvs = [];
vecmags = [];
dvecmags = [];
 
 
for k=1:25
    k
    for i=1:20,
        output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',0,'sigma',20,'doplotting',0,'dofitting',1,'anglestep',22.5,'noise_level',0);
        oi_t=compute_orientationindex(0:359,output.FITCURVE);
        for j=1:5,  
            output = OriDirCurveDemo('Rp',10,'Rn',10-i/2,'Rsp',0,'sigma',20,'doplotting',0,'dofitting',0,'anglestep',22.5,'noise_level',5);
            oi_theory(i,j) = oi_t;
            di_theory(i,j) = oi_t;
            ois(i,j) = compute_orientationindex(output.measured_angles,output.orimn);
            cvs(i,j) = compute_circularvariance(output.measured_angles,output.orimn);
            dis(i,j) = compute_directionindex(output.measured_angles,output.orimn);
            dcvs(i,j) = compute_dircircularvariance(output.measured_angles,output.orimn);
            vecmags(i,j) = abs(compute_orientationvector(output.measured_angles,output.orimn))/max(output.orimn);
            dvecmags(i,j) = compute_dirvecmod(output.measured_angles, output.orimn);
        end;
    end;
    std_2(k,:) = std(dis,0,2)';
    std_3(k,:) = std(dvecmags,0,2)';
    std_4(k,:) = std(1-dcvs,0,2)';
end;
 
%
x = mean(di_theory,2)
std2 = mean(std_2,1)';
std3 = mean(std_3,1)';
std4 = mean(std_4,1)';
stderr2 = std(std_2,0,1)'/(sqrt(25))
stderr3 = std(std_3,0,1)'/(sqrt(25))
stderr4 = std(std_4,0,1)'/(sqrt(25))
 
 
 
figure;
hold on;
plot(x,std2,'bx-');
plot(x,std3,'cx-');
plot(x,std4,'mx-');
errorbar(x,std2,stderr2,'b-')
errorbar(x,std3,stderr3,'c-')
errorbar(x,std4,stderr4,'m-')
box off;
 
xlabel('Underlying orientation selectivity index value (theoretical OSI value)');
ylabel('Standard deviations w/ error bars; dis (blue), dvecmags (cyan), and 1-dcvs (magenta)');

