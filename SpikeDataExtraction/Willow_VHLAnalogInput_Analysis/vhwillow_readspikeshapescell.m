function [spikeshapes] = vhwillow_readspikeshapescell(dirname, cell, samples)
%  READ_VHWILLOW_SPIKESHAPES - Return spike shapes from vhwillow_analoginput.vld file for a given cell
% 
%    [SPIKESHAPES]=READ_SPIKE2_SPIKESHAPES(DIRNAME,CELL)
% 
%    Inputs: DIRNAME - The directory name to examine (full path)
%            CELL - A SPIKEDATA object that may have spikes present in DIRNAME
%            SAMPLES - The number of samples to read before and after the spike.
%            
%    Outputs: SPIKESHAPES - An Nx2*SAMPLES+1 matrix of spike shapes; each row is a different spikeshape
%
%    This function only reads spikeshapes from the times indicated; if you are looking to extract spikeshapes from
%    a file based on a threshold, see VHWILLOW_EXTRACTWAVEFORMS.
%
%    See also: READVHWILLOWDATAFILE, READ_SPIKE2_SPIKESHAPES


vhwillowfilename = vhwillow_getdirfilename(dirname);

interval = getdataintervalfromdirname(dirname);

 % still need to extract the correct channel

spiketimes = get_data(cell,interval);

spikeshapes = vhwillow_readspikeshape(vhwillowfilename, spikechannel, spiketimes, samples);

