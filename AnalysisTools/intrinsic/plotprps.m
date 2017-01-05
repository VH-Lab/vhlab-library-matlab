function plotprps(xi,prp,holdon,str,minmax,scale)

for i=1:length(prp),
	subplot(ceil(length(prp)/3),3,i);
	if holdon, hold on; else, hold off; end;
	plot(xi,-prp{i}/scale,str);
	axis([min(xi) max(xi) min(minmax) max(minmax)]);
	title([i]);
end;
