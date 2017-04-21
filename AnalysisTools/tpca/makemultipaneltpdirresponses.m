function result = makemultipaneltpdirresponses(dirname, singleconditionfname, varargin)
% MAKEMULTIPANELTPDIRRESPONSES - Make a multipanel image showing direction responses
% 
%  RESULT = MAKEMULTIPANELTPDIRRESPONSES(DIRNAME, SINGLECONDITIONFNAME, ...)
% 
%      returns an image that is comprised of multiple single condition images of the
%  responses to different directions. The image has 2 rows and a number of columns that
%  corresponds to the number of orientations tested. The top rows show the directions
%  from [0,180), and the bottom row shows directions [180, 360). 
% 
% This function also accepts name/value pairs that modify the default behavior:
% Parameter (default)           |   
% --------------------------------------------------------------------------
% channel (2)                   | The 2-photon channel that contains the responses
% gain (1)                      | Gain multiplier for single condition images
% savefile (1)                  | 0/1 Should we save the image to a file?
% filename ('sc_dir_GAIN.mat')  | Filename to be saved. GAIN is output of 
%                               |    NUM2STR(gain)
% savetifffile (1)              | Should we save the file to TIFF format?
% tifffilename                  | Filename to be saved for TIFF format.
%       ('sc_dir_GAIN.tif')     | 
% input_range ([0 MAX])         | The input range that is used to scale the TIFF file
%                               |   (by default, 0 to MAX image value is used, but a 
%                               |    specific value can be used by passing [0 VALUE])
% output_range ([0 255])        | The output range for the TIFF file.
% tolerance (1)                 | The tolerance to use when looking for angle+180 matches
%   
% See also: MAKEMULTIPANELNMTPDISPLAY, MAKEMULTIPANELTPSTIMRESPONSES, INTERVAL_NOTATION, NAMEVALUEPAIR

channel = 2;
gain = 1;
savefile = 1;
filename = '';
savetifffile = 1;
tifffilename = '';
input_range = '';
output_range = [0 255];
tolerance = 1;

assign(varargin{:});

if isempty(filename),
	filename = ['sc_dir_' num2str(gain) '.mat'];
end;

if isempty(tifffilename),
	tifffilename = ['sc_dir_' num2str(gain) '.tif'];
end;


 % step 1, decode the directions used

s = getstimscript(dirname);

N = numStims(s);

dirstimlist = [];

for n=1:N,
	stim = get(s,n);
	p = getparameters(stim);
	if isfield(p,'isblank'),
		isblank = p.isblank;
	else,
		isblank = 0;
	end;
	if isfield(p,'angle') & ~isblank,
		dirstimlist(n) = getfield(p,'angle');
	else,
		dirstimlist(n) = NaN;
	end;
end;

[dirstimlist_sorted, dirstimlist_sortedindexes] = sort(mod(dirstimlist,360));

lows = find(dirstimlist_sorted>=0 & dirstimlist_sorted<180);
highs = [];

for i=1:length(lows),
	[thehigh, value] = findclosest( dirstimlist_sorted, dirstimlist_sorted(lows(i)) + 180);
	if isempty(thehigh) | (abs(value - (dirstimlist_sorted(lows(i))+180)) > tolerance),
		error(['No match for direction: ' num2str(lows(i)+180) '; do not know what to do.']);
	else,
		highs(i) = thehigh;
	end;
end;


indexes = [ dirstimlist_sortedindexes(lows(:)) dirstimlist_sortedindexes(highs(:)) ];

result = makemultipanelNMtpdisplay([dirname filesep singleconditionfname], 2, numel(lows), indexes, 0, gain);

result = result{1};

if savefile,
	save([dirname filesep filename],'result','-mat');
end;

if savetifffile,
	if isempty(input_range),
		input_range = [0 max(result(:))];
	end;
	newimage = rescale(result, input_range, output_range);
	imwrite(uint8(newimage), [dirname filesep tifffilename]);
end;


