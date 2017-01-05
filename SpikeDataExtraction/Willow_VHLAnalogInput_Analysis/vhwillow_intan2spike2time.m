% VHWILLOW_WILLOW2SPIKE2TIME - File describing shift between Willow multichannel records and Spike2 records
%
%  This file contains 2 numbers, SHIFT and SCALE, such that:
%
%     SPIKE2TIME = SHIFT + SCALE * WILLOW_TIME
%
%  This file is written by the VHWILLOW_SYNC2SPIKE2 function, which is normally
%  called automatically (that is, the user does not need to call it).
%
%  Example:  
%  If you have a bunch of event times WILLOW_EVENTS in units of Willow time,
%  then you can convert them to Spike2 time:
%
%  SHIFTSCALE = load('vhwillow_willow2spike2time.txt','-ascii');
%
%  SPIKE2EVENTS = SHIFTSCALE(1) + SHIFTSCALE(2)*WILLOW_EVENTS
%
%  See also: Willow_VHLAnalogInput_Analysis, VHWILLOW_SYNC2SPIKE2
    
 
