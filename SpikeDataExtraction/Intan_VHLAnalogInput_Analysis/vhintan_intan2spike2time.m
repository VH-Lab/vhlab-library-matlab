% VHINTAN_INTAN2SPIKE2TIME - File describing shift between Intan multichannel records and Spike2 records
%
%  This file contains 2 numbers, SHIFT and SCALE, such that:
%
%     SPIKE2TIME = SHIFT + SCALE * INTAN_TIME
%
%  This file is written by the VHINTAN_SYNC2SPIKE2 function, which is normally
%  called automatically (that is, the user does not need to call it).
%
%  Example:  
%  If you have a bunch of event times INTAN_EVENTS in units of Intan time,
%  then you can convert them to Spike2 time:
%
%  SHIFTSCALE = load('vhintan_intan2spike2time.txt','-ascii');
%
%  SPIKE2EVENTS = SHIFTSCALE(1) + SHIFTSCALE(2)*INTAN_EVENTS
%
%  See also: Intan_VHLAnalogInput_Analysis, VHINTAN_SYNC2SPIKE2
    
 
