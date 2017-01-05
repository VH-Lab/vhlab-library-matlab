function [shift,scale] = vhlv_sync2spike2(dirname, varargin)
% VHLV_SYNC2SPIKE2 - Compute shift between Labview and Spike2 records
%
%  [SHIFT,SCALE] = VHLV_SYNC2SPIKE2(DIRNAME)
%
%  Calculates the shift between the Multichannel LabView records that are stored
%  in DIRNAME in vhlvanaloginput.vld and the stimulus trigger records that are stored in
%  DIRNAME as stimtimes.txt.  DIRNAME should be provided as a full path.
%
%  IMPORTANT: By default, this function assumes that the stimulus triggers are
%  found in the last analog channel in vhlvanaloginput.vld.  If these triggers
%  are on a different channel, the file 'vhlv_syncchannel.txt' should be created
%  in the directory. It should have a single line that has the channel number
%  of the vhlvanaloginput.vld file that has the stimulus triggers.
%  
%  The answer SHIFT and SCALE represents the answer to the following equation:
%
%     SPIKE2TIME = SHIFT + SCALE * LABVIEW_TIME
%
%  This is also written to the file spike2time2labviewtime.txt in DIRNAME.
%  (Shift first, then scale, as ascii text values.)
%
%  It is possible to supply additional arguments in the form of NAME/VALUE
%  pairs:
% 
%  FORCE_RERUN, default 0        :  If this is 1 then the analysis will re-run even
%                                :  if a spike2time2labviewtime.txt file exists.
%

READSIZE = 10;  % read in N second steps
OVERLAP = 0.05;  % overlap each read by 0.1 seconds
VERBOSE = 0;
VERBOSE_GRAPHICAL = 1;
FORCE_RERUN = 0;

filename = 'vhlv_lv2spike2time.txt';
syncfilename = 'vhlv_syncchannel.txt';

if exist([dirname filesep filename])==2 & ~FORCE_RERUN,
	g = load([dirname filesep filename],'-ascii');
	shift = g(1);
	scale = g(2);
	return;
end;

header_filename = [dirname filesep 'vhlvanaloginput.vlh'];
data_filename =   [dirname filesep 'vhlvanaloginput.vld'];

stimtimes_filename = [dirname filesep 'stimtimes.txt'];
  % read in stim codes and stim times
spike2_stimtimes = [];
stimids = [];

fid = fopen(stimtimes_filename,'rt');
if fid<1, error(['Could not open file ' stimtimes_filename '.']); end;
while ~feof(fid),
	stimline = fgets(fid);
	if ~isempty(stimline)&(~eqlen(-1,stimline)),
		stimdata = sscanf(stimline,'%f');
		if ~isempty(stimdata),
			stimids(end+1) = stimdata(1);
			spike2_stimtimes(end+1) = stimdata(2);
		end;
	end;
end;
fclose(fid);

header = readvhlvheaderfile(header_filename);

threshold = [ 2.5 -1 0 ; 4 1 -10 ; 1 -1 10 ];

header = readvhlvheaderfile(header_filename);


if exist([dirname filesep syncfilename])==2,
	synchchannel = load([dirname filesep syncfilename],'-ascii');
else,
	synchchannel = header.NumChans;
end;


lv_stimtimes = [];
start_time =0;
hasprogbar = 0;
tot_time = 1000; % make something up so it doesn't crash

if VERBOSE_GRAPHICAL,
	zzzz=which('progressbar');
	if ~isempty(zzzz),
		hasprogbar = 1;
	end;
	if hasprogbar,
		progressbar(['Extracting stim times now']);
	end;
end;

end_of_file_reached = 0;

while (~end_of_file_reached),
	if VERBOSE,
		start_time,  % display the progress
	end;
	if VERBOSE_GRAPHICAL&hasprogbar,
		progressbar(start_time/tot_time);
	end;
	end_time = start_time + READSIZE;
	% read the data
	[T,D,tot_sam,tot_time] = readvhlvdatafile(data_filename,header,synchchannel,start_time,end_time);
	D = single(D);

	if abs(length(T) - ((end_time - start_time) * header.SamplingRate + 1))>0.1,
                        end_of_file_reached = 1;
	end;

	locs = find(D(1:end-1)>=2.5&D(2:end)<2.5);
	locs = refractory(locs,10); % debounce
	locs = locs(find(locs>10&locs+10<length(D)));
	lv_stimtimes = [lv_stimtimes; T(locs(:))'];

	start_time = start_time + READSIZE - OVERLAP;
end;

if VERBOSE_GRAPHICAL&hasprogbar,
	progressbar(1);
end;

lv_stimtimes = unique(lv_stimtimes);

if length(lv_stimtimes)==1,
	if length(spike2_stimtimes)~=1,
    		error(['Unable to find the shift from spike2_stimtimes and lv_stimtimes. The usual cause is that Spike2 has acquired too many triggers(' int2str(length(spike2_stimtimes)) '), or labview has not acquired the proper number of triggers (' int2str(length(lv_stimtimes)) '). Please edit the file stimtimes.txt in the directory ' dirname '.']);
	end;
	scale = 1;
	shift = spike2_stimtimes - lv_stimtimes;
else, % we have at least 2 points

	warnstate = warning('query');
	warning off;
	try,
	    P = polyfit(lv_stimtimes(:),spike2_stimtimes(:),1);
	catch,
	    error(['Unable to fit a line to spike2_stimtimes and lv_stimtimes. The usual cause is that Spike2 has acquired too many triggers(' int2str(length(spike2_stimtimes)) '), or labview has not acquired the proper number of triggers (' int2str(length(lv_stimtimes)) '). Please edit the file stimtimes.txt in the directory ' dirname '.']);
	end;
	warning(warnstate);
	
	shift = P(2);
	scale = P(1);
end;

dlmwrite([dirname filesep filename],[shift scale],'delimiter',' ','precision',15);

