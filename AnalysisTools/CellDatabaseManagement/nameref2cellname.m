function cellname = nameref2cellname(ds, name, ref, index)

% NAMEREF2CELLNAME - Produces string of cell name given name/ref
%
%   CELLNAME = NAMEREF2CELLNAME(DS, NAME, REF, INDEX)
%
% Produces an appropriate cell name given DIRSTRUCT DS, 
% reference name REF and reference number REF and cell
% index INDEX.
%
% Example, if pathname for DS is '2006-10-05', and
% NAME = 'lgn' and REF = 4 and INDEX = 1, then the
% returned name is cell_lgn_004_001_2006_10_12
%



[dirname,datestr] = fileparts(getpathname(ds));

if isempty(datestr), [dirname,datestr] = fileparts(dirname); end;

sp = find(datestr=='-');
if length(sp)~=2, error(['Can''t extract date string for naming cell...too many dashes.']); end;

datestr = [datestr(sp(1)-4:sp(1)-1) '_' datestr(sp(1)+1:sp(2)-1) '_' datestr(sp(2)+1:sp(2)+2)];

cellname=['cell_' name '_' sprintf('%.3d',ref) '_' sprintf('%.3d',index) '_' datestr];

