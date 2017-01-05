function [spikeshapes] = vhintan_readspikeshapes(vhintanfilename, spikechannel, times, samples)
%  VHINTAN_READSPIKESHAPES - Return spike shapes from vhintan_analoginput.vld file given spike times
% 
%    [SPIKESHAPES]=VHINTAN_READSPIKESHAPES(VHINTANFILENAME, SPIKECHANNEL,TIMES,SAMPLES)
% 
%    Inputs: VHINTANFILENAME - The vhintandatafile filename (full path)
%            SPIKECHANNEL - The channel number for the spike data channel (e.g., 1)
%            TIMES - The spike times to be read, with 0 being onset time of the VHINTAN data file
%            SAMPLES - The number of samples to return around each spike (before and after; the
%                      total samples returned will be 2*SAMPLES+1).
%            
%    Outputs: SPIKESHAPES - An Nx2*SAMPLES+1 matrix of spike shapes; each row is a different spikeshape
%
%    This function only reads spikeshapes from the times indicated; if you are looking to extract spikeshapes from
%    a file based on a threshold, see VHINTAN_EXTRACTWAVEFORMS.
%
%    See also: READVHINTANDATAFILE, READ_SPIKE2_SPIKESHAPES

[pathname,fname,ext] = fileparts(vhintanfilename);

h = read_Intan_RHD2000_header([pathname filesep fname '.' 'rhd']);

time_samples =  (samples / h.frequency_parameters.amplifier_sample_rate); % convert samples to time for readvhvldatafile

spikeshapes = zeros(numel(times),6*samples+1);

[b,a]=cheby1(4,0.8,300/(0.5*h.frequency_parameters.amplifier_sample_rate));

 % note: might need to read in more data to filter
for i=1:numel(times),
	[spikeshapes(i,:)] = read_Intan_RHD2000_datafile(vhintanfilename,h,'amp',spikechannel,times(i)-3*time_samples,times(i)+3*time_sampes);
	spikeshapes(i,:) = filtfilt(b,a,spikeshapes(i,:));
end;

spikeshapes = spikeshapes(:,2*samples:(4*samples+1));
