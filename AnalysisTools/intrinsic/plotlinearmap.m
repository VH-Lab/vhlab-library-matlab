function [or] = plotlinearmap(dirname,maptitle,mapparameter,plotpolar,plotsingleconditions)

%STILL NEEDS TESTING

sv = load([fixpath(dirname) 'stimvalues.mat']);
sv = sv.stimvalues;

images = [];

nonblankinds = [];

for i=1:length(sv),
	im = load([fixpath(dirname) 'singlecondition' sprintf('%0.4d',i) '.mat']);
	im = im.imgsc;
	images = cat(3,images,im);
	if ~isnan(sv(i)), nonblankinds(end+1) = i; end;
end;

myvals = rescale(sv(nonblankinds),[min(sv(nonblankinds)) max(sv(nonblankinds))],[0 135]);

wta = intrinsicwinnertakeall(-images(:,:,nonblankinds),0);

save([fixpath(dirname) 'wta_map_data.mat'],'wta');

if plotpolar,
	[impolar,immag,or_angs,or_mag] = intrinsicplotwinnertakeall(dirname);
end;

if plotsingleconditions,
	intrinsicplotsingleconditions(dirname,maptitle,mapparameter);
end;


