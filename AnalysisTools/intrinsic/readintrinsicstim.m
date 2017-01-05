function framedata = readintrinsicsim(dirname,N, formatarg)
% READINTRINSICSTIM - Reads a multiframe intrinsic signal image data
%
%  FRAMEDATA = READINTRINSICSTIM(DIRNAME,N,[FORMAT])
%  
%  Reads intrinsic signal data. Files are assumed to be in the directory
%  DIRNAME and named Trig_NNNNframe_YYYY.extension
%  where NNNN is a 4 digit number corresponding to each stimulus number
%  starting with 0000, and YYYY is a 4 digit number corresponding to each
%  frame, starting with 0000.  "EXTENSION" is "lvdata" for Labview files, or
%  "TIFF" for tiff images.
%  The function attempts to read all available frames for stimulus number N. 
%  FRAMEDATA is a 3-dimensional matrix; FRAMEDATA(:,:,i) has image data for
%  frame i.
%
%  FORMAT is optional; by default, the function will try to read the 'lvdata'
%  format, but one can force the program to read tiffs by providing 'tiff'.
%  If the function attempts to read 'lvdata' files but finds none, it will try
%  to read 'TIFF' files.

 % assume labview format unless otherwise instructed

d = [];
if nargin>2,
	format = upper(formatarg);
else,	format = upper('lvdata'); % labview
	d = dir([dirname filesep 'Trig_' sprintf('%0.4d',N) 'frame_*.lvdata']);
end;

if length(d)==0&strcmp(format,'LVDATA'),
	warning(['No labview images found, now looking for TIFF images']);
	format = 'TIFF';
end;

if strcmp(format,'TIFF')|strcmp(format,'TIF'),
	d_tf = dir([dirname filesep 'Trig_' sprintf('%0.4d',N) 'frame_*.tiff']);
	d = d_tf;
	format = upper('tiff');
    warning('only reading tif files. bit depth is compromised.');
end; 

framedata = [];

if ~isempty(d),
	d = sort({d.name});
	for i=1:length(d),
	   try,
		switch(format),
			case 'LVDATA',
				img=readlabviewarray([dirname filesep d{i}],'double','b');
			case 'TIFF',
				img = imread([dirname filesep d{i}]);
		end; % switch
	   catch,
		error(['Error reading ' dirname ', ' d{i} '.']);
	   end;
	   framedata = cat(3,framedata,img);
	end;
end;


