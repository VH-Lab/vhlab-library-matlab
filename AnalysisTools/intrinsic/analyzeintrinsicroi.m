function analyzeintrinsicroi(dirname)
% ANALYZEINTRINSICROI - Analyze brightness of region-of-interest in intrinsic image
%
%  This function walks through the directory DIRNAME and calculates the brightness
%  for each frame and each stimulus.
%  
%  It is assumed that the intrinsic imaging responses are named:
%   Trig_NNNNframe_YYYY.extension, where NNNN is the trigger number
%   and YYYY is the data frame number, and extension is "tiff" or "lvdata".
%
%  The brightness information for each stimulus will be stored as
%  'stimNNNNroibrightness.mat';
%
%

if exist([fixpath(dirname) 'IntrinsicROI.mat']),
	g=load([fixpath(dirname) 'IntrinsicROI.mat']);
	roi = g.roi;
else,
	roi = userintrinsicroi(dirname);
end;

d = dir([fixpath(dirname) 'Trig_*frame_0000.tiff']);
if length(d)==0,
        d = dir([fixpath(dirname) 'Trig_*frame_0000.lvdata']);
end;

pause(1); % give a little time for any in-progress writing operations to finish

if ~isempty(d),
        d = sort({d.name});
        for i=1:length(d),
                disp(['Working on ' d{i} '...']);,
                n = sscanf(d{i},'Trig_%dframe_0000.tiff');
                A = exist([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'roibrightness.mat'])==2;
                if A,
                        g = load([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'roibrightness.mat'],...
                                'roi');
                        B = ~(eqlen(roi,g.roi));
                else, B = 1;
                end;
                if B,
                        framedata = readintrinsicstim(dirname,n);
			brightness = [];
			for j=1:size(framedata,3),
				img = framedata(:,:,j);
				brightness(end+1) = nanmean(img(roi));
			end;
                        save([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'roibrightness.mat'],...
                                'roi','brightness');
                end;
        end;
end;

