function [T, STARTTIME] = findtransitionsSGSBL(dirname, colors_from, colors_to, varargin)
%  FINDTRANSITIONSSGSBL - Find transitions between colors for STOCHASTICGRIDSTIM or BLINKINGSTIM
%
%   [T,STARTTIME] = FINDTRANSITIONSSGSBL(DIRNAME, COLORS_FROM, COLORS_TO, ...)
%
%   Finds all occurances of transitions from any color listed in a matrix COLORS_FROM to
%   any color listed in a matrix COLORS_TO. Each row of COLORS_FROM and COLORS_TO should have 
%   an RGB triplet corresponding to a color (with RGB values ranging from 0..255).
%
%   The stimulus script in directory DIRNAME is examined and its time is corrected based on
%   the actual presentation times recorded in STIMS.mat. Any synchronization method is applied.
%
%   T{i} is the time of all transitions for grid number i. STARTTIME is the time of the start of
%   the acquisition run for DIRNAME in global (stimulus computer) time.
%
%   This functional also can take additional name/value pairs to modify the behavior:
%   Parameter (default)             | Description
%   ----------------------------------------------------------------------------------------
%   PerformErrorChecking (1)        | Check to make sure all stims in the script have the same
%                                   |   grid dimensions and that they are all STOCHASTICGRIDSTIM types or
%                                   |   BLINKINGSTIM types (mixing is okay as long as dimensions are the same).
%   ColorTolerance (1)              | How close the colors must be to be considered a match (Euclidean RGB
%                                   |   distance in RGB space).
%   ReturnGlobalTime (0)            | Return T in units of global (stimulus computer) clock time. Default is to
%                                   |   return time relative to acquisition in DIRNAME (local time).
%   
%   See also: STOCHASTICGRIDSTIM/FINDTRANSITIONS BLINKINGSTIM/FINDTRANSITIONS
%

PerformErrorChecking = 1;
ColorTolerance = 1;
ReturnGlobalTime = 0;

assign(varargin{:});

[s,mti,startTime]=getstimscriptsync(dirname,0);
do = getDisplayOrder(s);
N = numStims(s);

master_p = [];
F = {};

for i=1:N,
	stim = get(s,i);
	if PerformErrorChecking,
		if ~(isa(stim,'blinkingstim') | isa(stim,'stochasticgridstim')),
			error(['Stims must be of type stochasticgridstim or blinkingstim.']);
		end;
		p = getparameters(stim);
        [grid.x,grid.y,grid.rect] = getgrid(stim);
		if i==1,
			master_p.rect = p.rect;
			master_p.pixSize = p.pixSize;
            master_p.grid = grid;
		else,
			local_p.rect = p.rect;
			local_p.pixSize = p.pixSize;
            local_p.grid = grid;
			if ~eqlen(local_p,master_p),
				error(['All stim types within the script must have the same dimensions (rect and pixSize parameters) for this function to be able analyze it.']);
			end;
		end;
	end;
	F{i} = findtransitions(stim,colors_from,colors_to,ColorTolerance);
end;

T = cell(size(F{1})); % create empty entries

for i=1:length(do),
	stimid = do(i);
	for j=1:length(F{stimid}), % for each grid number, find the transitions that match
		T{j} = [T{j}; mti{i}.frameTimes(F{i}{j})'];
	end;
end;

if ~ReturnGlobalTime,
	for j=1:length(T),
		T{j} = T{j} - startTime;
	end;
end;

