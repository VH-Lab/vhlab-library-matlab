function [spikeshapes] = vhlv_readspikeshapescell(dirname, cell, samples)
%  READ_VHLV_SPIKESHAPES - Return spike shapes from vhlv_analoginput.vld file for a given cell
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
%    a file based on a threshold, see VHLV_EXTRACTWAVEFORMS.
%
%    See also: READVHLVDATAFILE, READ_SPIKE2_SPIKESHAPES


vhlvfilename = [dirname filesep 'vhlvanaloginput.vld'];

interval = getdataintervalfromdirname(dirname);

 % still need to extract the correct channel

spiketimes = get_data(cell,interval);

spikeshapes = vhlv_readspikeshape(vhlvfilename, spikechannel, spiketimes, samples);

