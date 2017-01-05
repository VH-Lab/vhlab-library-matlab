function [t_laser,duration_laser,baseline,tpeakPSE,peakPSE,totPSE] = analyze_caged_PSE(T,laser,celldata,window,baseline_window, maxormin)


 % find the laser pulse start time; goes from 0 to positive 50; use 10, 40 as thresholds
inds = find(laser(1:end-3)<10&laser(4:end)>40);
if isempty(inds), t_laser = 0.422; else, t_laser = T(inds(end)); end;
inds = find(laser(1:end-3)>40&laser(4:end)<10);
if isempty(inds), duration_laser = 0.010; else, duration_laser = T(inds(end)) - t_laser; end;

i0 = findclosest(T,t_laser+baseline_window(1));
i1 = findclosest(T,t_laser+baseline_window(2));

baseline = mean(celldata(i0:i1));

w0 = findclosest(T,t_laser + window(1));
w1 = findclosest(T,t_laser + window(2));

if maxormin,
	[peakPSE,peakPSEloc]  = max(celldata(w0:w1)-baseline);
else,   [peakPSE, peakPSEloc] = min(celldata(w0:w1)-baseline);
end;

wInd = w0:w1;

tpeakPSE = T(wInd(peakPSEloc));

totPSE = sum(celldata(w0:w1)-baseline)*(T(2)-T(1));
