function plot_oridir_full(cell, cellname)
% PLOT_ORIDIR_FULL - Plot orientation or direction tuning curve of a cell
% 
%   PLOT_ORIDIR_FULL(CELL,CELLNAME)
%
%   

figure;

subplot(2,2,1);
plotf1f0OTcurve(cell,cellname,'xaxisend',360);
title('blue=F0,red=F1');
subplot(2,2,2);
%plotcycleavg(cell,cellname,'testname','CoarseDir test');

subplot(2,2,3);

[oi,di,depth,putativelayer,cv,f1f0,cellnamelist,ori_sig,inds] = readoridirtuningfromcells({cell},{cellname});
f1f0 = 2*rescale(f1f0,[0 1],[0 1]);
if f1f0<1,
	dv_cv = 1-cell2dircircular_variance(cell,'SP F0 Ach');
	di_ass = findassociate(cell,'SP F0 Ach OT Fit Direction index blr','','');
else,
	dv_cv = 1-cell2dircircular_variance(cell,'SP F1 Ach');
	di_ass = findassociate(cell,'SP F1 Ach OT Fit Direction index blr','','');
end;
cv = 1-cell2circular_variance(cell,'SP F0 Ach');
str = {['DI=' num2str(di_ass.data)],['1-DI_CV=' num2str(dv_cv)],['1-CV=' num2str(cv)],['f1f0=' num2str(f1f0)],['scalebar=10Hz']};
h=autoplacetext(str);
set(h,'interp','none');
