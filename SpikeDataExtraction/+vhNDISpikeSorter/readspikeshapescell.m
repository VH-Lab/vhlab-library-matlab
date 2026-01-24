function [spikeshapes] = readspikeshapescell(dirname, cell, samples)
%  READ_VHINTAN_SPIKESHAPES - Return spike shapes from vhintan_analoginput.vld file for a given cell
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
%    a file based on a threshold, see VHINTAN_EXTRACTWAVEFORMS.
%
%    See also: READVHINTANDATAFILE, READ_SPIKE2_SPIKESHAPES


vhintanfilename = vhNDISpikeSorter.getdirfilename(dirname);

interval = getdataintervalfromdirname(dirname);

 % still need to extract the correct channel

spiketimes = get_data(cell,interval);

spikeshapes = vhNDISpikeSorter.readspikeshapes(vhintanfilename, spikechannel, spiketimes, samples);
