function c = sampleAPI_clock(device, interval)
% SAMPLEAPI_CLOCK - specify a clock for an experiment
%
%   C = SAMPLEAPI_CLOCK  returns a clock that is in units that are
%   global to the experiment.
%
%   C = SAMPLEAPI_CLOCK(DEVICE) returns a clock that is in units of
%   time local to the device DEVICE.
%
%   C = SAMPLEAPI_CLOCK(DEVICE, INTERVAL) returns a clock that is relative
%   to the beginning of the INTERVALth recording of device DEVICE.
%
%

if nargin==0,
	type = 'global';
	device = [];
	interval = [];
elseif nargin==1,
	type = 'local';
	interval = [];
elseif nargin==2,
	type = 'interval-relative';
end;

sampleapi_clock_structure = struct('type',type,'device',device,'interval',interval);

c = class(sampleapi_clock_structure,'sampleAPI_clock');
