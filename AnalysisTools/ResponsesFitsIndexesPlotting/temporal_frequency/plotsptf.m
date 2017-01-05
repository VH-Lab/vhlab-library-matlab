function plotsptf(cell,cellname)

plotgenerictuningcurve(cell,cellname,'SP F0 Ach TF Response curve','','',...
	'Temporal Frequency',1);

A = axis;

low = findassociate(cell,'SP F0 Ach TF Low SP','','');
high = findassociate(cell,'SP F0 Ach TF High SP','','');

if ~isempty(low),
	text(low.data,A(3),'low');
end;
if ~isempty(high),
	text(high.data,A(3),'high');
end;

%[low.data high.data],
axis(A);
