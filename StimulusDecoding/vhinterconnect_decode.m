function out = vhinterconnect_decode(time,input,polarity)
% VHINTERCONNECT_DECODE - Decode the 16 bit vhlab stimulus interconnect signals
%
%  OUT = VHINTERCONNECT_DECODE(TIME,INPUT)
%
%  Given a UINT16 array of INPUT, sampled at times TIME (an array in seconds the same size
%  as INPUT), this function decodes the data according to the VH lab stimulus interconnect scheme:
%
%  BIT  |  Description
%  ---------------------------------------------------------------
%   1   |  Stim Trigger (indicates when stimulus goes ON and OFF)
%   2   |  Frame Trigger (indicates when video frame changes)
%   3   |  Visual stimulus monitor vertical refresh (goes high and then low
%       |     whenever video device refreshes)
%   4   |  Pre-stimulus Trigger (goes high when the stimulus is cued up, 
%       |     remains high until stimulus is over; often this is used for
%       |     intrinsic-signal imaging, as it can be made to come on 0.5 - 1 
%       |     seconds before the visual stimulus comes on)
%   5   |  2-photon frame trigger (goes high then low then the 2-photon acquires
%             a frame)
%   6   |  (2-photon expansion slot, not presently used)
%   7   |  (Expansion, not presently used)
%   8   |  (Expansion, not presently used)
%  9-16 |  8-bit code for the stimulus (0..255). 9 is least significant bit.
%       |  This signal is read out only when the Stim Trigger is activated.
%
%  OUT = VHINTERCONNECT_DECODE(TIME, INPUT, POLARITY)
%
%  One can optionally provide POLARITY, which indicates the polarity of
%  transitions that indicates the signal (can be -1: indicating a high to low
%  transition is the signal, or 1: indicating a low to high transition is the
%  signal).  Only bits 1-8 are modifyable (the 8-bit stimulus code always codes
%  with high information).
%  POLARITY_DEFAULT = [-1 1 -1 1 1 1 1 1 1];
%  
%  If the user only wants to modify the polarity of some channels, he/she can
%  pass NaN for that channel. For example, to indicate that the Stim Trigger
%  signal is a low to high transition, one can use POLARITY=[1 NaN(1,7)]
%
%  OUT is a structure with the following fields:
%  StimTrigger = [times when stimulus trigger going ON]
%  StimTriggerOff = [ times with stimulus trigger going OFF]
%  FrameTriggerRaw = [times with frame trigger]
%  PreStimulusTrigger = [times with Pre-Stimulus trigger]
%  StimulusMonitorVerticalRefresh = [times with vertical refresh trigger]
%  TwoPhotonFrameTrigger = [ times with two photon frame trigger]
%  StimCode = [ stimulus code number for each stimulus trigger]

default_polarity = [ -1 1 -1 1 1 1 1 1 1];

if nargin>2,
	goodinds = find(isnan(polarity));
	default_polarity(goodinds) = polarity(goodinds);
else,
	polarity = default_polarity;
end;

th    = struct('name','StimTrigger','bit',1,'samples',0,'polarity',polarity(1));
th(2)    = struct('name','StimTriggerSamples','bit',1,'samples',1,'polarity',polarity(1));
th(3)    = struct('name','StimTriggerOff','bit',1,'samples',0,'polarity',polarity(2));
th(4) = struct('name','FrameTriggerRaw','bit',2,'samples',0,'polarity',polarity(3));
th(5) = struct('name','StimulusMonitorVerticalRefresh','bit',3,'samples',0,'polarity',polarity(4));
th(6) = struct('name','TwoPhotonFrameTrigger','bit',5,'samples',0,'polarity',polarity(5));

out = struct;

for i=1:length(th),
	bitinfo = bitget(input,th(i).bit);
	if th(i).polarity<0, bitinfo = 1- bitinfo; end;
	samples = threshold_crossings(bitinfo,1);
	if th(i).samples==0,
		out = setfield(out,th(i).name,time(samples));
	else,
		out = setfield(out,th(i).name,samples);
	end;
end;

out.StimCode = bitshift(bitand(input(out.StimTriggerSamples), intmax('uint16') - 255),-8);

