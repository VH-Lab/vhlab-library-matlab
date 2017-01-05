function [lfpmean,csdmean,lfp,csd,totaldepth]=docsd(dirnames, depths, channels, normalize, chanmap, gains, chan0, int1, int2, comps)


 % assumes 100um spacing between channels
 % assumes channels numbered from lowest to highest
 % will need to be updated if we different steps (e.g., 25um)

%dirnames = {'2005-09-28/Depth1100Lum','2005-09-28/Depth1600Lum','2005-09-28/Depth2100Lum','2005-09-28/Depth2500Lum'};
%depths = [ 1100-400 1600-400 2100-400 2500-400 ];
%depths = [ 1100-400 1100-400+350 1600-400 2100-400];

%depthsneeded = [ (depths(1)-(length(channels)-2)*100):100:(depths(end)-1) ];
%totaldepth = depthsneeded;
%totallfpdepth = [ (depths(1)-(length(channels)-1)*100):100:(depths(end)) ];

depthsneeded = [];
depthsneededlf = [];
for i=1:length(depths),
	depthsneeded = [ depthsneeded (depths(i)-(length(channels)-2)*100):100:(depths(i)-100)];
	depthsneededlf = [ depthsneededlf (depths(i)-(length(channels)-1)*100):100:(depths(i))];
end;
totaldepth = unique(depthsneeded),
totallfpdepth = unique(depthsneededlf),

for i=1:length(dirnames),
	i,
	% need to edit here...make a "channelsneeded" list
	channelsneeded = unique([depthsneeded depthsneeded-100 depthsneeded+100]);
	channelstoinclude = [];
	depthsfound = []; depthinds = []; lfpinds = [];
	depthshere = depths(i):-100:(depths(i)-(length(channels)-1)*100);
	for j=1:length(depthshere),
		if any(depthshere(j)==depthsneeded),
			above = find(depthshere==depthshere(j)+100);
			below = find(depthshere==depthshere(j)-100);
			if ~isempty(above)&~isempty(below),
				depthsfound(end+1) = depthshere(j);
				depthinds(end+1) = find(depthshere(j)==totaldepth);
				depthsneeded = setdiff(depthsneeded,depthshere(j));
				channelstoinclude(end+1) = channels(j);
				channelstoinclude(end+1) = channels(above);
				channelstoinclude(end+1) = channels(below);
				lfpinds(end+1) = find(depthshere(j)==totallfpdepth);
				lfpinds(end+1) = find(depthshere(above)==totallfpdepth);
				lfpinds(end+1) = find(depthshere(below)==totallfpdepth);
			end;
		end;
	end;
	channelstoinclude = unique(channelstoinclude);
	lfpinds = unique(lfpinds); lfpinds = lfpinds(end:-1:1);
	depthshere,depthsneeded, depthinds, lfpinds,
	channelstoinclude,
	[lfpmean_,csdmean_,lfp_,csd_]=lfp_csd_comp(dirnames{i},channelstoinclude,chanmap,gains,chan0,normalize,int1,int2,comps);
	if 1,
	if i==1,
		lfpmean = zeros(size(lfpmean_,1),length(totaldepth),size(lfpmean_,3));
		csdmean = zeros(size(csdmean_,1),length(totaldepth)-2,size(lfpmean_,3));
		lfp = lfp_([]);
		csd = csd_([]);
	end;
	lfpmean(:,lfpinds,:) = lfpmean_;
	csdmean(:,depthinds,:) = csdmean_;
	lfp(1:size(lfp_,1),lfpinds) = lfp_;
	csd(1:size(csd_,1),depthinds) = csd_;
	end;
end;

