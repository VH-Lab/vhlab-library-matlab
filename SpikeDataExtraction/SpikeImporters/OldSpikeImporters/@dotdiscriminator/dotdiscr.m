function locs=dotdiscr(dd,d,dots)

% LOCS=DOTDISCR - Internal function for dotdiscriminator - does discrimination
%
% LOCS = DOTDISCR(DD,D,DOTS)
%


locs = dotdisc(d,dots);

p = getparameters(dd);

di = diff(locs);
ind = find(di>p.refractory_period);
while ~isempty(locs)&(length(ind)~=length(locs)-1),
		% runs <refrectory_period times
	di = diff(locs);
	ind = find(di>p.refractory_period);
	locs = locs([1 ind'+1]);
end;
	

