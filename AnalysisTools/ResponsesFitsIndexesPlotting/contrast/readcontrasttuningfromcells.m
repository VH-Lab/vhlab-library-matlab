function [rmg,c50,si,depth,putativelayer,f1f0,cellnamelist, inds, sigcontrast] = readcontrasttuningfromcells(cells,cellnames)

  % loop through all cells

rmg = []; c50 = []; putativelayer = []; si = []; f1f0 = []; depth = []; sigcontrast = [];
inds = [];
cellnamelist = {};

% loop through all cells
for j=1:length(cells), 
	[f1f0c,rmg_,c50_,si_,sig_ct_] = extract_contrast_indexes(cells{j});
	if ~isempty(f1f0c),
		putativelayer_c = tscelllayer(cells{j});
	end;
	depth_assoc = findassociate(cells{j},'depth','','');

	if ~isempty(f1f0c)&~isempty(depth_assoc),
		inds(end+1) = j;
		c50(end+1) = c50_;
		rmg(end+1) = rmg_;
		si(end+1) = si_;
		f1f0(end+1) = f1f0c;
		if ~isempty(putativelayer_c),
			putativelayer(end+1) = putativelayer_c;
		else,
			putativelayer(end+1) = NaN;
		end;
		depth(end+1) = depth_assoc.data;
		sigcontrast(end+1) = sig_ct_;
		cellnamelist{end+1} = cellnames{j};
	end;
end;


