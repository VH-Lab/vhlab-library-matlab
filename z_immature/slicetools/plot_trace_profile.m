function [hdp, hmeans, hborders] = plot_trace_profile(pos,meanvals,allvals,slice_landmarks,plotdatapoints,plotmeans,plotborders);


hdp = []; hmeans = []; hborders = [];
 % covert all units to real, SI

cellreal = (slice_landmarks.cell-slice_landmarks.origin)*slice_landmarks.scale.realunits/slice_landmarks.scale.imageunits;
cellreal = cellreal(2); % get y axis for profile

if plotdatapoints,
	hold on;
	for i=1:length(pos),
		vals = find(~isnan(allvals(i,:)));
		hdp = [hdp plot(allvals(i,vals),repmat(cellreal+pos(i),1,length(vals)),'k.')];
	end;
end;
	
if plotmeans,
	hmeans = plot(meanvals,cellreal+pos,'k-');
end;

if plotborders,
	for i=1:length(slice_landmarks.borders),
		if length(slice_landmarks.borders(i).locs)==2,
			bord_real = (slice_landmarks.borders(i).locs(2)-slice_landmarks.origin(2))*...
				slice_landmarks.scale.realunits/slice_landmarks.scale.imageunits;
		end;
		hborders = [hborders plot([-1000 1000],[bord_real bord_real],'k--')];
		text(0,bord_real,slice_landmarks.borders(i).name);
	end;
end;
