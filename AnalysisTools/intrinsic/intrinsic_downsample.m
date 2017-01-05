function intrinsic_downsample(dirname_orig,dirname_new, varargin)
% INTRINSIC_DOWNSAMPLE - average over frames 
%
% INTRINSIC_DOWNSAMPLE(DIRNAME_ORIG, DIRNAME_NEW)
%
% Copies data from DIRNAME_ORIG into DIRNAME_NEW, while averaging
% multiple frames from DIRNAME_ORIG into single frames of DIRNAME_NEW.
% DIRNAME_ORIG and DIRNAME_NEW should be full paths or paths with respect
% to the current working directory.
%
% Example: If DIRNAME_ORIG has triggers with frames from 0 to 299, 
% and 'frames_to_average' is 15, then DIRNAME_NEW will have 20 frames
%
% This function also takes NAME/VALUE pairs that modify its behavior:
% Parameter (default):     | Description: 
% -------------------------------------------------------------------
% frames_to_average (15)   | Number of frames to average together
%  

frames_to_average = 15;

assign(varargin{:});

try, mkdir(dirname_new); end;

d = dir([dirname_orig filesep '*.*']);

d = dirlist_trimdots(d,1);

 % copy all non .lvdata and .tiff files
for i=1:length(d),
	[pathstr,name,ext] = fileparts(d(i).name);
	switch lower(ext),
		case {'.lvdata','.tiff','.stamp'},
			%disp(['Skipping file ' d(i).name ]);
		otherwise,
			disp(['Copying file ' d(i).name ]);
			copyfile([dirname_orig filesep d(i).name],[dirname_new filesep d(i).name]);
	end;
end;

d = dir([dirname_orig filesep 'Trig_*frame_0000.tiff']);
if length(d)==0,
	d = dir([dirname_orig filesep 'Trig_*frame_0000.lvdata']);
end;

if ~isempty(d),
	d = sort({d.name});
	for i=1:length(d),
		n=sscanf(d{i},'Trig_%dframe_0000.tiff');
		disp(['Working on trigger ' d{i}]);

		framedata = readintrinsicstim(dirname_orig,n);
		NewFrames = floor(size(framedata,3)/frames_to_average); % trim excess frames
		for j=1:NewFrames,
			framedata2 = mean(framedata(:,:,(j-1)*frames_to_average+(1:frames_to_average)),3);
			writelabviewarray([dirname_new filesep 'Trig_' sprintf('%0.4d',n) 'frame_' sprintf('%0.4d',j-1) '.lvdata'],...
				framedata2,'double','b');
		end;
	end;
end;

