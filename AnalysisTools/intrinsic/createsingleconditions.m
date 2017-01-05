function createsingleconditions(dirname, multiplier, meanfilteropts, medianfilteropts, baselineframes, signalframes)
% CREATESINGLECONDITIONS - Makes single condition images from intrinsic data
%
%  CREATESINGLECONDITIONS(DIRNAME,MULTIPLIER,MEANFILTEROPTS,MEDIANFILTEROPTS,...
%       BASELINEFRAMES,SIGNALFRAMES)
%
%  Creates single condition images from individual intrinsic signal responses.
%
%  Assumptions: Assumes that in the directory DIRNAME there are the following files:
%    stimorder.mat -- should have variable 'stimorder' that has the display order of stimuli
%    stimNNNNImage.mat -- should have variable 'img' that has the individual response 
%                         to each stimulus (numbered from 0)
%
%  Inputs: 
%         DIRNAME -- the directory name to examine
%         MULTIPLIER - Multiplier for saving TIFF image
%         MEANFILTEROPTS - The size of an optional mean filter
%         MEDIANFILTEROPTS - The size of an optional median filter
%         BASELINEFRAMES - the frames that should count as baseline
%         SIGNALFRAMES - the frames that should count as signal
%
%  Files that are written:
%         singleconditionZZZZ.mat -- the single condition file
%         singleconditionZZZZ.tif -- single condition in 16-bit tiff format  
%         singleconditionprogress.mat -- contains information on partial progress


so = load([fixpath(dirname) 'stimorder.mat']);
so = so.stimorder;

stims = unique(so);

sc = {};

progfilename = [fixpath(dirname) 'singleconditionprogress.mat'];

if exist(progfilename)==2,
	prog = load(progfilename,'-mat'),
	if ~isfield(prog,'baselineframes'),  % for backwards compatibility
		prog.baselineframes = [];
	end;
	if ~isfield(prog,'signalframes'),
		prog.signalframes = [];
	end;
else,
	for i=1:length(stims), prog.existence{i} = []; end;
	prog.meanfilteropts = meanfilteropts;
	prog.medianfilteropts = medianfilteropts;
	prog.multiplier = multiplier;
	prog.baselineframes = baselineframes;
	prog.signalframes = signalframes;
end;

for i=1:length(stims),
	existence = [];
	inds = find(so==stims(i))-1;
	% first check existence data to see if we need to update
	match_all_frames = 1;
	for j=1:length(inds),
		existence(j) = exist([fixpath(dirname) 'stim' sprintf('%0.4d',inds(j)) 'Image.mat']);
		if existence(j),
			g = load([fixpath(dirname) 'stim' sprintf('%0.4d',inds(j)) 'Image.mat'],'baselineframes','signalframes');
			match_all_frames = match_all_frames & ...
				 (eqlen(g.baselineframes,prog.baselineframes)&eqlen(g.signalframes,prog.signalframes));
		end;
	end;
	if ~eqlen(existence,prog.existence{i})|...
		~eqlen(medianfilteropts,prog.medianfilteropts)|...
		~eqlen(meanfilteropts,prog.meanfilteropts)|~match_all_frames,
		disp(['updating single condition ' int2str(i) '.']);
		stimdata = [];
		for j=1:length(inds),
			if existence(j)==2,
				g = load([fixpath(dirname) 'stim' sprintf('%0.4d',inds(j)) 'Image.mat']);
				%stimdata = cat(3,stimdata,g.img);
				if isempty(stimdata), stimdata = g.img./double(sum(existence>0));
				else, stimdata = stimdata + g.img./double(sum(existence>0));
				end;
			end;
		end;
		% compute mean image
		imgsc = nanmean(stimdata,3);
		% if any filter options are specified, then apply them
		if ~isempty(meanfilteropts),
			imgsc=imgsc-conv2(imgsc,ones(meanfilteropts)/sum(sum(ones(meanfilteropts))),'same');
		end;
		if ~isempty(medianfilteropts),
			imgsc=medfilt2(imgsc,medianfilteropts*[1 1]);
		end;
		save([fixpath(dirname) 'singlecondition' sprintf('%0.4d',stims(i)) '.mat'],'imgsc');
		imwrite(uint16( round(2^15+multiplier*imgsc)),...
			[fixpath(dirname) 'singlecondition' sprintf('%0.4d',stims(i)) '.tiff'],...
			'tif');,
		prog.existence{i} = existence;
	end;
end;

existence = prog.existence;
save(progfilename,'existence','medianfilteropts','meanfilteropts','multiplier');
