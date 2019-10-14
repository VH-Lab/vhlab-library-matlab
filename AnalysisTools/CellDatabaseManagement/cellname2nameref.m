function [nameref,index,datestr] = cellname2nameref(cellname)
% CELLNAME2NAMEREF - Converts a VHLab cellname to a CKSDIRSTRUCT name/ref
%
%    [NAMEREF,INDEX,DATESTR] = CELLNAME2NAMEREF(CELLNAME)
%
%   Converts a cellname to a name/ref pair.  The cell's index number is also
%   returned, as is the trailing date string.
%
%   Example:
%    [nameref,index] = cellname2nameref('cell_ctx_0003_001_2003_05_27') returns
%        nameref = struct('name','ctx','ref',3);
%        index = 1;
%
%
%   See also: NAMEREF2CELLNAME, CELLNAME2DATE

m = find(cellname=='_')
nameref = struct('name',cellname(m(1)+1:m(end-5)-1), ...
	'ref',round(str2num(cellname(m(end-4)+1:m(end-3)-1))));

index = round(str2num(cellname(m(end-3)+1:m(end-2)-1)));

datestr = cellname(m(end-2)+1:end);
