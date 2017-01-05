function [KL, H] = JohannaKL_wholething(filename)
% JOHANNAKL_WHOLETHING - peform KL analysis from a filename of data
%
%  [KL,H] = JOHANNAKL_WHOLETHING(FILENAME)
%
%  This function calls JOHANNADATA2SPIKESBINS and JOHANNAKL to return
%  the KL difference values and entropy.  
%
%  See JOHANNAKL for a description of the KL and H outputs.
% 

[spikes,timebins,eventtimes,numcells]=JohannaData2SpikesBins(filename);
[KL,H] = JohannaKL(spikes);
