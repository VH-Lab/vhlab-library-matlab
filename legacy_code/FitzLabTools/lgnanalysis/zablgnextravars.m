function zablgnextravars(ds, name, ref, index)

% ZABLGNEXTRAVARS - Extra variables for shrew lgn experiment
%
%  ZABLGNEXTRAVARS(DS, NAME, REF, INDEX)
%
%  Asks the user for input about variables to assiociate with an
%  extracellular recording in tree shrew LGN.
%
%  


r = input('Is the cell ipsi (0) or contra (1)?');
assoclist=struct('type','contra','owner','','data',r,'desc','');

r = input('What is the LGN Layer?');
assoclist=[assoclist struct('type','LGN layer','owner','','data',r,'desc','')];

r = input('What is the recording depth, in um?');
assoclist=[assoclist struct('type','depth','owner','','data',r,'desc','')];

r = input('What is the tree shrew number, excluding the string TS?');
assoclist=[assoclist struct('type','tree shrew number','owner','','data',r,'desc','')];

r = input('What is cell isolation quality? (0=multiunit, 1=decent, 2=excellent):');
assoclist=[assoclist struct('type','isolation','owner','','data',r,'desc','')];

s = input('Enter any notes and press return: ','s');
assoclist=[assoclist struct('type','notes','owner','','data',s,'desc','')];

save([getscratchdirectory(ds,1) filesep 'EXTRAINFO_' name '_' int2str(ref) '_' int2str(index) '.mat'],'assoclist');
