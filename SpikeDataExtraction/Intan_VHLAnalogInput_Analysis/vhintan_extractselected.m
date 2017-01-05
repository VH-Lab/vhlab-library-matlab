function vhintan_extractselected(dirname, varargin)
% VHINTAN_EXTRACTSELECTED - Extract spikes from user-specified directories for a given experiment
%
%    VHINTAN_EXTRACTSELECTED(DIRNAME, ...)
%
%    Extracts spikes from user-specified test directories in DIRNAME.
%    The user is presented with a dialog box to choose the extraction parameters
%    and a second dialog box to choose the directories to be extracted.
%
%    One can pass additional arguments to the function to modify the default behavior
%    using name/value pairs:
% 
%    Parameter (default)              :  Description
%    ---------------------------------------------------------------------------
%    MEDIAN_FILTER_ACROSS_CHANNELS (1):  0/1 Should we median filter across channels?
%                                     :     (uses vhintan_filtermap.txt -- see help for this file)
%    SAMPLES ([-10 25])               :  [S0 S1] The number of samples to read around
%                                     :     each threshold crossing
%    REFRACTORY_PERIOD_SAMPLES (15)   :  Minimum number of samples that must occur
%                                     :     between reported spikes (spikes that are detected with
%                                     :     shorter intervals will be ignored)
%    
   
 % step 1 - assign default parameters and modify for user preferences

MEDIAN_FILTER_ACROSS_CHANNELS = 0;
SAMPLES = [ -10 25 ];
REFRACTORY_PERIOD_SAMPLES = 15;

assign(varargin{:}); % assign any parameters the user specified

 % step 1 - get the parameters

prompts = {'Perform median filter? (0/1)', 'Samples around spikes [begin end]', 'Refractory samples [N]'};
default_answers = { int2str(MEDIAN_FILTER_ACROSS_CHANNELS), mat2str(SAMPLES), int2str(REFRACTORY_PERIOD_SAMPLES) };
windowname = 'Choose extraction parameters';
numlines = 1;
options.Resize = 'on';
options.WindowStyle = 'normal';
options.Interpreter = 'none';

answer = inputdlg(prompts,windowname,numlines,default_answers,options);

if isempty(answer), return; end; % user cancelled

MEDIAN_FILTER_ACROSS_CHANNELS = str2num(answer{1});
SAMPLES = str2num(answer{2});
REFRACTORY_PERIOD_SAMPLES = str2num(answer{3});

 % step 2 - get the directories

ds = dirstruct(dirname);
T = getalltests(ds);

[s,ok] = listdlg('PromptString','Select directories to extract','SelectionMode','multiple','ListString',T);

if ok,
    VHLabGlobals;
    usep = ~isempty(VH_UseParallel);
    if usep,
        usep = VH_UseParallel;
    end;

    if usep,
        disp('Beginning parallel extraction..you will observe no feedback..wait');
        parfor t=1:length(s),
            vhintan_extractwaveforms([getpathname(ds) filesep T{s(t)}], SAMPLES, REFRACTORY_PERIOD_SAMPLES, ...
            	'MEDIAN_FILTER_ACROSS_CHANNELS',MEDIAN_FILTER_ACROSS_CHANNELS);
        	vhintan_sync2spike2([getpathname(ds) filesep T{s(t)}]);
        end;
        disp('Parallel extraction completed successfully');
    else,
    	for t=1:length(s),
    		vhintan_extractwaveforms([getpathname(ds) filesep T{s(t)}], SAMPLES, REFRACTORY_PERIOD_SAMPLES, ...
        		'MEDIAN_FILTER_ACROSS_CHANNELS',MEDIAN_FILTER_ACROSS_CHANNELS);
        	vhintan_sync2spike2([getpathname(ds) filesep T{s(t)}]);
        end;
	end;
end;

