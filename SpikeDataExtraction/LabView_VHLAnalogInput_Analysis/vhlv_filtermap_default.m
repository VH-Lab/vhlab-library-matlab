function s=vhlv_filtermap_default
% VHLV_FILTERMAP_DEFAULT - Describes the vhlv_filtermap.txt file for multichannel analysis
%
%   In each directory that contains data that was recorded by the VH Lab
%   LabView multichannel analog input program, there should be a file
%   called "vhlv_filtermap.txt" that describes how the channels should be 
%   grouped for the purpose of filtering.
%
%   It should have the following format:
%
%   The first line should contain the text 'channel_list' followed by
%   a carriage return.
%
%   Each subsequent line should contain a list of channels to be grouped
%   together, expressed in Matlab matrix format:
%
%   Example:
%
%   Line 1:   channel_list
%   Line 2:   [1 2 3 4 5 6 7 8]
%   Line 3:   [9 10 11 12 13 14 15 16]
%
%   This file can be read by the function LOADSTRUCTARRAY

s = struct('channel_list',[1 2 3 4 5 6 7 8]);
s(end+1) = struct('channel_list',[9 10 11 12 13 14 15 16]);
