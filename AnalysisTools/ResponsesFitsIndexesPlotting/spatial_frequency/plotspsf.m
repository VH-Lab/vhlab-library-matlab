function plotspsf(cell,cellname)

plotgenerictuningcurve(cell,cellname,'SP F0 Ach SF Response curve','','',...
	'Spatial Frequency',1);

A = axis;

low = findassociate(cell,'SP F0 Ach SF Low SP','','');
high = findassociate(cell,'SP F0 Ach SF High SP','','');

if ~isempty(low),
	text(low.data,A(3),'low');
end;
if ~isempty(high),
	text(high.data,A(3),'high');
end;

[low.data high.data],
axis(A);
