function newcoords = landmark_project_point(lms, pts, coordframe1, coordframe2)

newcoords = [];

%try,
	if strcmp(coordframe1,coordframe2),
		newcoords = pts;
	elseif ~isempty(lms.coordframestransforms),
		inds1 = find(strcmp(coordframe1,{lms.coordframestransforms.name1}));
		inds2 = find(strcmp(coordframe2,{lms.coordframestransforms.name2}));
		ind = intersect(inds1,inds2);
		if isempty(ind), newcoords = [];
		else, newcoords = repmat(lms.coordframestransforms(ind).C,size(pts,1),1)+(lms.coordframestransforms(ind).M*pts')';
		end;
	end;
%catch,
	%error(['No instructions to transform between ' coordframe1 ' and ' coordframe2 '.']);
%end;

