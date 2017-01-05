function [thestimscript,mti] = getstimscript(dirname)
% GETSTIMSCRIPT - Return a stimscript from a directory
%
%   [THESTIMSCRIPT,MTI] = GETSTIMSCRIPT(DIRNAME)
%
%   Looks for the existence of a 'stims.mat' file in the directory DIRNAME.
%   If it exists, it loads the STIMSCRIPT (variable 'saveScript') and the
%   measured timing information (variable 'MTI2').
%
%   See also: GETSTIMSCRIPTSYNC, STIMSCRIPT, DIRSTRUCT/GETSTIMSCRIPT

if ~exist([dirname]),
	error(['Directory ' dirname ' does not exist.']);
elseif ~exist([fixpath(dirname) 'stims.mat']),
	error(['No stims in directory ' dirname '.']);
else,
	g = load([fixpath(dirname) 'stims.mat'],'saveScript','MTI2');
	thestimscript = g.saveScript;
	mti = g.MTI2;
end;

