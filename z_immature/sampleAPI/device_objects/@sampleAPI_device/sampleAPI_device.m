function d = sampleAPI_device(name)
% SAMPLEAPI_DEVICE - Create a new SAMPLEAPI_DEVICE object
%
%  D = SAMPLEAPI_DEVICE(NAME)
%
%  Creates a new SAMPLEAPI_DEVICE object with the name NAME.
%  This is an abstract class that is overridden by specific devices.
%

sampleAPI_device_struct = struct('name',name);

d = class(sampleAPI_device_struct, 'sampleAPI_device');
