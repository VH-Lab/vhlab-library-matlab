function h = plot_oridir_indexes(indexes)
% PLOT_ORIDIR_FULL - Plot orientation or direction tuning curve of a cell
% 
%   PLOT_ORIDIR_INDEXES(indexes)
%
%  PLOT orientation/direction tuning curve and index values in current
%  axes
% 

hold off
h = errorbar(indexes.OTresponsecurve(1,:),indexes.OTresponsecurve(2,:)-indexes.blank_rate,indexes.OTresponsecurve(4,:),indexes.OTresponsecurve(4,:),'k','LineStyle','none');

hold on;
h2 = plot(indexes.OTfit(1,:),indexes.OTfit(2,:)-indexes.blank_rate,'k-');

A = axis;
axis([-22.5 360+22.5 A(3) A(4)]);

box off;

str = {['DI=' num2str(indexes.di)],['1-DI_CV=' num2str(1-indexes.dcv)],['1-CV=' num2str(1-indexes.cv)],['f1f0=' num2str(indexes.f1f0)]};
h3=autoplacetext(str);
set(h3,'interp','none');

h = cat(2,h,h2,h3);

return;

