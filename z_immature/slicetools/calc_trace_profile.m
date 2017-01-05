function [pos, meanvals, allvals] = calc_trace_profile(traces, condition, Vh, fieldname);

pos = []; meanvals = []; allvals = [];

for i=1:length(traces),
	if strcmp(traces(i).condition,condition)&abs(traces(i).Vh-Vh)<0.001,
		pos(end+1) = traces(i).position(2);
	end;
end;

if isempty(pos), return; end;

newpos = unique(pos);
maxnum = 0;
for i=1:length(newpos), 
	if length(find(newpos(i)==pos))>maxnum, maxnum = length(find(newpos(i)==pos)); end;
end;

allvals = NaN + ones(length(newpos), maxnum);

for i=1:length(traces),
	if strcmp(traces(i).condition,condition)&traces(i).Vh==Vh,
		ind = find(traces(i).position(2)==newpos);
		ind2 = find(isnan(allvals(ind,:)));
		allvals(ind,ind2(1)) = getfield(traces(i),fieldname);
	end;
end;

pos = newpos;
meanvals = nanmean(allvals,2);
