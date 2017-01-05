function [dr] = prairieviewdriftcheck(dirname, channel, searchx, searchy, refdirname, refsearchx, refsearchy, howoften, avgframes, writeit, doplotit)

%  PRAIRIEVIEWDRIFTCHECK - Checks prairieview two-photon data for drift
%
%    [DR] = PRAIRIEVIEWDRIFTCHECK(DIRNAME,CHANNEL,SEARCHX, SEARCHY,
%       REFDIRNAME,REFSEARCHX, REFSEARCHY, ...
%	HOWOFTEN,AVGFRAMES, WRITEIT, PLOTIT)
%
%  Reports drift across a PrairieView time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.  SEARCHX and SEARCHY are vectors
%  containing offsets from 0 (no drift).  REFSEARCHX and
%  REFSEARCHY are the offsets to check during the initial
%  effort to find a match between frames acquired in different
%  directories.
%
%  DIRNAME is the directory in which to check for drift (omit the
%  '-001' in the name) relative to data at the beginning of data
%  in REFDIRNAME.  CHANNEL is the channel to be read.
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  If WRITEIT is 1, then a 'driftcorrect.mat' file is written to the
%  directory, detailing shifted frames.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each frame.
%
%  If PLOTIT is 1, the results are plotted in a new figure.

im0 = previewprairieview(refdirname,avgframes,1,channel);  % the first image

plotit = doplotit;

pathstr = fileparts(dirname);
 % figure out how many data directories we have
TPD = dir([dirname '-*']);
if isempty(TPD), error(['Cannot find any directories ' dirname '-001, -002, etc.']); end;
tpdirnames = sort({TPD.name});  % in a minute, we'll append the pathstr

for k=1:length(tpdirnames),

	tpdirname = [pathstr filesep tpdirnames{k}],

	 % lets find parameter file

	pcfile = dir([tpdirname filesep '*_Main.pcf']);
	if isempty(pcfile), pcfile = dir([tpdirname filesep '*.xml']); end;
	pcfile = pcfile(end).name;
	params = readprairieconfig([tpdirname filesep pcfile]);

	% now get file names
	fname = dir([tpdirname filesep '*Cycle001_Ch' int2str(channel) '_000001.tif']); fname = fname.name;
	fnameprefix = fname(1:strfind(fname,'Cycle')-1);

	ffile = repmat([0 0],length(params.Image_TimeStamp__us_),1);
	initind = 1;
	for i=1:params.Main.Total_cycles,
		numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
		ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
		initind = initind + numFrames;
	end;


	params.Image_TimeStamp__us_ = params.Image_TimeStamp__us_*1e-6; % change to seconds

	dr = []; t = [];
	drlast = [0 0];

	refisdifferent = 0;

	if strcmp(dirname,refdirname), % this is base directory
		xrange = searchx; yrange = searchy;
	else, xrange = refsearchx; yrange = refsearchy; refisdifferent = 1;
	end;

	for f=1:howoften:length(params.Image_TimeStamp__us_)-avgframes,
		fprintf(['Checking frame ' int2str(f) ' of ' int2str(length(params.Image_TimeStamp__us_)) '.\n']);
		t(end+1) = 1;
		im1 = zeros(params.Main.Lines_per_frame,params.Main.Pixels_per_line);
		for j=0:avgframes-1,
			im1(:,:,j+1)=imread([tpdirname filesep fnameprefix 'Cycle' sprintf('%.3d',ffile(f+j,1)) '_Ch' int2str(channel) '_' sprintf('%.6d',ffile(f+j,2)) '.tif']);
		end;
		im1 = mean(im1,3);
		dr(length(t),[1 2]) = driftcheck(im0,im1,drlast(1,1)+xrange,drlast(1,2)+yrange,1);
		if refisdifferent,
			% refine search of first frame
			dr(length(t),[1 2]) = driftcheck(im0,im1,dr(length(t),1)+searchx,dr(length(t),2)+searchy,1);
            %dr(length(t),[1 2]) = [-32 -19];
			refisdifferent = 0;
		end;
		drlast = dr(length(t),[1 2]);
		disp(['Shift is ' int2str(dr(end,:))]);
		disp(['Searching ' int2str(dr(end,1)+xrange) ' in x.']);
		disp(['Searching ' int2str(dr(end,2)+yrange) ' in y.']);
		xrange = searchx; yrange = searchy;
	end;

	if writeit,
		newframeind = 1:length(params.Image_TimeStamp__us_);
		frameind = 1:howoften:length(params.Image_TimeStamp__us_)-avgframes;
		drift=round([interp1(1:howoften:length(params.Image_TimeStamp__us_)-avgframes,dr(:,1),newframeind,'linear','extrap')' ...
				interp1(1:howoften:length(params.Image_TimeStamp__us_)-avgframes,dr(:,2),newframeind,'linear','extrap')';]);
		save([tpdirname filesep 'driftcorrect'],'drift','-mat');
	end;

	if plotit,
		figure;
		subplot(2,2,1);
		image(rescale(im0,[min(min(im0)) max(max(im0))],[0 255])); colormap(gray(256));
		title('First image');
		subplot(2,2,2);
		im2 = (im0 / max(max(im0)));
		im2(:,:,2) = im1/max(max(im0));
		im2(:,:,3) = im2(:,:,1);
		im2(:,:,1) = zeros(size(im0));
		im2(find(im2>1)) = 1;
		image(im2);
		title('blue=first image, green = last image');
		subplot(2,2,3);
		plot(dr(:,1));
		title('X drift'); ylabel('Pixels'); xlabel('Frame #');
		subplot(2,2,4);
		plot(dr(:,2));
		title('Y drift'); ylabel('Pixels'); xlabel('Frame #');
	end;

end;
