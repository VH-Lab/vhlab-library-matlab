function datestr = cellname2date(cellname)
% CELLNAME2DATE - Converts a VHLAB cellname to a date string
%
%    NAMEREF = CELLNAME2DATE(CELLNAME)
%
%   Converts a cellname to a name/ref pair.
%
%   Example:
%    cellname2nameref('cell_ctx_0003_001_2003_05_27') returns
%        '2003-05-27'
%
%   See also: CELLNAME2NAMEREF, NAMEREF2CELLNAME

m = find(cellname=='_');
datestr = [cellname(m(4)+1:m(5)-1) '-' cellname(m(5)+1:m(6)-1) '-' cellname(m(6)+1:end)];

		
