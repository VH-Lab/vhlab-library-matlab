function tc = tuning_curve(inputs, parameters, where)

%  TUNING_CURVE  Creates a tuning curve based on a parameter
%  
%  TC = TUNING_CURVE(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new tuning_curve object.  It allows visualization of data taken
%  across many conditions.  It also looks for maxima and minima in the
%  curve.   WHERE should be a set of parameters as described in 'help
%  analysis_generic'.
%
%  INPUTS should contain the following fields:
%      st [1xN]     :    a stimscripttime structure containing the script
%                   :      and display timing information
%  spikes [1x1]     :    the spikedata describing the neural data
%paramname[1xN]     :    string of the parameter name to look at (must be a
%                   :      parameter in the stimulus)
%
%  PARAMETERS should contain the following fields:
%    res      [1x1] :    binning interval for raster
%   showrast  [1x1] :    0/1 show rasters/psth for individual conditions
%   interp    [1x1] :    interpolation factor; will interpolate using 
%                   :      'interp*num points provided' number of points
%   drawspont [1x1] :    0/1 whether or not to show a raster of spontaneous
%                   :      activity (if any was recorded)

computations=struct('curve',[],'maxes',[],'mins',[]);
internals = struct('rast',[],'spont',[]);

[good,er]=verifyinputs(inputs); if ~good,error(['INPUT: ' er]); end;

nag=analysis_generic([],[],where); delete(nag); ag=analysis_generic([],[],[]);

tc = class(struct('inputs',inputs,'TCparams',[],'internals',internals,...
        'computations',computations),'tuning_curve',ag);
tc = setparameters(tc,parameters); % must be immediately after above
%delete(contextmenu(tc)); tc = newcontextmenu(tc);  % install new contextmenu
tc = compute(tc);
tc = setlocation(tc,where);
