function [dr,t] = prairieviewdriftcheck(dirname, searchxy, howoften, avgframes, doplotit)

%  PRAIRIEVIEWDRIFTCHECK - Checks prairieview two-photon data for drift
%
%    [DR,T] = PRAIRIEVIEWDRIFTCHECK(DIRNAME, SEARCHXY, HOWOFTEN,...
%           AVGFRAMES, [PLOTIT])
%
%  Reports drift across a PrairieView time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified in SEARCHXY = [XPIXELS YPIXELS].
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each vector, and T is the time of the frame.
%
%  If PLOTIT is given and is 1, the results are plotted in a new figure.

if nargin<5, plotit = 0; else, plotit = doplotit; end;

tpdirname = [dirname '-001' ];

 % lets find parameter file

pcfile = dir([tpdirname filesep '*_Main.pcf']); pcfile = pcfile.name;
params = readprairieconfig([tpdirname filesep pcfile]);

tptimes = load([dirname filesep 'twophotontimes.txt'],'-ascii');

params.Image_TimeStamp__us_ = params.Image_TimeStamp__us_*1e-6; % change to seconds

if params.Main.Total_cycles>=1, % can we correct time?
   if params.Main.Total_cycles~=length(tptimes),
      error(['Number of twophoton times does not equal number of cycles ... don''t know what to do.']);
   end;
   if length(tptimes)>1,
      spike2machinterval = diff(tptimes(1:2));
      numFramesInFirstCycle = params.Cycle_1.Number_of_images;
      % assume first two frames will determine time ratio between machines
      tptimeinterval = diff(params.Image_TimeStamp__us_([1 numFramesInFirstCycle+1]));
      timeratio = spike2machinterval / tptimeinterval;
   else, timeratio = 1;
   end;
   tptime0 = tptimes(1);

   % now get file names
   fname = dir([tpdirname filesep '*Cycle001_Ch1_000001.tif']); fname = fname.name;
   fnameprefix = fname(1:strfind(fname,'Cycle')-1);
end;

frametimes = timeratio*(params.Image_TimeStamp__us_) + tptime0;
ffile = repmat([0 0],length(frametimes),1);
initind = 1;
for i=1:params.Main.Total_cycles,
        numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
        ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
        initind = initind + numFrames;
end;

dr = [0 0]; t = frametimes(1);
im0 = zeros(params.Main.Lines_per_frame,params.Main.Pixels_per_line);
for j=1:avgframes,
	im0(:,:,j)=...
  imread([tpdirname filesep fnameprefix 'Cycle' sprintf('%.3d',ffile(j,1)) '_Ch1_' sprintf('%.6d',ffile(j,2)) '.tif']);
end;

im0 = mean(im0,3);


for f=2:howoften:length(frametimes)-avgframes,
	disp(['Checking frame ' int2str(f) ' of ' int2str(length(frametimes)) '.']);
	t(end+1) = frametimes(f);
	im1 = zeros(params.Main.Lines_per_frame,params.Main.Pixels_per_line);
	for j=0:avgframes-1,
		im1(:,:,j+1)=imread([tpdirname filesep fnameprefix 'Cycle' sprintf('%.3d',ffile(f+j,1)) '_Ch1_' sprintf('%.6d',ffile(f+j,2)) '.tif']);
	end;
	im1 = mean(im1,3);
	dr(end+1,:) = driftcheck(im0,im1,searchxy);
end;

if plotit,
	figure;
	subplot(2,2,1);
	image(im0); colormap(gray(1000));
	title('First image');
	subplot(2,2,2);
	im2 = (im0 / 1000);
	im2(:,:,2) = im1/1000;
	im2(:,:,3) = im2(:,:,1);
	im2(:,:,1) = zeros(size(im0));
	im2(find(im2>1)) = 1;
	image(im2);
	title('blue=first image, green = last image');
	subplot(2,2,3);
	plot(t,dr(:,1));
	title('X drift'); ylabel('Pixels'); xlabel('Time (s)');
	subplot(2,2,4);
	plot(t,dr(:,2));
	title('Y drift'); ylabel('Pixels'); xlabel('Time (s)');
end;
