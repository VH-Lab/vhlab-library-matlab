function [thestimscript,mti,startTime] = getstimscriptsync(dirname, useglobal)
% GETSTIMSCRIPT - Return a stimscript from a directory, with synchronization run
%
%   [THESTIMSCRIPT,MTI,STARTTIME] = GETSTIMSCRIPTSYNC(DIRNAME, USEGLOBAL)
%
%   Looks for the existence of a 'stims.mat' file in the directory DIRNAME.
%   If it exists, it loads the STIMSCRIPT (variable 'saveScript') and the
%   measured timing information (variable 'MTI2').
%
%   This calls the function 'TPCORRECTMTI' to perform synchronization with other
%   devices. STARTTIME is the time of beginning of the acquisition in
%   DIRNAME.  
%
%   GLOBAL determines if the time returned is relative to the stimulus computer's
%   clock. Generally, one wants 1 for spike data and 0 for non-spike data.
%
%   See also: GETSTIMSCRIPT, STIMSCRIPT, DIRSTRUCT/GETSTIMSCRIPT

[thestimscript,mti] = getstimscript(dirname);
[mti,startTime] = tpcorrectmti(mti,[fixpath(dirname) 'stimtimes.txt'], useglobal);


