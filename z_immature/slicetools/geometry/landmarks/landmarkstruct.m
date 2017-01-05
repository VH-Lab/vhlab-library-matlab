function lms = landmarkstruct

lms.coordframeslist = struct('name','','cf','');
lms.coordframeslist = lms.coordframeslist([]);
	% name
	% cf
lms.coordframestransforms = struct('name1','','name2','','M',0,'c',0);
lms.coordframestransforms = lms.coordframestransforms([]);
	% name1
	% name2
	% M
	% c
lms.alignpointlist = [];
