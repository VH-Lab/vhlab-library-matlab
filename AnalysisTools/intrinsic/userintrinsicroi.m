function roi = userintrinsicroi(dirname)
% USERINTRINSICROI - Ask the user to draw an ROI for analysis for intrinsic imaging
%
%    ROI = USERINTRINSICROI(DIRNAME)
%
%  This function looks at the directory DIRNAME, pulls up the first acquired
%  set of intrinsic imaginges (assumed it is named Trig_0000frame_YYYY.extension)
%  and asks the user to draw a region of interest for further calculation.
%
%  The pixel index values that correspond to the ROI are saved in the file
%  'IntrinsicROI.mat' with the variable name 'roi'.  The index values are also
%  returned in the output argument roi.  
%

framedata = readintrinsicstim(dirname,0);

fig = figure;
imagesc(framedata(:,:,1));
colormap(gray);
str = 'Please click a region of interest with the mouse, double-click to finish';
questdlg(str,'Select ROI','OK','OK');
BW = roipoly;
roi = find(BW);
save([fixpath(dirname) 'IntrinsicROI.mat']);
close(fig);
