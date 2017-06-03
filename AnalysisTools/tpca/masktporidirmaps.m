function masktporidirmaps(dirname, angle, varargin)
% MASKTPORIDIRMAPS - Read in orientation/direction maps and create masked versions
% 
%  MASKTPORIDIRMAPS(DIRNAME, ANGLE, ...)
% 
%  Creates a mask image with 0s where the orientation angle is greater than 45 degrees
%  from ANGLE.
%  
% This function also accepts name/value pairs that modify the default behavior:
% Parameter (default)              |   
% --------------------------------------------------------------------------
% savefile (1)                     | 0/1 Should we save the image and vectors to a file?
% filename ('sc_oridirmap.mat')    | Filename to be read with complex vector ori and dir map. 
% angletolerance (45)              | How close does the pixel orientation have to be?
% savefilename ('sc_orimask.mat')  | Filename to be saved
%   
% See also: MAKEMULTIPANELNMTPDISPLAY, MAKEMULTIPANELTPSTIMRESPONSES, INTERVAL_NOTATION, NAMEVALUEPAIR


savefile = 1;
filename = 'sc_oridirmap.mat';
angletolerance = 45;
savefilename = 'sc_orimask.mat';

assign(varargin{:});

ori_data = intrinsic_ori2dir(dirname, 'filename',filename);

ori_masked = (angdiffwrap(ori_data-angle,180)<angletolerance);

save([dirname filesep savefilename ],'ori_masked');


