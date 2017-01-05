function [Popt, Ropt, err] = fitsinglegaussian(R, x, wrap, widthseeds, wrapseeds);

da = mean(diff(sort(x)));

[maxresp,i] = max(R); maxang = x(i);

lb = [ min(R) 0 -1000 da/2]; % lower bounds
ub = [ max(R) 3*maxresp 1000 180]; % upper bounds
options=[1E-03, 1E-15, 1E-15, 1E-20, 1];

Popt = []; err = Inf;

for w=1:length(widthseeds),
	for r = 1:length(wrapseeds),
		ws = widthseeds(w);
		p0 = [min(R) maxresp mod(maxang+wrapseeds(r),wrap) ws],
		[ret,popt,info] = levmar('singlegaussian',p0,R,500,options,x,360);
		if info(2)<err, Popt = popt; err=info(2); end;
	end;
end;

%Popt(3) = mod(Popt(3),wrap);
Ropt = singlegaussian(Popt,x,wrap);
