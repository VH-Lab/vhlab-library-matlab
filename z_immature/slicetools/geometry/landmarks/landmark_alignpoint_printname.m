function str = landmark_alignpoint_printname(lm)

showstr = ''; if strcmp(lm.show,'0'), showstr = '*'; end;

str = [showstr lm.name ' | ' lm.type ' | ' num2str(lm.data.point1) ...
	',' lm.data.coordframe1name ',' num2str(lm.data.point2) ',' ...
	lm.data.coordframe2name ];


