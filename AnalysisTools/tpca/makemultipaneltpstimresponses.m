function result = makemultipaneltpstimresponses(dirname, singleconditionfname, varargin)
% MAKEMULTIPANELTPSTIMRESPONSES - Make a multipanel image showing stimulus responses
% 
%  RESULT = MAKEMULTIPANELTPSTIMRESPONSES(DIRNAME, SINGLECONDITIONFNAME, ...)
% 
%      returns an image that is comprised of multiple single condition images of the
%  responses to different directions. The image has 1 rows and a number of columns that
%  corresponds to the number of stimuli used (including blanks, in order). 
% 
% This function also accepts name/value pairs that modify the default behavior:
% Parameter (default)           |   
% --------------------------------------------------------------------------
% channel (2)                   | The 2-photon channel that contains the responses
% gain (1)                      | Gain multiplier for single condition images
% savefile (1)                  | 0/1 Should we save the image to a file?
% filename ('sc_stim_GAIN.mat') | Filename to be saved. GAIN is output of 
%                               |    NUM2STR(gain)
% savetifffile (1)              | Should we save the file to TIFF format?
% tifffilename                  | Filename to be saved for TIFF format.
%       ('sc_stim_GAIN.tif')    | 
% input_range ([0 VALUE])       | The input range that is used to scale the TIFF file
%                               |    (by default, 0 to the VALUE calculated by the
%                               |    input_range_method is used, but a
%                               |    specific value can be used by passing [0 MYVALUE])
% input_range_method ('99.99%') | The algorithm that is used for calculating the
%                               |    upper end of the input_range. Options: 'NN%' (use
%                               |    NN% percentile), 'max' (use the maximum value).
% output_range ([0 255])        | The output range for the TIFF file.
% maskfile ([])                 | Should we apply a mask to the single condition images?
%   
% See also: MAKEMULTIPANELTPDIRRESPONSES, MAKEMULTIPANELNMTPDISPLAY, NAMEVALUEPAIR

channel = 2;
gain = 1;
savefile = 1;
filename = '';
savetifffile = 1;
tifffilename = '';
input_range = '';
input_range_method = '99.99%';
output_range = [0 255];
maskfile = '';

assign(varargin{:});

if isempty(filename),
	filename = ['sc_stim_' num2str(gain) '.mat'];
end;

if isempty(tifffilename),
	tifffilename = ['sc_stim_' num2str(gain) '.tif'];
end;

if isempty(maskfile),
	mask = 1;
else,
	z = load(maskfile);
	fn = fieldnames(z);
	mask = double(getfield(z,fn{1})); 
end;


 % step 1, decode the directions used

s = getstimscript(dirname);

N = numStims(s);

indexes = [ 1:N];

result = makemultipanelNMtpdisplay([dirname filesep singleconditionfname], 1, N, indexes, 0, gain, mask);

result = result{1};

if savefile,
	save([dirname filesep filename],'result','-mat');
end;

if savetifffile,
	if isempty(input_range),
		if strcmp(lower(input_range_method),'max') | strcmp(lower(input_range_method),'maximum'),
			input_range = [0 max(result(:))];
		elseif any(input_range_method=='%'),
			P = sscanf(input_range_method,'%f%');
			if isempty(P) | (P<0 | P>100),
				error(['Do not know how to process input_range_method of ' input_range_method '.']);
			end;
			input_range = [0 prctile(result(:),P)];
		end;
	end;
	newimage = rescale(double(result), input_range, output_range);
	imwrite(uint8(newimage), [dirname filesep tifffilename]);
end;


