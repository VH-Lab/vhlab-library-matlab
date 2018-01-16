% VHSPIKE2_SPIKE22SPIKE2TIME - File describing shift between Spike2 records and Spike2 records
%
%  This file contains 2 numbers, SHIFT and SCALE, such that:
%
%     SPIKE2TIME = SHIFT + SCALE * SPIKE2_TIME
%
%  This file is written by the VHSPIKE2_SYNC2SPIKE2 function, which is normally
%  called automatically (that is, the user does not need to call it).
%
%  Example:  
%  If you have a bunch of event times SPIKE2_EVENTS in units of Intan time,
%  then you can convert them to Spike2 time:
%
%  SHIFTSCALE = load('vhspike2_spike22spike2time.txt','-ascii');
%
%  SPIKE2EVENTS = SHIFTSCALE(1) + SHIFTSCALE(2)*SPIKE2_EVENTS
%
%  SHIFT will always be 0, SCALE will always be 1
%
%  See also: Spike2_VHLAnalogInput_Analysis, VHSPIKE2_SYNC2SPIKE2
    
 
