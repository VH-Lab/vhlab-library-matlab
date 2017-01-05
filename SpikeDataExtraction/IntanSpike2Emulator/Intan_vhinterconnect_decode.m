function out_all=Intan_vhinterconnect_decode(dirname)
% INTAN_VHINTERCONNECT_DECODE - Process VH lab interconnect data from the Intan board
%
%   INTAN_VHINTERCONNECT_DECODE(DIRNAME)
%
%   For directory with name DIRNAME (full path), processes the VH lab interconnect data and
%   writes the following files:
%
%   stimtimes.txt (see help stimtimes_txt)
%   stimontimes.txt (see documentation on website)
%   frametimes.txt (time of each video frame data change event)
%   verticalblanking.txt (time of each vertical blanking event)
%   twophotonframes.txt
%   
%   % need filetime.txt

 % 

if exist([dirname filesep 'Intan_decoding_finished.txt'],'file'),
	% we already did it, no need to repeat
	out_all = [];
	return;
end;

d = dir([dirname filesep '*.rhd']);

if length(d)>1,
	error(['Unsure which .rhd file to use; there are more than one in directory ' dirname '.']);
end;

fname = [dirname filesep d(1).name];

h = read_Intan_RHD2000_header(fname); % read header so we don't have to do it multiple times

[dummy,dummy,tot_time] = read_Intan_RHD2000_datafile(fname,h,'time',1,0,0.001);

slices = [0:200:tot_time-1 tot_time];

samp_interval = 1/h.frequency_parameters.amplifier_sample_rate;

stimtimes = [];
frametimes = [];
verticalblanking = [];

out_all = [];

for s=1:length(slices)-1,
		% read in the slice; read 1 sample early to allow transitions that started in last slice
	t=read_Intan_RHD2000_datafile(fname,h,'time',1,slices(s)-samp_interval,slices(s+1));
		% check for lack of file break, right now produce an error
	if any(diff(t)>samp_interval+1.1/double(intmax('int32'))), 
		keyboard;
		error(['Error encountered; samples are not adjacent; this can be fixed by Steve if reported. Save file as example']); 
	end;
	d=read_Intan_RHD2000_datafile(fname,h,'din',1,slices(s)-samp_interval,slices(s+1));
	out = vhinterconnect_decode(t,d);
	if isempty(out_all),
		out_all = out;
	else,
		out_all = catstructfields(out_all,out);
	end;
end;

write_interconnect_textfiles(dirname,out_all);
