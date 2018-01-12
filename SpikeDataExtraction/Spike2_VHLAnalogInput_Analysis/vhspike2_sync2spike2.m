function [shift,scale] = vhspike2_sync2spike2(dirname, varargin)
% VHSPIKE2_SYNC2SPIKE2 - Compute shift between Intan and Spike2 records
%
%  [SHIFT,SCALE] = VHSPIKE2_SYNC2SPIKE2(DIRNAME)
%
%  Calculates the shift between the Multichannel LabView records that are stored
%  in DIRNAME in *.rhd files and the stimulus trigger records that are stored in
%  DIRNAME as stimtimes.txt.  DIRNAME should be provided as a full path.
%
%  IMPORTANT: By default, this function assumes that the stimulus triggers are
%  found in the first digital input channel in the *.rhd file.  If these triggers
%  are on a different channel, the file 'vhspike2_syncchannel.txt' should be created
%  in the directory. It should have a single line that has the channel number
%  of the vhspike2analoginput.vld file that has the stimulus triggers.
%  
%  The answer SHIFT and SCALE represents the answer to the following equation:
%
%     SPIKE2TIME = SHIFT + SCALE * INTAN_TIME
%
%  This is also written to the file 'vhspike2_intan2spike2time.txt' in DIRNAME.
%  (Shift first, then scale, as ascii text values.)
%
%  It is possible to supply additional arguments in the form of NAME/VALUE
%  pairs:
% 
%  FORCE_RERUN, default 0        :  If this is 1 then the analysis will re-run even
%                                :  if a spike2time2intantime.txt file exists.
%
%
%  See also: VHSPIKE2_INTAN2SPIKE2TIME

READSIZE = 10;  % read in N second steps
OVERLAP = 0.05;  % overlap each read by 0.1 seconds
VERBOSE = 0;
VERBOSE_GRAPHICAL = 1;
FORCE_RERUN = 0;

assign(varargin{:});

filename = 'vhspike2_intan2spike2time.txt';
syncfilename = 'vhspike2_syncchannel.txt';

if exist([dirname filesep filename])==2 & ~FORCE_RERUN,
	g = load([dirname filesep filename],'-ascii');
	shift = g(1);
	scale = g(2);
else,
	shift = 0;
	scale = 1;
	dlmwrite([dirname filesep filename],[shift scale],'delimiter',' ','precision',15);
end;


