function b = tpcaothists(cells,cellnames)

w = []; cv = []; p = []; mr = []; indshere = [];

for i=1:length(cells),

	width = findassociate(cells{i},'OT Tuning width','','');
	circv = findassociate(cells{i},'OT Circular variance','','');
	otparams = findassociate(cells{i},'OT Carandini Fit Params','','');
	otp   = findassociate(cells{i},'OT varies p','','');

	if ~isempty(width)&~isempty(circv)&~isempty(otp),
		if otp.data<0.05,
			w = [w width.data]; cv = [cv circv.data]; mr = [mr max(otparams.data([2 5]))];
			indshere = [indshere i];
		end;
	end;
end;

figure;
N = 25;

subplot(1,3,1);
hist(cv,N);
xlabel('Circular variance');
ylabel('Counts');

subplot(1,3,2);
hist(mr,N);
xlabel('Fit peak response');

subplot(1,3,3);
hist(w,N);
xlabel('Tuning width (deg)');

b = [];
