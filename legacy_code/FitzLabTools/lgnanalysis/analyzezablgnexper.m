function analyzezablgnexper(pathname, analyze, saveresults, plotit, dbfilename)

%  ANALYZEZABLGNEXPER - Analyze an LGN experiment
%
%  ANALYZEZABLGNEXPER(PATHNAME, ANALYZE, SAVERESULTS, ...
%       PLOTRESULTS, DATABASEFILE)
%
%  This routine reads cells from the experiment at directory location
%  PATHNAME.  If ANALYZE is 1, then the stimulus responses are
%  (re)analyzed.  If SAVERESULTS is 1, then the data are saved back to
%  the experiment's file located at PATHNAME/analysis/experiment.  
%  If PLOTRESULTS is 1, then the results of the analyses are plotted
%  as they are run.  Finally, if DATABASEFILE contains the name of a
%  legal file name, then the user is prompted on a cell-by-cell basis
%  to see if the cell should be added to the database.  If DATABASEFILE
%  is empty then no attempt is made to add to the master database.
%
%  See also:  ANALYZEZABLGNCELL

ds = dirstruct(pathname);

if analyze,
	nr = getallnamerefs(ds); cells = {}; cellnames = {};
	for i=1:length(nr),
		[cells{i},cellnames{i}] = analyzezablgncell(ds,nr.name,nr.ref,1,plotit,saveresults);
	end;
end;

if ~isempty(dbfilename),
	[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');
	for i=1:length(cells),
		s = input(['Should we add ' cellnames{i} ' to the database? (y/n)'],'s');
		if strcmp(s,'y')|strcmp(s,'Y'),
			eval([cellnames{i} '=cells{i};']);
			if exist(dbfilename)==2,
				save(dbfilename,cellnames{i},'-append','-mat');
			else,
				save(dbfilename,cellnames{i},'-mat');
			end;
		end;
	end;
end;
