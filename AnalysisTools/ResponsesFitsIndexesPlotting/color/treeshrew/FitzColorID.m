function [id,str,plotcolor,longname] = FitzColorID(col1,col2,tol)

%  FitzColorID -- Determine identify of color, if any
%
%  [ID,STR,PLOTCOLOR,LONGNAME] = FitzColorStimID(col1,col2,tolerance)
%
%  Examines the color pair col1 and col2 and determines if
%  they correspond to any known type, within a total error
%  tolerance of TOLERANCE color values.
%
%  COL1 = [ R1 G1 B1], COL2 = [ R2 G2 B2], where R, G, and B values
%  range from 0..255.
%
%  If the color ID is unknown, then ID is 0, and STR, PLOTCOLOR, and
%  LONGNAME are empty.
%
%  If the function is called with no arguments, then ID is an array of
%  all known IDs, STR is a cell list of all strings, and LONGNAME is a
%  cell list of all long names.
%
%  Known types:
%  [col1;col2]                ID    STR        LONGNAME
%  [255 255 255;0 0 0]         1    'Ach'      Achromatic
%  [128 153 41;128 102 214]    2    'L'        Tree shrew L-cone isolating
%  [128 103 230;128 152 26]    3    'S'        Tree shrew S-cone isolating
%  [91 55 222;91 113 12]       3    'S'        Tree shrew S-cone isolating
%  (if unknown)                0    ''         Unknown

strs = {'','Ach','L','S'};
longnames = {'Unknown','Achromatic','Tree shrew L-cone isolating','Tree shrew S-cone isolating'};
plotcolors = [0 0 0 ; 0 0 0; 0 1 0; 0 0 1];

if nargin==0,
	str = strs; longname = longnames; id = 0:3; plotcolor = plotcolors;
	return;
end;

id = 0;

Ach = [ 255 255 255;   0   0   0];
L =   [ 128 153  41; 128 102 214];
S =   [ 128 103 230; 128 152  26];
S2=   [  91 55  222;  91 113  12];
S3 =   [ 128 152  26; 128 103 230];

if size(col1,1)>size(col1,2), col1 = col1'; end;
if size(col2,1)>size(col2,2), col2 = col2'; end;

col = [col1 ; col2];
id = 1*(coldiff(Ach,col)<10) + 2*(coldiff(L,col)<10) + 3*(coldiff(S,col)<10)+3*(coldiff(S2,col)<10)+3*(coldiff(S3,col)<10);

if id>=1,
	str = strs{id}; longname = longnames{id}; plotcolor = plotcolors(id,:);
else,
	str = ''; longname = ''; plotcolor = [ 0 0 0];
end;
	
function df = coldiff(x1,x2)
df = (sum(sum(abs(x1-x2))));