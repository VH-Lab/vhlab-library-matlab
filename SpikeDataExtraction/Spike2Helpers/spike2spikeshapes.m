function [spikeshapes, codes, t] = spike2spikeshapes(spike2filename, spikechannel, spike_wavemark, samples)
% SPIKE2SPIKESHAPES - Return spike shapes from a Spike2 record exported to Matlab
%
%   [SPIKESHAPES,CODES,T]=SPIKE2SPIKESHAPES(SPIKE2FILENAME, SPIKECHANNEL,SPIKE_WAVEMARK,SAMPLES)
%
%   Inputs: SPIKE2FILENAME - The spike2 filename (exported to Matlab from Spike2)
%           SPIKECHANNEL - The channel number for the spike data channel (e.g., 1)
%           SPIKE_WAVEMARK - The channel number of the wavemark channel that
%                          was used to detect spikes in Spike2 (e.g., 20)
%           SAMPLES - The number of samples to return around each spike (before and after; the
%                     total samples returned will be 2*SAMPLES+1)
%           
%   Outputs: SPIKESHAPES - An Nx2*SAMPLES+1 matrix of spike shapes; each row is a different spikeshape
%            CODES - The wavemark codes corresponding to each of the N spikes.
%            T - a time record (centered on the spiketime) of the points in SPIKESHAPES.
%
%   Example:
% 

g = load(spike2filename,'-mat');

fn = fieldnames(g);

spikechanname = ['Ch' int2str(spikechannel)];
spikewavemarkchanname = ['Ch' int2str(spike_wavemark)];

spikechanfield = [];
spikewavemarkfield = [];

for i=1:length(fn),
	if length(fn{i})>length(spikechanname),
		if strcmp(fn{i}(end-length(spikechanname)+1:end),spikechanname),
			spikechanfield = fn{i};
		end;
	end;
	if length(fn{i})>length(spikewavemarkchanname),
		if strcmp(fn{i}(end-length(spikewavemarkchanname)+1:end),spikewavemarkchanname),
			spikewavemarkchanname = fn{i};
		end;
	end;
end;

spike = getfield(g,spikechanfield);
spikewavemark = getfield(g,spikewavemarkchanname);

clear g; % free up memory

num_spikes = size(spikewavemark.times,1);

t_ = spike.start:spike.interval:spike.start+(spike.length-1)*spike.interval;

t = (-samples:samples)*spike.interval;

 % find sample time of each spike, assuming center at time 0

s = spikewavemark.times/spike.interval + spikewavemark.trigger;

inds = round(repmat([-samples:samples], num_spikes, 1) + repmat(s(:),1,2*samples+1));

spikeshapes = spike.values(inds);

codes = spikewavemark.codes(:,1);
