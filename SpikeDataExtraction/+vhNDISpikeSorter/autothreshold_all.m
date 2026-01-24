function autothreshold_all(ds, args)
% AUTOTHRESHOLD_ALL - Perform automatic spike threshold determination on all records
%
%   AUTOTHREHSOLD_ALL(DS, ...)
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

    arguments
        ds
        args.sigma = 4;
        args.pretime = 20.0;
        args.usemedian = 0;
        args.MEDIAN_FILTER_ACROSS_CHANNELS = 0;
    end

    sigma = args.sigma;
    pretime = args.pretime;
    usemedian = args.usemedian;
    MEDIAN_FILTER_ACROSS_CHANNELS = args.MEDIAN_FILTER_ACROSS_CHANNELS;


[dirs,status] = vhNDISpikeSorter.getdirectorystatus(ds);

 % step 1 - sort the list
[sorted,order] = sort(dirs);

dirs = dirs(order);
status = status(order);

 % step 2 - autothreshold each directory %the first directory

for i=1:numel(dirs),
	vhNDISpikeSorter.autothreshold_dir([getpathname(ds) filesep dirs{i}],'sigma',sigma,'pretime',pretime,'usemedian',usemedian,...
		'MEDIAN_FILTER_ACROSS_CHANNELS',MEDIAN_FILTER_ACROSS_CHANNELS);
end

 % step 3 - copy these to subsequent directories

%vhNDISpikeSorter.copythresholds(ds,dirs{1});
