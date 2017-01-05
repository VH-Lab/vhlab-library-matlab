function rd = standardize_depth(cell, standard_layer4_borders)

% STANDARDIZE_DEPTH - Project a cell's depth onto a "standardized" cortex
%
%   S_DEPTH = STANDARDIZE_DEPTH(CELL, STANDARD_LAYER4_BORDERS)
%
%  This function projects a cell onto a "standardized" cortex based
%  on the cell's recorded depth and the determined beginning and
%  end of layer 4 as determined by the experimenter.  
%
%  The beginning and end depth of layer 4 should be in a
%  'Layer 4 border depths' associate in CELL.  This data in this associate
%  can either be a [1x2] vector that describes the [TOP BOTTOM] of 
%  layer 4 in microns, or a [1x3] vector that describes [SURFACE TOP BOTTOM]
%  in microns.
%  
%  The cell's depth is stretched so it matches a standard cortex with the
%  layer 4 top and bottom as specified in STANDARD_LAYER4_BORDERS (a 
%  1x2 vector describing the [TOP BOTTOM] boundaries of layer 4 (in microns).
%   

A1=findassociate(cell,'depth','','');
A2=findassociate(cell,'Layer 4 border depths','','');

rd = [];

if ~isempty(A1)&~isempty(A2),
    depth = A1.data;
    if ischar(depth), depth = str2nume(depth); end;
    if length(A2.data)==2,
        rd = fix(rescale(depth,A2.data,standard_layer4_borders,1));
    elseif length(A2.data)==3,
        if depth>A2.data(3),
            rd = fix(rescale(depth,A2.data(2:3),standard_layer4_borders,1));   
        else, rd = fix(interp1(A2.data,[0 standard_layer4_borders],depth,'linear'));
        end;
    end;
end;

