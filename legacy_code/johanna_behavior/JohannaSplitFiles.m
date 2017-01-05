function JohannaSplitFiles(filename, number)
% JOHANNASPLITFILES - SPLIT FILES INTO 2 BY CHANNELS
%
%  JOHANNASPLITFILES(FILENAME, NUMBER)
%
%  Splits Johanna's data files into 2 files by splitting
%  the channels into 2 groups. Channels NUMBER and higher
%  are split into the second file. The new file names are
%  [FILENAME 'N1.mat'] and [FILENAME 'N2.mat'].
%
%  Example:
%     JohannaSplitFiles('Ferret#1258_Day1', 9);
%
%     Writes 2 files 'Ferret#1258_Day1N1.mat' and 
%     'Ferret#1258_Day1N2.mat', with spike channels
%     sigX[a-z] going to the first file (X less than
%     9) and spike channels sigY[a-z] going to the second
%     file (Y greater than or equal to 9).
%  
%
%  See also: JOHANNADATA2SPIKESBINS

load([filename '.mat']);
for i=0:number-1,
	eval(['clear sig' sprintf('%.3d',i) '*']);
end;
vars=whos;
varnames_to_save = setdiff({vars.name},{'vars','filename','number','i','ans'});
save([filename 'N2.mat'],varnames_to_save{:},'-mat');


load([filename '.mat']);
for i=number:number+40,
	eval(['clear sig' sprintf('%.3d',i) '*']);
end;
vars=whos;
varnames_to_save = setdiff({vars.name},{'vars','filename','number','i','ans','varnames_to_save'});
save([filename 'N1.mat'],varnames_to_save{:},'-mat');

