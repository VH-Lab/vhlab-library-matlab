function [figs,ax] = plotallfits(m,n,cells, cellnames, includefunction, plotfunction)

% PLOTALLFITS - Calls a plot function for all cells in a study
%
%  [FIGS,AX] = PLOTALLFITS(M,N,CELLS,CELLNAMES,INCLUDEFUNCTION,PLOTFUNCTION)
%
%  This function allows the user to examine raw data and fits or index
%  values for all cells in a cell list CELLS with names CELLNAMES.
%
%  The function will create as many figures as needed with M x N plots to
%  show the entire study.  The figures that are created are returned in the
%  list FIGS.  The axes that are created are returned in AX.
%
%  To determine if the cell should be included in the plotting, the function
%  first calls the named function INCLUDEFUNCTION(cells{i},cellnames{i}).
%  This is specified by the user and should return 0 or 1; 0 if the cell should
%  be excluded, and 1 if the cell should be included.  The arguments cells{i} and
%  cellnames{i} are always provided first, but the user can optionally provide additional
%  arguments.  For example, if the user specifies 'myincludefunction(a,b)', then
%  PLOTALLFITS will call 'myincludefunction(cells{i},cellnames{i},a,b)'.
%
%  Next, the function calls PLOTFUNCTION(cells{i},cellnames{i}).  This function
%  should perform all drawing, and may optionally write index values to the plot.
%  Again, the user can specify additional arguments such as 'myplotfunction(a,b,c)'
%  and PLOTALLFITS will call 'MYPLOTFUNCTION(cells{i},cellnames{i},a,b,c)'.
%
%  Generic example:
%           Suppose you have all of your experiments for a study in the directory
%           'C:\mydir' and the experiments are named '2010-01-01','2010-01-02','2010-01-03'
%
%           prefix = 'C:\mydir\'
%           expernames = {'2010-01-01' '2010-01-02' '2010-01-03'};
%           [cells,cellnames] = readcellsfromexperimentlist(prefix,expernames,1);
%           [fix,ax]= plotallfits(cells,cellnames,'myincludefunc','myplotfunc');
%
%  Specific example:
%           prefix = 'Z:\treeshrew_LGNctx\';
%           expernames = {'2008-05-22','2008-05-30','2008-06-05','2008-06-18',...
%                         '2008-06-25','2008-07-10','2008-07-23','2008-08-07',...
%                         '2008-08-14','2008-08-20','2008-09-25','2008-10-14','2008-10-22'};
%           [cells,cellnames] = readcellsfromexperimentlist(prefix,expernames,1);
%           [figs,ax] = plotallfits(6,6,cells,cellnames,...
%		['sfcellinclude(''SP F0 Ach'',1)'],['sfcellplotdog(''SP F0 Ach'',1)']);
%
%
%  For an example INCLUDE function, see SFCELLINCLUDE.  For an example PLOT function see
%  SFCELLPLOTDOG.
%
%  See also: SUBPLOT 

 % first set up function strings to call

inclfunc = '';

z1 = find(includefunction=='(');
if isempty(z1),
	inclfunc = [includefunction '(cells{i},cellnames{i});'];
else,
	inclfunc = [includefunction(1:z1) 'cells{i},cellnames{i},' includefunction(z1+1:end) ';'];
end;

plotfunc = '';

z2 = find(plotfunction=='(');
if isempty(z2),
	plotfunc = [plotfunction '(cells{z(i)},cellnames{z(i)});'];
else,
	plotfunc = [plotfunction(1:z2) 'cells{z(i)},cellnames{z(i)},' plotfunction(z2+1:end) ';'];
end;

 % now figure out which cells out of the total we should include

include = zeros(length(cells),1);

disp(['Checking for inclusion...']);
for i=1:length(cells),
	include(i) = eval(inclfunc);
end;

 % now make the plots

disp(['Now plotting...']);

z = find(include);

figs = [];
ax = [];

for i=1:length(z),
	if (mod(i-1,n*m)==0), figs(end+1) = figure; end; % make a new figure if needed

	p = mod(i-1,n*m)+1;
	ax(end+1) = subplot(m,n,p);
	eval(plotfunc);
end;

