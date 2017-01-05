function [xyz]=tpgetcellposition(mycell)

% TPGETCELLPOSITION - Get X, Y, Z location of two-photon cell
%
%  [XYZ]= TPGETCELLPOSITION(MYCELL)
%
%  Given a MEASUREDDATA object that has been prepared by
%  ANALYZETPSTACK, this function will return the X, Y, and Z
%  position of the cell in the stack space.  The cell's position
%  will be corrected for any XY offset of the data slice it originated
%  from.

pixellocs = findassociate(mycell,'pixellocs','','');
depth = findassociate(mycell,'depth','','');
if ~isempty(depth),
	if ischar(depth.data),
		depth.data = str2num(depth.data);
	end;
end;
xyoffset = findassociate(mycell,'xyoffset','','');

if isempty(xyoffset), xyo = [0 0]; else, xyo = xyoffset.data; end;

if ~isempty(pixellocs)&~isempty(depth),
	xyz = [mean(pixellocs.data.x)-xyo(1) mean(pixellocs.data.y)-xyo(2) depth.data];
else, error(['Cell does not have recorded pixellocs, depth, or both.']);
end;