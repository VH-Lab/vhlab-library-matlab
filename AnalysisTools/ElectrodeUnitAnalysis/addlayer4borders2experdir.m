function [cells,cellnames] = addlayer4borders2experdir(dirname, borderdepths, saveit, penetration_assoc, penetration_number)

% ADDLAYER4BORDERS2EXPERDIR - Add information to an experiment
%
%   [CELLS,CELLNAMES]=ADDLAYER4BORDERS2EXPERDIR(DIRNAME,BORDERDEPTHS,SAVEIT)
%   or
%
%   Adds an associate to cells in an experiment.
%
%   DIRNAME should be a directory name of an experiment that confirms to
%   the DIRSTRUCT organization.
%
%   BORDERDEPTHS can be a 1x2 vector that contains the [TOP BOTTOM] depths of
%   layer 4 for the given experiment.  It can also be a 1x3 vector that 
%   indcates the [SURFACE TOP BOTTOM] depths.
%
%   If SAVEIT is 1, then the changes are saved to disk.  If SAVEIT is 0, the
%   changes are applied to the list of cell data in CELLS that is returned.
%
%   This function returns all cells and cellnames in the experiment in CELLS
%   and CELLNAMES.
%
%   One can also restrict the assignment of Layer 4 border depths to particular
%   penetrations
%   
%      ... = ADDLAYER4BORDERS2EXPERDIR(DIRNAME,BORDERDEPTHS,SAVEIT,...
%                PENETRATION_ASSOC, PENETRATION_NUMBER)
%
%   See also:  ADDASSOCIATEDATA2EXPERDIR STANDARDIZED_DEPTH
%

assoc = struct('type','Layer 4 border depths','owner','addlayer4border2experdir','data',borderdepths,...
		'desc','Layer 4 border depths as determined during the penetration; either [top bottom] or [surface top bottom]');

if nargin>3,
	addassociatedata2experdir(dirname,assoc,saveit,p_assoc,p_num);
else,
	addassociatedata2experdir(dirname,assoc,saveit);
end;

