function [shift,scale] = vhintan_sync2spike2(dirname, varargin)
% VHINTAN_SYNC2SPIKE2 - Compute shift between Intan and Spike2 records
%
%  [SHIFT,SCALE] = VHINTAN_SYNC2SPIKE2(DIRNAME)
%
%  Calculates the shift between the Multichannel LabView records that are stored
%  in DIRNAME in *.rhd files and the stimulus trigger records that are stored in
%  DIRNAME as stimtimes.txt.  DIRNAME should be provided as a full path.
%
%  IMPORTANT: By default, this function assumes that the stimulus triggers are
%  found in the first digital input channel in the *.rhd file.  If these triggers
%  are on a different channel, the file 'vhintan_syncchannel.txt' should be created
%  in the directory. It should have a single line that has the channel number
%  of the vhintananaloginput.vld file that has the stimulus triggers.
%  
%  The answer SHIFT and SCALE represents the answer to the following equation:
%
%     SPIKE2TIME = SHIFT + SCALE * INTAN_TIME
%
%  This is also written to the file 'vhintan_intan2spike2time.txt' in DIRNAME.
%  (Shift first, then scale, as ascii text values.)
%
%  It is possible to supply additional arguments in the form of NAME/VALUE
%  pairs:
% 
%  FORCE_RERUN, default 0        :  If this is 1 then the analysis will re-run even
%                                :  if a spike2time2intantime.txt file exists.
%
%
%  See also: VHINTAN_INTAN2SPIKE2TIME

READSIZE = 100;  % read in N second steps
OVERLAP = 0.05;  % overlap each read by 0.1 seconds
VERBOSE = 0;
VERBOSE_GRAPHICAL = 1;
FORCE_RERUN = 0;
PLOTIT = 0;

assign(varargin{:});

filename = 'vhintan_intan2spike2time.txt';
syncfilename = 'vhintan_syncchannel.txt';
ignorefilename = 'vhintan_intanignoretriggers.txt';

if exist([dirname filesep filename])==2 & ~FORCE_RERUN,
	g = load([dirname filesep filename],'-ascii');
	shift = g(1);
	scale = g(2);
	return;
end;

header_filename = vhintan_getdirfilename(dirname); 
data_filename =   header_filename; 

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


threshold = [ 2.5 -1 0 ; 4 1 -10 ; 1 -1 10 ];

header = read_Intan_RHD2000_header(header_filename);

if exist([dirname filesep syncfilename])==2,
	synchchannel = load([dirname filesep syncfilename],'-ascii');
else,
	synchchannel = 1;
end;

if vlt.file.isfile([dirname filesep ignorefilename]),
	ignoretriggers = load([dirname filesep ignorefilename],'-ascii');
else,
	ignoretriggers = [];
end;


intan_stimtimes = [];
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

t0 = read_Intan_RHD2000_datafile(data_filename,header,'time',1,0,0);

while (~end_of_file_reached),
	if VERBOSE,
		start_time,  % display the progress
	end;
	if VERBOSE_GRAPHICAL&hasprogbar,
		progressbar(start_time/tot_time);
	end;
	end_time = start_time + READSIZE;
	% read the data
	[D,tot_sam,tot_time] = read_Intan_RHD2000_datafile(data_filename,header,'din',1,start_time,end_time);
	[T,tot_sam,tot_time] = read_Intan_RHD2000_datafile(data_filename,header,'time',1,start_time,end_time);
	
	D = bitget(D,synchchannel);

	if abs(numel(D) - ((end_time - start_time) * header.frequency_parameters.amplifier_sample_rate + 1))>2,
		%start_time,tot_time,
		%disp(['declaring end of file reached.']);
		end_of_file_reached = 1;
	end;

	locs = find(D(1:end-1)>=1&D(2:end)<1);
	locs = refractory(locs,10); % debounce
	locs = locs(find(locs>10&locs+10<length(D)));
	intan_stimtimes = [intan_stimtimes; -t0+T(locs(:))];

	start_time = start_time + READSIZE - OVERLAP;
end;

if VERBOSE_GRAPHICAL&hasprogbar,
	progressbar(1);
end;

intan_stimtimes = unique(intan_stimtimes);

ignoretriggers,
intan_dontignore = setdiff(1:numel(intan_stimtimes),ignoretriggers);

intan_stimtimes = intan_stimtimes(intan_dontignore);


if length(intan_stimtimes)==1,
	if length(spike2_stimtimes)~=1,
    		error(['Unable to find the shift from spike2_stimtimes and intan_stimtimes. The usual cause is that Spike2 has acquired too many triggers(' int2str(length(spike2_stimtimes)) '), or Intan has not acquired the proper number of triggers (' int2str(length(intan_stimtimes)) '). Please edit the file stimtimes.txt in the directory ' dirname '.']);
	end;
	scale = 1;
	shift = spike2_stimtimes - intan_stimtimes;
else, % we have at least 2 points

	warnstate = warning('query');
	warning off;
	try,
	    P = polyfit(intan_stimtimes(1:end),spike2_stimtimes(:),1);
	catch,
	    error(['Unable to fit a line to spike2_stimtimes and intan_stimtimes. The usual cause is that Spike2 has acquired too many triggers(' int2str(length(spike2_stimtimes)) '), or Intan has not acquired the proper number of triggers (' int2str(length(intan_stimtimes)) '). Please edit the file stimtimes.txt in the directory ' dirname '.']);
	end;
	warning(warnstate);

	shift = P(2);
	scale = P(1);

	if PLOTIT,
		figure;
		plot(intan_stimtimes(:),spike2_stimtimes(:),'o');
		hold on;
		plot(intan_stimtimes(:),intan_stimtimes(:)*scale+shift,'-','linewidth',1);
		xlabel('Intan times');
		ylabel('Spike2 times');
	end;


end;

dlmwrite([dirname filesep filename],[shift scale],'delimiter',' ','precision',15);


