% Unconstrained minimization

% fitting the exponential model x_i=p(1)*exp(-p(2)*i)+p(3) of expfit.c to noisy measurements obtained with (5.0 0.1 1.0)
p0=[1.0, 0.0, 0.0];
x=[5.8728, 5.4948, 5.0081, 4.5929, 4.3574, 4.1198, 3.6843, 3.3642, 2.9742, 3.0237, 2.7002, 2.8781,...
   2.5144, 2.4432, 2.2894, 2.0938, 1.9265, 2.1271, 1.8387, 1.7791, 1.6686, 1.6232, 1.571, 1.6057,...
   1.3825, 1.5087, 1.3624, 1.4206, 1.2097, 1.3129, 1.131, 1.306, 1.2008, 1.3469, 1.1837, 1.2102,...
   0.96518, 1.2129, 1.2003, 1.0743];

options=[1E-03, 1E-15, 1E-15, 1E-20, 1E-06];
% arg demonstrates additional data passing to expfit/jacexpfit
arg=[40];

[ret, popt, info]=levmar('expfit', 'jacexpfit', p0, x, 200, options, arg);
disp('Exponential model fitting (see also ../expfit.c)');
popt


% Box constraints

% Hock-Schittkowski problem 01
p0=[-2.0, 1.0];
x=[0.0, 0.0];
lb=[-realmax, -1.5];
ub=[realmax, realmax];
options=[1E-03, 1E-15, 1E-15, 1E-20];

[ret, popt, info, covar]=levmar('hs01', 'jachs01', p0, x, 200, options, 'bc', lb, ub);
disp('Hock-Schittkowski problem 01');
popt


P = [5 10 179 30];
angs = 0:22.5:180-22.5;
R = singlegaussian(P,angs,180);
p0=[0 1 0 22.5];
lb=[-10 0 -1000 22.5/2];
ub=[10 100 1000 90];
options=[];
wrap = 180;

[ret, popt, info, covar]=levmar('singlegaussian', p0, R, 200, options, 'bc', lb, ub, angs, wrap);
disp('Gaussian fit');
popt

P = [5 10 70 30 5];
angs = 0:22.5:360-22.5;
R = doublegaussian180(P,angs,180);
p0=[5 10 65 22.5 10];
lb=[-10 0 -1000 22.5/2 0];
ub=[10 100 1000 90 100];
options=[];
wrap = 360;

[ret, popt, info, covar]=levmar('doublegaussian180', p0, R, 200, options, 'bc', lb, ub, angs, wrap);
disp('Double Gaussian fit');
popt

P = [ 5 1 357 30 1];
angs = 0:22.5:360-22.5;
R = doublegaussian180(P,angs,360);
[Popt,Ropt,err] = fitdoublegaussian180(R,angs);

P = [ 5 10 178 30];
angs = 0:22.5:180-22.5;
R = singlegaussian(P,angs,180);
R = randn(size(R))+0*R;
[Popt,Ropt,err] = fitsinglegaussian2(R,angs,180,[22.5/2 60]);
hold off; plot(angs,R); hold on; plot(angs,Ropt,'g');
