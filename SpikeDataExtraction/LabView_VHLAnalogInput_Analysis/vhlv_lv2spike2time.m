% VHLV_LV2SPIKE2TIME - File describing shift between Labview multichannel records and Spike2 records
%
%  This file contains 2 numbers, SHIFT and SCALE, such that:
%
%     SPIKE2TIME = SHIFT + SCALE * LABVIEW_TIME
%
%  This file is written by the VHLV_SYNC2SPIKE2 function, which is normally
%  called automatically (that is, the user does not need to call it).
%
%  Example:  
%  If you have a bunch of event times LV_EVENTS in units of labview time,
%  then you can convert them to Spike2 time:
%
%  SHIFTSCALE = load('vhlv_lv2spike2time.txt','-ascii');
%
%  SPIKE2EVENTS = SHIFTSCALE(1) + SHIFTSCALE(2)*LV_EVENTS
%
%  See also: LabView_VHLAnalogInput_Analysis, VHLV_SYNC2SPIKE2
    
 
