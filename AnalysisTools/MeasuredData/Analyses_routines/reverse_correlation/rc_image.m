function [img, img_hz] = rc_image(avgstim, gridsize, stepsize, numspikes)
% RC_IMAGE - Display an image of STA at a particular time offset
%
%   [IMG, IMG_HZ] = RC_IMAGE(AVGSTIM, GRIDSIZE, STEPSIZE, NUMSPIKES)
%  
%  Creates an image view of the average stim picture that is
%  returned by SINGLE_RC.  GRIDSIZE should be the size of the
%  stimulus grid (for example, [10 10] for 10 x 10), and
%  NUMSPIKES is the number of spikes that occurred during
%  the stimulus run. STEPSIZE is the time step of the kernel
%  in AVGSTIM.
%
%  Returns IMG, a GRIDSIZE(1) x GRIDSIZE(2) x SIZE(AVGSTIM,1)
%  image that can be displayed with IMAGE(IMG(:,:,i)) to
%  display the ith time step (see SINGLE_RC).
%
%  Also returns IMG_HZ which has units of spikes per second;
%  this is the predicted response to the best stimulus in that
%  time window. 

img = reshape(avgstim',gridsize(1),gridsize(2),size(avgstim,1));
img_hz = img * numspikes / stepsize;
