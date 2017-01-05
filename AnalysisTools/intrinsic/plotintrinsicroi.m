function plotintrinsicroi(dirname)
% PLOTINTRINSICROI - Plot brightness over time of an intrinsic region of interest
%
%   Plots the brightness of the user-selected ROI as a function of frame number.
%   There is a gap of 10 units between successive stimuli.
%
%   See also: USERINTRINSICROI, ANALYZEINTRINSICROI


so = load([fixpath(dirname) 'stimorder.mat']);
so = so.stimorder;

brightness = [];
framenumber = [];
frame_offset = 0;
prev_frame = 0;

stimids = unique(so);

stims_bright = {};
stims_dRoR = {};

for i=1:length(stimids),
	stims_bright{i} = [];
	stims_dRoR{i} = [];
end;

dRoR = [];

for i=1:length(so),
	g = load([fixpath(dirname) 'stim' sprintf('%0.4d',i-1) 'roibrightness.mat']);
	stimind = find(stimids==so(i));
	stims_bright{stimind} = [stims_bright{stimind}; g.brightness];
	stims_dRoR{stimind} = [stims_dRoR{stimind}; (g.brightness-g.brightness(1))/g.brightness(1)];

	framenumber = [framenumber prev_frame+frame_offset+(1:length(g.brightness))];
	brightness = [brightness g.brightness];
	dRoR = [dRoR (g.brightness-g.brightness(1))/g.brightness(1)];
	frame_offset = frame_offset + 2;
	prev_frame = framenumber(end);
end;

[path,name] = fileparts(dirname);

figure;
plot(framenumber,brightness,'ko');
xlabel('Frame number');
ylabel('Mean brightness in ROI');
title(['Brightness vs. time for ' name '; stims separated by 10 units.']);
A = axis;
axis([A(1) A(2) 0 A(4)]);

figure;
plot(framenumber,dRoR,'ko');
xlabel('Frame number');
ylabel('dR/R');
title(['dR/R vs. time for ' name '; stims separated by 10 units.']);

for i=1:length(stimids),
	figure;
	mn_bright = mean(stims_bright{i});
	stderr_bright = stderr(stims_bright{i});
	myerrorbar(1:length(mn_bright),mn_bright,stderr_bright,stderr_bright,'ko');
	xlabel('Frames');
	ylabel(['brightness stim ' int2str(i) '.']);

	figure;
	mn_dRoR = mean(stims_dRoR{i});
	stderr_dRoR = stderr(stims_dRoR{i});
	myerrorbar(1:length(mn_bright),mn_dRoR,stderr_dRoR,stderr_dRoR,'ko');
	xlabel('Frames');
	ylabel(['dRoR stim ' int2str(i) '.']);
end;
