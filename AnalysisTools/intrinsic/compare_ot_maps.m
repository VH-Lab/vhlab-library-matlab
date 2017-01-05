function [mapangdiff,angs1,angs2] = compare_ot_maps(map1,map2)
 
  % maps must be OT maps

angs1 = rescale(mod(angle(map1),2*pi),[0 2*pi],[0 pi])*180/pi;
angs2 = rescale(mod(angle(map2),2*pi),[0 2*pi],[0 pi])*180/pi;

mapangdiff = angdiffwrapsign(angs2 - angs1,180);
