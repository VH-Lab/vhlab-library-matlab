function h0 = plototresponse(cell,eb,fit)

% PLOTOTRESPONSE - Plots orientation responses for cell
%
%   H = PLOTOTRESPONSE(CELL,EB,FIT)
%
%  Plots orientation tuning curve for a cell on the curent axes.
%
%  If EB is 1, then standard error is shown.
%  If FIT is 1, then the fit is shown. Otherwise linear interpolation is
%  shown.

resp = findassociate(cell,'Best orientation resp','','');
resp = resp.data;

h = []; h2 =[];

h1 = plot(resp.curve(1,:),resp.curve(2,:),'ko');
hold on;
if fit==1,
	fitd=findassociate(cell,'OT Carandini 2-peak Fit','','');
	if isempty(fitd),
		fitd=findassociate(cell,'IT Carandini Fit','','');
	end;
	if ~isempty(fitd),
		h2 = plot(0:359,fitd.data,'k');
	end;
else,
	h2 = plot(resp.curve(1,:),resp.curve(2,:),'k');
end;

if eb==1,
	h=myerrorbar(resp.curve(1,:),resp.curve(2,:),...
			resp.curve(4,:),resp.curve(4,:));
	delete(h(2));
	set(h(1),'linewidth',1,'color',0*[1 1 1]);
	h = h(1);
end;

h0 = [h;h1;h2];

set(gca,'box','off');
A = axis;
axis([0 359 A(3) A(4)]);
