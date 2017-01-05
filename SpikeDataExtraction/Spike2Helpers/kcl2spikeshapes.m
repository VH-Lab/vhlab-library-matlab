function [spikeshapes, codes, t] = kcl2spikeshapes(spike2filename, spikechannel, spike_wavemark, samples)
% KCL2SPIKESHAPES - Return spike shapes from a sigTOOL kcl Spike2 record 
%
%   [SPIKESHAPES,CODES,T]=KCL2SPIKESHAPES(SPIKE2FILENAME, SPIKECHANNEL,SPIKE_WAVEMARK,SAMPLES)
%
%   Inputs: SPIKE2FILENAME - The spike2 filename (exported to Matlab from Spike2)
%           SPIKECHANNEL - The channel number for the spike data channel (e.g., 1)
%           SPIKE_WAVEMARK - The channel number of the wavemark channel that
%                          was used to detect spikes in Spike2 (e.g., 20)
%           SAMPLES - The number of samples to return around each spike (before and after; the
%                     total samples returned will be 2*SAMPLES+1)
%           
%   Outputs: SPIKESHAPES - An NxSAMPLES matrix of spike shapes; each row is a different spikeshape
%            CODES - The wavemark codes corresponding to each of the N spikes.
%            T - a time record (centered on the spiketime) of the points in SPIKESHAPES.
%
%   Example:
% 

g = load(spike2filename,'-mat');

fn = fieldnames(g);

spike = getfield(g,['chan' int2str(spikechannel)]);
spikeh = getfield(g,['head' int2str(spikechannel)]);

spikewavemark = getfield(g,['chan' int2str(spike_wavemark)]);
spikewavemark_h = getfield(g,['head' int2str(spike_wavemark)]);

clear g; % free up memory

num_spikes = size(spikewavemark.tim,1);

t_ = 0:6e-5:0+(length(spike.adc)-1)*6e-5;

t = (-samples:samples)*6e-5;

 % find sample time of each spike, assuming center at time 0

s = double(spikewavemark.tim(:,1))*(double(spikewavemark_h.tim.Scale)*double(spikewavemark_h.tim.Units))/6e-5+12;%spikewavemark.trigger;

inds = round(repmat([-samples:samples], num_spikes, 1) + repmat(s(:),1,2*samples+1));

spikeshapes = double(spike.adc(inds))*double(spikeh.adc.Scale);

codes = spikewavemark.mrk(:,1);
