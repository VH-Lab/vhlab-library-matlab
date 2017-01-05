function out = MCS_A1Poly32_right(in, in2)
% MCS_A1POLY32_RIGHT - Channel map (or depth) for right side of A1Poly32 NeuroNexus electrode to MCS
%    
%   CHANMAP       = MCS_A1POLY32_RIGHT
%   CHANMAP       = MCS_A1POLY32_RIGHT('channel')
%
%   The above forms of MCS_A1POLY32_RIGHT returns the channel map from the A1Poly32
%   channel electrode from NeuroNexus onto the Multichannel Systems (MCS) acquisition
%   system (using ADPT-NN-32). Only channels from the RIGHT SIDE of the probe (when viewed from the
%   front) are returned. The channels that come out are with respect to
%   depth. For example, MCS_A1POLY32_RIGHT(1) = 2, because channel 1 corresponds
%   to the deepest channel on the probe. MCS_A1POLY32_RIGHT(2) returns NaN, because
%   MCS channel 2 corresponds to a channel on the left side of the probe.
%   This version only return the channels that are on the RIGHT side of the probe
%   (corresponding to channels from 17 (bottom) to 23 (top) on the channel map
%   from NeuroNexus).
%
%   CHAN_I_ID     = MCS_A1POLY32_RIGHT(i)
%   CHAN_I_ID     = MCS_A1POLY32_RIGHT('channel',i)
%
%   These forms allow one to query a set of channels in the vector i. i can be
%   a single scalar or a vector.
%
%   CHANDEPTHS    = MCS_A1POLY32_RIGHT('depth')
%   CHAN_I_DEPTH  = MCS_A1POLY32_RIGHT('depth',i)
% 
%   These forms of MCS_A1POLY32_RIGHT return the depth relative to the bottom channel.
%   If a vector i is given, then only the ith subsets of depths is/are returned.
%
%   NUMCHANNELS = MCS_A1POLY32('number of channels');
%
%   Returns the number of channels for this electrode (32).
%   
%   See also: MCS_A1POLY32

 %chanmap_MCS = [16 12 15 10 14 8 13 6 4 2 1 3 5 7 9 11 32 30 31 28 29 ...
 %	26 27 24 25 20 22 19 23 18 21 17];
    % above is from Rig 1 Maurader Map shared file

   % this is the MCS channel that corresponds to each pad, with 1 on bottom

chanmap_MCS = 1:32; 

chanmap_NN = [ 17 21 18 23 19 22 20 25 24 27 26 29 28 31 30 32 ...
		11 9 7 5 3 1 2 4 6 13 8 14 10 15 12 16];

    % above is steve's map 2015-08-11

chanmap_depth = [ 16 17 15 18 14 19 13 20 12 21 11 22 1 32 2 31 3 30 4 ...
	29 5 28 6 27 7 26 8 25 9 24 10 23];

chanmap_depth_inv = [];
for i=1:length(chanmap_depth),
	chanmap_depth_inv(chanmap_depth(i)) = i;
end;

depth_map = 0:(50e-6):(31*50e-6);

default_channel_input = 1:32;

if nargin==0,
	out = MCS_A1Poly32_right('channel',default_channel_input);
elseif nargin==1,
	if strcmp(lower(in),'depth'),
		out = MCS_A1Poly32_right('depth',default_channel_input);
	elseif strcmp(lower(in),'channel'),
		out = MCS_A1Poly32_right('channel',default_channel_input);
	elseif strcmp(lower(in),'number of channels'),
		out = MCS_A1Poly32_right('number of channels',default_channel_input);
	else,
		out = MCS_A1Poly32_right('channel',in);
	end;
elseif nargin==2,
	if strcmp(lower(in),'depth'),
		out = NaN(size(in2));
		[in_a,in_b] = ismember(in2,chanmap_MCS);
		out(find(in_b)) = depth_map(chanmap_depth_inv(chanmap_NN(in_b)));
		out(find(mod(out,2*50e-6)<50e-7)) = NaN; % take out even depths
	elseif strcmp(lower(in),'channel'),
		[in_a,in_b] = ismember(in2,chanmap_MCS);
		out = NaN(size(in2));
		out(find(in_b)) = chanmap_depth_inv(chanmap_NN(in_b));
		out(find(mod(out,2)~=0)) = NaN; % take out odd channel numbers
		out = out / 2; % make numbers 1..2...16 instead of 2...4...32
	elseif strcmp(lower(in),'number of channels'),
		out = 16;
	elseif isa(in,'char'),
		error(['Unknown string input to MCS_A1POLY32_RIGHT.']);
	end;
end;
