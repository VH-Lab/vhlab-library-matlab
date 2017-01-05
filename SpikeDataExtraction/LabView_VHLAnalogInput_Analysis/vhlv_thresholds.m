% VHLV_THRESHOLDS - Describes the vhlv_thresholds.txt file for multichannel analysis
%
%   In each directory that contains data that was recorded by the VH Lab
%   LabView multichannel analog input program, there should be a file
%   called "vhlv_thresholds.txt" that describes the thresholds that should
%   be used for spike detection.
%
%   It should have the following format:
%
%   The first line should contain the text 'channel' followed by a tab, followed
%   by the word "threshold", followed by a carriage return.
%
%   Each subsequent line should contain an instruction for detecting threshold.
%   Presently, there are 2 options:
%
%   1) To specify that spike detection threshold on a given channel should be 
%   N standard deviations below of the signal, use [-N] (or [N] for above the
%   standard deviation).
%
%   2) To specify that a specific threshold value should be used, provide
%   [VALUE SIGN 0]
%   where value is the threshold value, SIGN is -1 (for below) or 1 (for above),
%   and 0 is simply needed by our program.
%
%   Example:
%
%   Line 1:   channel<tab>threshold
%   Line 2:   1<tab>[-0.2 -1 0]
%   Line 3:   2<tab>[-3]
%
%   This indicates that spikes on channel 1 should be detected when the signal
%   falls below the value -0.2, and spikes on channel 2 should be detected when
%   the signal is less than 3 standard deviations below 0.
%
%   This file can be read by the function LOADSTRUCTARRAY

