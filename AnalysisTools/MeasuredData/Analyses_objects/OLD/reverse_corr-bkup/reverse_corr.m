function rc = reverse_corr(inputs, parameters, where)

%  Part of the NeuralAnalysis package
%
%  RC = REVERSE_CORR(INPUTS,PARAMETERS,WHERE)
%
%  Creates a new reverse_corr object.  It computes the "average" image which
%  preceded the spiking of a particular neuron.  It also optionally brings up
%  a raster plot which shows the stimulus-response profile of the neuron
%  triggered on the display of any particular portion of the image, and this
%  portion is selectable by the user.  In addition, it optionally brings up a
%  spike-triggered average value of the selected image portion.
%
%  INPUTS should be a struct with the following fields:
%     spikes  {1xN}    :    a cell list of spikedata objects
%   stimtime  [1xM]    :    a vector of stimtime records of stimuli (see
%                      :      'help stimtimestruct')
%   cellnames {1xN}    :    cell list containing names for the spikedata
%                      :      objects above
%
%  PARAMETERS should be a struct with the following fields, or the string
%  'defaults':
%   interval [1x2]     :   interval after each frame in which to count spikes
%   showrast [1x1] 0/1 :   whether or not to show a raster along with the
%                      :      reverse correlation*
%   show1drev[1x1] 0/1 :   whether or not to show a one-dimentional reverse
%                      :      correlation for the currently selected center
%   showabsol[1x1] 0/1 :   whether 1d rev correlation should be with absolute
%                      :      intensity values or absolute value of derivative
%   showdata [1x1] 0/1 :   whether or not to show a plot with the data values
%                      :      for a grid point and the spikes.
%   normalize[1x1]     :   0=>no normalization, 1=>normalize to 256 colors by
%                      :      maximum, 2=> use 256 colors from min to max.
%   chanview [1x1]     :   0=>view composite,1=>view red ,2=>view green,3=>view
%                      :      blue; this also determines how the maxmimum
%                      :      location is determined
%   colorbar [1x1] 0/1 :   whether or not to show a colorbar along with the
%                      :      reverse correlation image
%  clickbehav[1x1]     :   0=> zoom, 1=> drag manually select center, 2=>
%                      :      select new grid point for raster, one-dimensional
%                      :      reverse correlation (if possible)
%                      :      image drags a new center rectangle; if possible *,
%                      :      if this is 0 clicking re-directs the raster to
%                      :      that grid point. 
%  datatoview[1x3]     :   [cell stim trial], tells which image to view
%                      :      (should be integers referring to the Nth cell,
%                      :       stimulus, or presentation in input); stim and
%                      :      trial indicate which structures the computations
%                      :      are restricted; if 0 is given for stim, this means
%                      :      an average of all the stims for a given cell, and
%                      :      if 0 is given for trial, then this means average
%                      :      over the trials of that stim.
%show1drevprs[1x5]     :    [mode tres start stop show_std]
%                      :      mode=0=>show value,mode=1=>show abs derivative,
%                      :      tres -> time resolution (e.g., 0.001 = 1ms)
%                      :      start,stop=interval to look in around each frame
%                      :      (e.g., -0.050 0.050 is plus/minus 50ms)
%                      :     show_std=1=>show standard deviation, too
%     bgcolor[1x1]     :   the color to treat as the background color; this is
%                      :     an index in the color list of a stochasticgridstim
%                      :     or blinkingstim (e.g., bgcolor=1=>first one)
%pseudoscreen[1x4]     :   rectangle for a virtual screen to show the stimulus
%                      :      upon.
%
%  The stim object chosen should have as a method a function called
%  'reverse_corr' which takes the stimulus, the frame times, the spike data,
%  and the interval post-stimulus in which to count spikes.  This function
%  should return a cell of size 3 which has the image matrix corresponding to
%  the average image in each of the three R,G,B channels.  If the function
%  returns a cell of size 4, the fourth element is assumed to be a matrix of
%  grid indicies and frames (see 'help stochasticgridstim/reverse_corr').  This
%  will allow some additional parameters marked with a * above.  (All parameters
%  must be given always, some will be ignored if that is appropriate.)
%  
%  See also:  ANALYSIS_GENERIC

%computations = struct('reverse_corr',[],'center',[],'center_rect',[]);
computations = struct('comps',[]);
internal=struct('rasterobj',[],'reverse1d',[],'oldint',[],'selectedbin',0);

[good,er]=verifyinputs(inputs); if ~good,error(['INPUT: ' er]); end;

nag = analysis_generic([],[],where); delete(nag);
ag = analysis_generic([],[],[]);
rc = class(struct('inputs',inputs,'RCparams',[],'computations',computations,...
	'internal',internal),'reverse_corr',ag);
rc = setparameters(rc,parameters);
%delete(contextmenu(rc)); rc = newcontextmenu(rc);
rc = compute(rc);
rc = setlocation(rc,where);
