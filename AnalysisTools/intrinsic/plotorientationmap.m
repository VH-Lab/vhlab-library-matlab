function [or] = plotorientationmap(dirname,difference,plotpolar,plotsingleconditions)
% PLOTORIENTATIONMAP - Plot an oridentation map for intrinsic signal imaging data
%
%  OR = PLOTORIENTATIONMAP(DIRNAME, DIFFERENCE, PLOTPOLAR, PLOTSINGLECONDITIONS)
%
%   Plots an orientation map from intrinsic signal imaging data.
%
%   DIRNAME is the full path dirname that should have files called
%      [DIRNAME filesep 'singleconditionXXXX.mat'], where XXXX is the 
%      number of each stimulus.
%   DIFFERENCE is a 0/1 variable that indicates whether difference images
%      (90 degree differences in orientation) should be created and used when
%      plotting the maps.
%   PLOTPOLAR is 0/1 variable that indicates whether we should plot the polar
%      map.
%   PLOTSINGLECONDITIONS is a 0/1 variable that indicates whether we should plot
%      the single conditions.
%
% See also: INTRINORIVECTORSUM, INTRINSICPLOTSINGLECONDITIONS, INTRINSICPLOTORIENTATIONPOLAR
%


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


