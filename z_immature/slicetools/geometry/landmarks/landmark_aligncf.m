function lms = landmark_aligncf(oldlms, landmarklist)

lms = oldlms;

inds = find(strcmp('alignpoint',{landmarklist.type}));

if ~eqlen(landmarklist(inds), lms.alignpointlist),
	disp('Re-aligning coordinate systems...please wait...');
	lms.alignpointlist = landmarklist(inds);
	lms.coordframestransforms = [];

	for i=1:length(lms.coordframeslist),
		for j=1:length(lms.coordframeslist),
			if i~=j,
				newconv.name1 = lms.coordframeslist(i).name;
				newconv.name2 = lms.coordframeslist(j).name;
				[newconv.M,newconv.C]=coordframe_conversion_matrix(newconv.name1, newconv.name2,...
					lms.alignpointlist);
				if ~isempty(newconv.M),
					if length(lms.coordframestransforms)==0,
						lms.coordframestransforms = newconv;
					else,
						lms.coordframestransforms(end+1) = newconv;
					end;
				end;
			end;
		end;
	end;
end;


