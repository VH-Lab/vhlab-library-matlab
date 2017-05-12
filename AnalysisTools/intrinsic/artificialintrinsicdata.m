function artificialintrinsicdata(dirname, varargin)
% ARTIFICIALINTRINSICDATA - Generate artificial data to test intrinsic signal imaging analysis code
%
% ARTIFICIALINTRINSICDATA(DIRNAME, ...)
%
% Generates artificial intrinsic signal data that mimics the VH-Lab
% LabView. The signal generated is a noisy sinewave that changes phase
% by 2*pi/(number_of_stimuli) for each stimulus presentation. The signal
% is negative and is relative to a baseline (see parameter below).
%
% The function generates matlab files 'paramname.mat', 'stimvalues.mat', and
% 'stimorder.mat', as well as simulated frames for each stimulus. Each 
% stimulus presentation is indicated by a file "Trig_NNNNframe_MMMM.tiff',
% where NNNN indicates the presentation number and MMM is the stimulus frame
% number (both beginning with 0).
%
% This function can be altered by passing parameters as name/value pairs:
% Parameter (default)       | Description
% ------------------------------------------------------------------------
% N (100)                   | Number of rows of images
% M (50)                    | Number of columns
% noise (10)                | Standard deviation of gaussian noise
% NS (4)                    | Number of stimuli
% T (20)                    | Number of trials 
% F (2*5)                   | Number of data frames per stimulus 
%                           |  (2*2 mimics 2Hz sampling for 5 seconds)
% signal (2)                | Signal strength (*1/baseline dR/R)
% signal_sf (0.025)         | Signal spatial frequency (cycles/pixel)
% baseline (2000)           | Baseline image

N = 100;
M = 50;
noise = 10;
NS = 4;
T = 20;
F = 2*5;
signal = 2;
signal_sf = 0.025;
baseline = 2000;

assign(varargin{:});

img0 = baseline+(zeros(N,M));  % no need to have a large image here

[X,Y] = meshgrid(1:M,1:N);

stimorder = [];

for i=1:T,
	stimorder = [stimorder randperm(NS+1)];
end;

stimvalues = [0:180/NS:180-180/NS NaN];

paramname = 'angle';

save([fixpath(dirname) 'stimorder.mat'],'stimorder','-mat');
save([fixpath(dirname) 'stimvalues.mat'],'stimvalues','-mat');
save([fixpath(dirname) 'paramname.mat'],'paramname','-mat');

for i=1:length(stimorder),
	for f=1:F,
		img = img0+noise*rand(size(img0))+double((f~=1)&stimorder(i)~=9)*...
			-rectify(signal*sin(2*pi.*X*signal_sf+stimorder(i)*2*pi/NS));
		imwrite(uint16(img),['Trig_' sprintf('%0.4d',i-1) 'frame_' sprintf('%0.4d',f-1) '.tiff'],'tif');
	end;
end;

