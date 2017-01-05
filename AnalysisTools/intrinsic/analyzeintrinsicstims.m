function analyzeintrinsicstims(dirname,baselineframes,signalframes)
% ANALYZEINTRINSICSTIMS - Calculate deltaR/R for intrinsic imaging data
%
%  ANALYZEINTRINSICSTIMS(DIRNAME,BASELINEFRAMES,SIGNALFRAMES)
%
%  This function walks through the directory DIRNAME and
%  calculates deltaR/R = (signal_avg-baseline_avg)./baseline_avg
%  for each intrinsic imaging response that is found.
%  signal_avg is computed as the average response in the data frames that
%  are specified in the vector SIGNALFRAMES, and baseline_avg is
%  calculated as the average response in the data frames that are
%  specified as BSAELINEFRAMES.  Data frames are numbered from 1.
%
%  It is assumed that the intrinsic imaging responses are named:
%   Trig_NNNNframe_YYYY.extension, where NNNN is the trigger number
%   and YYYY is the data frame number, and extension is "tiff" or "lvdata".
%
%  The function loops through all such files and saves each dR/R image as
%  'stimNNNNImage.mat'; the image is saved in the variable 'img'.
%
%  If the stimNNNNImage.mat file already exists, the function looks to see
%  if the 'baselineframes' and 'signalframes' used in the computation were
%  the same; if so, nothing is done. Otherwise, the new result replaces the old.
%
%  Example: analyzeintrinsicstims(DIRNAME,1,[2 3]) will use the first frame
%     as the baseline frame and frames 2 and 3 as the signal frames.


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
		A = exist([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'Image.mat'])==2;
		if A,
			g = load([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'Image.mat'],...
				'baselineframes','signalframes');
			B = ~(eqlen(baselineframes,g.baselineframes)&eqlen(g.signalframes,signalframes));
		else, B = 1;
		end;
		if B,
			framedata = readintrinsicstim(dirname,n);
			baseline = nanmean(framedata(:,:,baselineframes),3);
			signal = nanmean(framedata(:,:,signalframes),3);
			img = (signal-baseline)./baseline;
			save([fixpath(dirname) 'stim' sprintf('%0.4d',n) 'Image.mat'],...
				'img','baselineframes','signalframes');
		end;
	end;
end;

