% PLEXONSPIKES-LV - Describes the plexonspikes-lv.txt file for spike-sorting in Plexon
%
%  In each directory that contains data that was 1) recorded by the VH Lab
%  LabView multichannel analog input program, and 2) was spike-sorted using
%  Plexon's offline sorter, the information from the offline sorter should be
%  exported to a text file called 'plexonspikes-lv.txt'.
%
%  This file should have the following format. Each spike is represented by a single
%  line with 3 tab-delimited entries: [the channel] [the cluster number] [the spike time]
%
%  The channel refers to the Nth channel in the LabView file; this can be mapped to any
%  name/reference pair (see next paragraph).
%
%  The mapping between the name/ref entries in the reference.txt file
%  (see help REFERENCE_TXT) is given in the 'vhlv_channelgrouping.txt' file
%  (see help VHLV_CHANNELGROUPING).
%
%  The spike time units are in seconds and are in the "LabView" clock. They can be 
%  converted to spike2 time in seconds with the VHLV_LV2SPIKE2TIME file.
%
%  Example file:
%    1	5	3.45
%    1	1	3.55
%    2	1	3.555
%
%  This file states that there are 3 spikes, 2 that was recorded on channel 1 of the
%  LabView file, and 1 that was recorded on channel 2 of the LabView file. The first
%  spike was in the 5th spike cluster on channel 1 land occurred at time 3.45 seconds.
%  The second spike was in the 1st spike cluster on channel 1 and occurred at time 3.55 seconds.
%  The third spike was in the 1st spike cluster on channel 2 and occurred at time 3.555 seconds.
%  
%
%  See also: IMPORTSPIKEDATA, VHPLEXLV_IMPORTCELLS
%  
