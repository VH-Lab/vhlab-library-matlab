function [Popt, Ropt, err] = fitdoublegaussian180(R, angs);

da = mean(diff(sort(angs)));

[maxresp,i] = max(R); maxang = angs(i);
widthseeds = [da/2 da 40 60 90];

lb = [ min(R) 0 -1000 da/2 0]; % lower bounds
ub = [ max(R) 3*maxresp 1000 180 3*maxresp]; % upper bounds
options=[];


Popt = []; err = Inf;

for w=1:length(widthseeds),
	ws = widthseeds(w);
	p0 = [min(R) maxresp maxang ws maxresp];
	[ret,popt,info] = levmar('doublegaussian180',p0,R,200,options,'bc',lb,ub,angs,360);
	if info(2)<err, Popt = popt; err=info(2); end;
end;

Popt = fixparamsdg180(Popt,360);
Ropt = doublegaussian180(Popt,angs,360);
