function [ssp, do] = stimscriptproperties(prefix, cells, cellnames, associatename)
% STIMSCRIPTPROPERTIES - Examine stimulus script properties for a number of recorded cells
%
%   [STIMSCRIPTPROPERTIES, DO] = STIMSCRIPTPROPERTIES(PREFIX, ...
%                CELLS, CELLNAMES, ASSOCIATENAME)
%
%   Examines the stimuli that were used for the cells in the
%   array of MEASUREDDATA objects CELLS that are in the
%   directory described by the associate ASSOCIATENAME.
%   The cell names that correspond to CELLS should be provided
%   in CELLNAMES.  The date from the cell names will be used to
%   identify the appropriate experiment from which to draw the
%   data.
%
%   This function assumes that the raw experimental data is
%   available at PREFIX/EXPERDATE
%
%   STIMSCRIPTPROPERTIES is a cell list of parameters for each
%   stimulus script.  DO is the display order that was used
%   to present the stimuli.
%
%   See also: MEASUREDDATA, ASSOCIATE, FINDASSOCIATE

ssp = {};
do = {};

 % step 1 -  make sure we are in order in case we someday switch to dirstruct loading; this will be fastest
[cellnames,inds] = sort(cellnames);
cells = cells(inds);

 % step 2 - now loop through all of the experiments and cells

lastexperimentname = '';

for i=1:length(cells),
	% do we need a new directory structure?
	%   check date to see if it matches
	underscores = find(cellnames{i}=='_');
	datestr = cellnames{i}(underscores(end-2)+1:end);
	datestr(find(datestr=='_')) = '-';
	if ~strcmp(lastexperimentname,datestr),
		pathname = [prefix filesep datestr];
		if ~exist(pathname),
			error(['Could not find experiment at ' pathname '; is prefix correct?']);
		end;
		lastexperimentname = datestr;
	end;
	% now get the parameters
	assoc = findassociate(cells{i},associatename,'','');
	ssp{i} = {};
	if ~isempty(assoc),
		fullname = [pathname filesep assoc.data filesep 'stims.mat'];
		if exist(fullname)==2,
			mystimscript = load(fullname);
			do{i} = getDisplayOrder(mystimscript.saveScript);
			for j=1:numStims(mystimscript.saveScript),
				mystim = get(mystimscript.saveScript,j);
				ssp{i}{j} = getparameters(mystim);
			end;
		end;
	end;
end;

