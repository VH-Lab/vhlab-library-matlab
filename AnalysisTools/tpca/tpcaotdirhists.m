function b = tpcaothists(cells,cellnames)

w = []; cv = []; p = []; mr = []; indshere = []; di = []; dif = []; oi=[];

for i=1:length(cells),

	width = findassociate(cells{i},'OT Tuning width','','');
	circv = findassociate(cells{i},'OT Circular variance','','');
	otparams = findassociate(cells{i},'OT Carandini Fit Params','','');
	dirp= findassociate(cells{i},'OT Direction index','','');
	dirf= findassociate(cells{i},'OT Fit Direction index','','');
	oti= findassociate(cells{i},'OT Orientation index','','');
	otp   = findassociate(cells{i},'OT varies p','','');
	vp   = findassociate(cells{i},'OT visual response p','','');

	if ~isempty(width)&~isempty(circv)&~isempty(otp),
		if otp.data<0.05,
			w = [w width.data]; cv = [cv circv.data]; mr = [mr max(otparams.data([2 5]))];
			indshere = [indshere i]; di = [di dirp.data]; dif=[dif dirf.data];
			oi=[oi oti.data];
		end;
	end;
end;

figure;
N = 25;

subplot(1,3,1);
hist(oi,N);
xlabel('Orientation index');
ylabel('Counts');

subplot(1,3,3);
hist(mr,N);
xlabel('Fit peak response');

subplot(1,3,2);
hist(dif,N);
xlabel('Direction index');

b = [];

disp([int2str(length(find(dif>0.5))) ' of ' int2str(length(dif)) ' cells have DI>0.5']);
