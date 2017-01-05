function unitquality
% UNITQUALITY - Info for the unitquality.txt file, used to determine which cells to keep and which to remove
%
%  The unitquality.txt file is one way of specifying the quality of single
%  units analyzed using the Plexon Offline Spike Sorter.
%
%  The format of the file is as follows. The first row has field names, separated
%  by tabs. Each additional row has the values of those fields.
%
%  channel<tab>unit<tab>goodtestdirs<tab>qualitycode<tab>comment
%
%  Channel is the channel number that the recording is on in the file that has been
%  prepared for Plexon.  The text file 'vhlv_channelgrouping.txt' describes the mapping
%  between channels in the Plexon file and records in the 'reference.txt' file.
%
%  IF there is a shift between the channels in Plexon and the channels described in the
%  rerference.txt files, then there should be an additional file 'unitquality_channelshift.txt'
%  with a single line that has the shift to apply. For example, if the 1st channel was used as
%  a sync channel, then this number should be -1 so that Plexon channel 2 shifts to the first entry
%  of the reference list.
%  
%  It is assumed that all channels use a name/ref of 'extraN',
%  and that the reference number is 1; unit is a list of units to be included; can
%  be 'a,b,c' or '401,402,403',etc; goodtestdirs is a list of directories that have
%  valid data for those cells; qualitycode is a code that describes the quality of
%  the recorings and can be 'multinit' (or 'mu'),'excellent' ('e'),'good' ('g'),
%  'not useable' ('nu').  Comment can be any text the user wants.
%
%  See also: VHLV_CHANNELGROUPING, REFERENCE_TXT
%  
