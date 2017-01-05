function pc = periodic_curve(inputs, parameters, where)

%  PERIODIC_CURVE Creates a periodic curve based on a parameter
%  
%  PC = PERIODIC_CURVE(INPUTS, PARAMETERS, WHERE)
%
%  Creates a new periodic_curve object.  It allows visualization of data taken
%  across many conditions on up to four plots.
%  WHERE should be a set of parameters as described in 'help
%  analysis_generic'.
%
%  INPUTS should contain the following fields:
%      st [1xN]     :    a stimscripttime structure containing the scripts
%                   :      and display timing information
%  spikes [1x1]     :    the spikedata describing the neural data
%paramnames{1x1or2} :    string of the parameter name to look at (must be a
%                   :      parameter in the stimulus).  If two values are given,
%                   :      then many curves of the second are plotted against
%                   :      the first.
%    blankid [1xM]  :    optional argument that specifies some of the stims as
%                   :      blank controls.  If blankid is not given or is empty,
%                   :      then the stims are searched for the parameter 'isblank',
%                   :      and if that parameter is found, those stimuli are taken to
%                   :      to be the blank.  If blankid is not given and no
%                   :      stimulus has a parameter 'isblank', then the blank
%                   :      computation is not performed.  When computing F1/F2
%                   :      for the blank stim, the property 'tFrequency' of the
%                   :      each blank stim is used; if the stim does not have that property,
%                   :      then the median temporal frequency of all the stims is used.
%                   :      
%
%  PARAMETERS should contain the following fields:
%  title      [1xN] :    string of the title to use
%  res        [1x1] :    binning interval for raster (in s)
%  lag        [1x1] :    what lag should we use between stimulus and data for
%                   :      averaging (in s)?
%  paramnames {1xM} :    parameter names to provide restricting values
%  paramvalues{1xM} :    a list of values for the parameter names above to
%                   :      include.  For example:
%                   :      parnamnames = {'angle','contrast'},
%                   :        and values ={{0,30,60},{0.32, 0.64, 1}}
%                   :      means to look at all trials which uesd parameter
%                   :      'angle' == 0,30,or 60 and parameter 'contrast'
%                   :      == 0.32, 0.64, or 1.  Leave empty if no restrictions
%                   :     are to be used.
%  graphParams[1x4] :    A structure describing the plotting parameters for
%                   :     the four plots.
%     draw          :    0/1 should we draw the plot
%     howdraw       :    0 => linear linear 1=> log linear
%                   :    2 => linear log    3=> log log
%     showstderr    :    0/1 should we show stderr
%     showstddev    :    0/1 should we show stddeviation
%     showspont     :    0/1 should we show spontaneous activity (if avail)
%     whattoplot    :    0 => raster showing whole trial plots
%                   :       (whichdata must be 1x1)
%                   :    1 => raster showing whole trial plots
%                   :       using each cycle as a new trial
%                   :       (whichdata must be 1x1)
%                   :    2 => raster showing cycle-by-cycle plots
%                   :       of an individual stimulus
%                   ;       (whichdata must be 1x2)
%                   :    3 => show total response (f0)
%                   :    4 => show f1 response
%                   :    5 => show f2 response
%                   :    6 => show f1/f0 response
%                   :    7 => show f2/f1 response
%                   :    8 => show cycle-by-cycle-estimated mean (f0)
%                   :    9 => show cycle-by-cycle-estimated  f1
%                   :    10 => show cycle-by-cycle-estimated f2
%                   :    11 => show cycle-by-cycle-estimated f1/f0
%                   :    12 => show cycle-by-cycle-estimated f2/f1
%                   :    13 => show cycle-by-cycle means (f0)
%                   :    14 => show cycle-by-cycle f1
%                   :    15 => show cycle-by-cycle f2
%                   :    16 => show cycle-by-cycle f1/f0
%                   :    17 => show cycle-by-cycle f2/f1
%                   :    For 3-12, whichdata must be 1xN, describing which
%                   :      conditions to plot
%                   :    For 13-17, whichdata must be Mx1, describing which
%                   :     condition (whichdata(1)) and which stimuli in that
%                   :     condition to plot (whichdata(1,2:end))
%     whichdata     :    A list of indicies of which data conditions to plot
%                   :       (e.g.,if whichdata==1, then the lowest value of
%                   :       paramnames{2} will be plotted
%                   :       This list can also be two dimensional for plotting
%                   :       the results for a single stimulus, as in
%                   :       whichdata==[1 1], which will plot the lowest value
%                   :       of paramnames{2} and paramnames{1}


computations=struct('spont',[],'vals2',[],'vals1',[],'curve',[],'rast',[],...
                    'cycg_curve',[],'cycg_rast',[],'cyci_curve',[],...
                    'cyci_rast',[]);

internals = struct('rast',[],'spont',[],'oldparams',[],'blank',[]);

[good,er]=verifyinputs(inputs); if ~good,error(['INPUT: ' er]); end;

if ~isfield(inputs,'blankid'),
	for i=1:numStims(inputs.st.stimscript),
		if isfield(getparameters(get(inputs.st.stimscript,i)),'isblank'),
			inputs.blankid = i; break;
		end;
	end;
end;

if ~isfield(inputs,'blankid'), inputs.blankid = []; end;

nag=analysis_generic([],[],where); delete(nag); ag=analysis_generic([],[],[]);

pc = class(struct('inputs',inputs,'PCparams',[],'internals',internals,...
        'computations',computations),'periodic_curve',ag);
pc = setparameters(pc,parameters); % must be immediately after above
delete(contextmenu(pc)); pc = newcontextmenu(pc);  % install new contextmenu
% pc = compute(pc); % not necessary b/c called from setparameters
pc = setlocation(pc,where);
