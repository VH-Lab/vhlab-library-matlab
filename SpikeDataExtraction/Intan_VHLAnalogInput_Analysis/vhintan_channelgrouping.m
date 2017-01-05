% VHINTAN_CHANNELGROUPING - Describes the vhintan_channelgrouping.txt file for multichannel analysis
%
%   In each directory that contains data that was recorded by the 
%   Intan multichannel analog input program, there should be a file
%   called "vhintan_channelgrouping.txt" that describes how signals should
%   be grouped for spike waveform analysis.
%
%   It should have the following format:
%
%   The first line should contain the text 'name', followed by a tab, followed
%   by 'ref', followed by a tab, followed by the word 'channel_list',
%   followed by a carriage return and/or linefeed.
%
%   Each subsequent line should contain a name/reference pair and a list of
%   channels that correspond to that name/reference pair.
%
%   Example:
%
%   Line 1:   name<tab>ref<tab>channel_list
%   Line 2:   extra<tab>1<tab>[1 2]
%   Line 3:   extra<tab>2<tab>[3]
%
%   This indicates that channels 1 and 2 should be grouped, and that they correspond
%   to records with name 'extra' and reference 1.  Further, channel 3 should be considered alone, and they
%   correspond to name 'extra' and reference number 2.
%
%   This file can be read by the function LOADSTRUCTARRAY

