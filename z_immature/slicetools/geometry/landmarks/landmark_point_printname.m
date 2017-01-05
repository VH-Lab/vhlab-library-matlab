function str = landmark_point_printname(lm)

showstr = '';
if strcmp(lm.show,'0'), showstr = '*'; end;

str = [showstr lm.name ' | ' lm.type ' | ' num2str(lm.data.point) ...
	' | ' lm.data.coordframename];


