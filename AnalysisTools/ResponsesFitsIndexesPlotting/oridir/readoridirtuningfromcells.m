function [oi,di,depth,putativelayer,cv,f1f0,cellnamelist, sigorientation, inds, blanks, maxrates, coeffvars, prefs, nulls, orths] = readoridirtuningfromcells(cells,cellnames)

  % loop through all cells

oi = []; di = []; putativelayer = []; cv = []; f1f0 = []; depth = []; sigorientation = [];
inds = [];
cellnamelist = {};

blanks = []; maxrates = []; coeffvars = [];

prefs = []; nulls = []; orths = [];

    % loop through all cells
for j=1:length(cells), 
	[f1f0c,dirprefc,oiindc,tunewidthc,cvc,dic,sigorientationc, blankrate, maxrate, coeffvar, pref, null, orth] = extract_oridir_indexes(cells{j});
	if ~isempty(f1f0c),
		putativelayer_c = tscelllayer(cells{j});
	end;
	depth_assoc = findassociate(cells{j},'depth','','');

	if ~isempty(f1f0c)&~isempty(depth_assoc),
		inds(end+1) = j;
		oi(end+1) = oiindc;
		di(end+1) = dic;
		f1f0(end+1) = f1f0c;
        blanks(end+1) = blankrate;
        maxrates(end+1) = maxrate;
        coeffvars(end+1) = coeffvar;
        prefs(end+1) = pref;
        nulls(end+1) = null;
        orths(end+1) = orth;
	if ~isempty(putativelayer_c),
		putativelayer(end+1) = putativelayer_c;
	else,
		putativelayer(end+1) = NaN;
	end;
		depth(end+1) = depth_assoc.data;
		sigorientation(end+1) = sigorientationc;
		cv(end+1) = cvc;
       	cellnamelist{end+1} = cellnames{j};
	end;
end;


