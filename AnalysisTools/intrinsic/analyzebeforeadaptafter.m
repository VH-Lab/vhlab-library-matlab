function analyzebeforeadaptafter(IM_before,IM_adapt,IM_after,roipts,bvm,xi)

if ~isempty(roipts),
	roipts = roipts.*(1-bvm);
end;

or_before = intrinorivectorsum(IM_before,xi,0,1);
or_adapt = intrinorivectorsum(IM_adapt,xi,0,1);
or_after = intrinorivectorsum(IM_after,xi,0,1);


grad = ot_map_gradient(or_before);
myhighgradmask = roipts&(grad>20);
mylowgradmask = roipts&(grad<=20);

plot_ot_map_compare(or_before,or_adapt,1-roipts, 1, 1);
plot_ot_map_compare(or_before,or_adapt,1-myhighgradmask, 0, 1);
plot_ot_map_compare(or_before,or_adapt,1-mylowgradmask, 0, 1);

if 0,
	[prpIbefore] = prpinds(IM_before,0,roipts);
	[prpIadapt] = prpinds(IM_adapt,0,roipts);
	[prpIafter] = prpinds(IM_after,0,roipts);

	bins = xi;
else,
	bins = 0:10:170;
	prpIbefore = contprpinds(rescale(mod(angle(or_before),2*pi),[0 2*pi],[0 pi])*180/pi,0:10:170,5,1-roipts+bvm,180);
	prpIadapt = contprpinds(rescale(mod(angle(or_adapt),2*pi),[0 2*pi],[0 pi])*180/pi,0:10:170,5,1-roipts+bvm,180);
	prpIafter = contprpinds(rescale(mod(angle(or_after),2*pi),[0 2*pi],[0 pi])*180/pi,0:10:170,5,1-roipts+bvm,180);
end;

prpr_before = prpresp(IM_before,prpIbefore);
prpr_adapt = prpresp(IM_adapt,prpIbefore);
prpr_after = prpresp(IM_after,prpIbefore);

if 0,  % plot global responses
prpr_beforeg = prpresp(IM_before,{find(roipts)});
prpr_adaptg = prpresp(IM_adapt,{find(roipts)});
prpr_afterg = prpresp(IM_after,{find(roipts)});

figure;
plot(xi,-prpr_beforeg{1}/max(-prpr_beforeg{1}),'k-');
hold on;
plot(xi,-prpr_adaptg{1}/max(-prpr_adaptg{1}),'g-');
plot(xi,-prpr_afterg{1}/max(-prpr_afterg{1}),'r-');
title(['Global responses (black before, green adapt, red recovery)']);
end;

colors = [0 0 0; 0 1 0; 1 0 0];
figure;
for i=1:3,
	if i==1, prpI = prpIbefore; elseif i==2, prpI = prpIadapt; elseif i==3, prpI = prpIafter; end;
	subplot(3,1,i);
	k = [];
	for j=1:length(prpI),
		k(end+1) = length(prpI{j});
	end;
	h=bar(bins,k);
	set(h,'facecolor',colors(i,:));
	A=axis;
	axis([bins(1) bins(end) A([3 4])]);
	if i==1, title(['Best stimulus pixel-by-pixel']); end;
	ylabel('Pixels');
	if i==3, xlabel(['Orientation (\circ)']); end;
end;

if 1,  % plot normalized to before
mn = Inf; mx = -Inf;
for i=1:1,
	if i==1,prpr=prpr_before; elseif i==2,prpr=prpr_adapt; elseif i==3, prpr=prpr_after; end;
	for j=1:length(prpr),
		mmn = min(-prpr{j}); mxx = max(-prpr{j});
		if mmn<mn, mn = mmn; end;
		if mxx>mx, mx = mxx; end;
	end;
end;

plotprps(xi,prpr_before,1,'k',[0 1],mx)
plotprps(xi,prpr_adapt,1,'g',[0 1],mx)
plotprps(xi,prpr_after,1,'r',[0 1],mx)
ch = get(gcf,'children');
axes(ch(end));
title(['PRP responses, normalized to before']);
end;  % plot normalized to before

for i=1:3,
	mn = Inf; mx = -Inf;
	if i==1,prpr=prpr_before; elseif i==2,prpr=prpr_adapt; elseif i==3, prpr=prpr_after; end;
	for j=1:length(prpr),
		mmn = min(-prpr{j}); mxx = max(-prpr{j});
		if mmn<mn, mn = mmn; end;
		if mxx>mx, mx = mxx; end;
	end;
	MN{i} = mn; MX{i} = mx;
end;

figure;
plotprps(xi,prpr_before,1,'k',[0 1],MX{1})
plotprps(xi,prpr_adapt,1,'g',[0 1],MX{2})
plotprps(xi,prpr_after,1,'r',[0 1],MX{3})
ch = get(gcf,'children');
axes(ch(end));
title(['PRP responses, normalized for each']);
%subplot(length(prpr_before),1,1);

if 1,
	compareprpinds(prpIbefore{2},prpIbefore{3},IM_before(:,:,1),1);
	title('Indices for BEFORE set 2 compared to BEFORE set 3');
	compareprpinds(prpIbefore{2},prpIadapt{2},IM_before(:,:,1),1);
	title('Indices for BEFORE set 2 compared to ADAPT set 2');
	compareprpinds(prpIbefore{5},prpIadapt{5},IM_before(:,:,1),1);
	title('Indices for BEFORE set 5 compared to ADAPT set 5');
end;
