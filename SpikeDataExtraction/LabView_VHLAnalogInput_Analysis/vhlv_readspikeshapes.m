function [spikeshapes] = vhlv_readspikeshapes(vhlvfilename, spikechannel, times, samples)
%  VHLV_READSPIKESHAPES - Return spike shapes from vhlv_analoginput.vld file given spike times
% 
%    [SPIKESHAPES]=VHLV_READSPIKESHAPES(VHLVFILENAME, SPIKECHANNEL,TIMES,SAMPLES)
% 
%    Inputs: VHLVFILENAME - The vhlvdatafile filename (full path)
%            SPIKECHANNEL - The channel number for the spike data channel (e.g., 1)
%            TIMES - The spike times to be read, with 0 being onset time of the VHLV data file
%            SAMPLES - The number of samples to return around each spike (before and after; the
%                      total samples returned will be 2*SAMPLES+1).
%            
%    Outputs: SPIKESHAPES - An Nx2*SAMPLES+1 matrix of spike shapes; each row is a different spikeshape
%
%    This function only reads spikeshapes from the times indicated; if you are looking to extract spikeshapes from
%    a file based on a threshold, see VHLV_EXTRACTWAVEFORMS.
%
%    See also: READVHLVDATAFILE, READ_SPIKE2_SPIKESHAPES

[pathname,fname,ext] = fileparts(vhlvfilename);

h = readvhlvheaderfile([pathname filesep fname '.' 'vlh']);

time_samples =  (samples / h.SamplingRate); % convert samples to time for readvhvldatafile

spikeshapes = zeros(numel(times),2*samples+1);

for i=1:numel(times),
	[t,spikeshapes(i,:)] = readvhlvdatafile(vhlvfilename,h,spikechannel,times(i)-time_samples,times(i)+time_sampes);
end;

