function [newcells,newassoc,assocind,outstr]=tpmulticellresponseanalysis(dirname,param,assocname,cells,cellnames,ds,display)

% TPMULTICELLRESPONSEANALYSIS - Computes responses from two-photon raw data
%
%  [NEWCELLS,ASSOCS]=TPMULTICELLRESPONSEANALYSIS(DIRNAME,PARAM,ASSOCNAME,...
%			CELLS,CELLNAMES,DS,DISPLAY)
%
%
needtorun = 1;
resps = [];

newcells = cells;
newassoc = myassoc(assocname,'');
newassoc = newassoc([]);
assocind = [];
outstr = '';

if isempty(dirname), return; end;

  % first look for an analyzetpstack record to see if we can avoid running the data

cellpixels = {};
for i=1:length(cells),
	try, cellpixels{i} = getfield(findassociate(cells{i},'pixelinds','',''),'data');
	catch, error(['Could not find pixel indices for cell ' cellnames{i} '.']);
	end;
end;

assoc = findassociate(cells{1},'analyzetpstack name','','');

  % not having resps is not an error anymore
 
if ~isempty(assoc),
	stillgood = 1;
	% open stimulus directory and see what varied
	try, 
		g = analyzetpstack_loadsavedfile(ds,assoc.data,dirname);
	catch, g.empty = 1;
	end;
	if exist(analyzetpstack_getrawfilename(ds,assoc.data,dirname))
		z = analyzetpstack_loadrawfile(ds,assoc.data,dirname);
	else, z = [];
	end;
	if isfield(g,'paramname'),
		if (~strcmp(g.paramname,param)&~isempty(param)), stillgood = 0; end;
	end;
	if isfield(g,'empty')&isempty(z), stillgood = 0; end;
	if stillgood, %&length(cells)<=length(g.listofcells),
		needtorun = 0;
		if ~isfield(g,'empty'), resps = g.resps; end;
		%for i=1:length(cells),
		%	if ~eqlen(cellpixels{i},g.listofcells{i}),
		%		needtorun = 1;
		%	end;
		%end;
	end;
end;

if needtorun,
	if 1,
		warning(['Could not find appropriate analyzed data for ' dirname '; data not included.']);
	else,
		dirname,
		fulldirname = [fixpath(getpathname(ds)) dirname];
		resps = prairieviewtuningcurve(fulldirname,param,cellpixels,display,cellnames);
	end;
end;

if ~isempty(resps)|~isempty(z),
	INDs = [];
	for i=1:length(z.listofcellnames),
		sp = find(z.listofcellnames{i}==' ');
		INDs(i) = str2num(z.listofcellnames{i}(sp(1)+1:sp(2)-1));
	end;
	for i=1:length(cells),
		inds_ = find(cellnames{i}=='_'); indx = str2num(cellnames{i}(inds_(3)+1:inds_(4)-1));
		myind = find(INDs==indx);
		if ~isempty(myind),
			if ~isempty(resps),
				newassoc(end+1) = myassoc(assocname,resps(myind));
				assocind(end+1) = i;
				newcells{i}=associate(newcells{i},newassoc(end));
			end;
			if ~isempty(z),
				newassoc(end+1)=myassoc([assocname ' raw'],struct('data',z.data{myind},'t',z.t{myind}));
				assocind(end+1) = i;
				newcells{i}=associate(newcells{i},newassoc(end));
			end;
		end;
	end;
end;

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

