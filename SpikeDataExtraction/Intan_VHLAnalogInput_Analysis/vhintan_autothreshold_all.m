function vhintan_autothreshold_all(ds, varargin)
% VHINTAN_AUTOTHRESHOLDALL - Perform automatic spike threshold determination on all records
%
%   VHINTAN_AUTOTHREHSOLD_ALL(DS, ...)
%
%   Perform automatic spike threshold determination on all records in
%   the directory structure DS.  The first directory is examined and the
%   thresholds are applied to all subsequent directories.
%
%  Extra parameters can be passed as NAME/VALUE pairs:
%  Parameter name (default)        : Description
%  --------------------------------------------------------------------
%  sigma (4)                       : Number of standard deviations away to set
%                                  :    threshold. The standard deviation is
%                                  :    using the median(abs(data))/0.6745 method.
%  pretime (20.0)                  : Number of seconds of data to examine in
%                                  :    determining threshold.
%  usemedian (0)                   : Use the median divided by 0.6745 to determine sigma
%  MEDIAN_FILTER_ACROSS_CHANNELS(0): 0/1 Perform a median filter across filtermap channels?
%
%  

 % step 1 - assign default values and user changes

sigma = 4;
pretime = 20.0;
usemedian = 0;
MEDIAN_FILTER_ACROSS_CHANNELS = 0;

assign(varargin{:});

[dirs,status] = vhintan_getdirectorystatus(ds);

 % step 1 - sort the list
[sorted,order] = sort(dirs);

dirs = dirs(order);
status = status(order);

 % step 2 - autothreshold the first directory

vhintan_autothreshold_dir([getpathname(ds) filesep dirs{1}],'sigma',sigma,'pretime',pretime,'usemedian',usemedian,...
	'MEDIAN_FILTER_ACROSS_CHANNELS',MEDIAN_FILTER_ACROSS_CHANNELS);

 % step 3 - copy these to subsequent directories

vhintan_copythresholds(ds,dirs{1});


