function [Popt, Ropt, err] = fitsinglegaussian2(R, x, wrap, widthseeds);

da = mean(diff(sort(x)));

R = double(R);
[maxresp,i] = max(R); maxang = x(i);
R = [R(:)' R(:)'];
x = [x x+180];

lb = [ min(R) 0 -1000 da/2 0]; % lower bounds
ub = [ max(R) 3*(maxresp-min(R)) 1000 180 3*(maxresp-min(R))]; % upper bounds
options=[];

Popt = []; err = Inf;

for w=1:length(widthseeds),
	ws = widthseeds(w);
	p0 = [min(R) maxresp maxang ws maxresp];
	[ret,popt,info]=levmar('doublegaussian180',p0,R,200,options,'bc',lb,ub,x,360);
	if info(2)<err, Popt = popt; err=info(2); end;
end;

Popt = fixparamsdg180(Popt,wrap*2);
Popt = Popt(1:4); Popt(3) = mod(Popt(3),wrap);
Ropt = singlegaussian(Popt,x(1:length(x)/2),wrap);
