function [spikeshapes] = read_spike2_spikeshapes(spike2filename, spikechannel, times, samples)
%  SPIKE2SPIKESHAPES - Return spike shapes from a Spike2 record exported to Matlab
% 
%    [SPIKESHAPES]=READ_SPIKE2_SPIKESHAPES(SPIKE2FILENAME, SPIKECHANNEL,TIMES,SAMPLES)
% 
%    Inputs: SPIKE2FILENAME - The spike2 filename 
%            SPIKECHANNEL - The channel number for the spike data channel (e.g., 1)
%            TIMES - The spike times to be read, with 0 being onset time of spike2 recording
%            SAMPLES - The number of samples to return around each spike (before and after; the
%                      total samples returned will be 2*SAMPLES+1)
%            
%    Outputs: SPIKESHAPES - An Nx2*SAMPLES+1 matrix of spike shapes; each row is a different spikeshape
%
%    Needed libraries: the SON library from Malcolm Kidierth

 % open the file, mimicking Kidierth's ImportSMR.m here

[pathname filename2 extension]=fileparts(spike2filename);
if strcmpi(extension,'.smr')==1
    % Spike2 for Windows source file so little-endian
    fid=fopen(spike2filename,'r','l');
elseif strcmpi(extension,'.son')==1
    % Spike2 for Mac file
    fid=fopen(spike2filename,'r','b');
else
    warning('%s is not a Spike2 file\n', filename);
    matfilename='';
    return
end

[dummy,header] = SONGetADCChannel(fid,spikechannel,1,1);

block_length = length(dummy);

sample_times = 1+round(times/(header.sampleinterval*1e-6));

start_samples = sample_times - samples;
end_samples = sample_times + samples;

block_starts = 1 + floor(start_samples/block_length);
start_sample_within_block = 1+mod(start_samples,block_length);
block_ends = 1 + floor(end_samples/block_length);
end_sample_within_block = start_sample_within_block + 2*samples;

spikeshapes = zeros(length(sample_times),2*samples+1);

currentblock_start = -Inf;
currentblock_end = -Inf;

for i=1:length(sample_times),
	if block_starts(i)~=currentblock_start | block_ends(i)~=currentblock_end,
		data = SONGetADCChannel(fid,spikechannel,block_starts(i),block_ends(i));
		currentblock_start = block_starts(i);
		currentblock_ends = block_ends(i);
	end;
	if length(data)<end_sample_within_block(i), % if we don't have enough data to fill out the spike
		num_samples_available = length(data) - start_sample_within_block(i) + 1;
		spikeshapes(i,1:num_samples_available) = data(start_sample_within_block(i):length(data));
		spikeshapes(i,num_samples_available+1:end) = NaN;
	else,
		spikeshapes(i,:) = data(start_sample_within_block(i):end_sample_within_block(i));
	end;
end;

fclose(fid);

