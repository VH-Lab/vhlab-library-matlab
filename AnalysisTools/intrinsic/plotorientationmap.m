function [or] = plotorientationmap(dirname,difference,plotpolar,plotsingleconditions)

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

or = intrinorivectorsum(-images(:,:,nonblankinds),sv(nonblankinds),0,difference);

save([fixpath(dirname) 'orientation_map_data.mat'],'or');

if plotpolar,
	[impolar,immag,or_angs,or_mag] = intrinsicplotorientationpolar(dirname);
end;

if plotsingleconditions,
	intrinsicplotsingleconditions(dirname,'Orientation','angle');
end;


