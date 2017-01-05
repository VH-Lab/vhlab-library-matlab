function [cell, cellname] = analyzezablgncell(ds, name, ref, index, plot, save)


 % first, load the spike times from disk
[cell,cellname] = vhspike2_loadcell(ds,name,ref,index);

 % now get a list of all test directories that contain recordings for this cell
T = gettests(ds, name, ref);

 % now loop over the test directories, analyzing each one w/ the appropriate function
for t = 1:length(T),

	% open the stimulus file and get the script
	mystims = load([getpathname(ds) filesep T{t} filesep 'stims.mat'],'-mat');
	myscript = mystims.saveScript;

	 %use the script to determine the stimulus that was shown
	if strcmp( class(get(myscript,1)),'centersurroundstim' ),
		% if a spot stim, use parameters to figure out which one was shown
		thestim = get(myscript,1);
		ps = getparameters(thestim);
		NBstr = '';
		% was it a neutral background?
		if ~eqlen(ps.BG,ps.FGs), NBstr = 'NB '; end;
		% now identify the center to make the associate name
		ps.FGc,
		if eqlen(ps.FGc,[255 255 255]), spotstr = ['W '];
		elseif eqlen(ps.FGc,[0 0 0]), spotstr = ['B '];
		elseif eqlen(ps.FGc,[91 55 222]), spotstr = ['S+ ']; 
		elseif eqlen(ps.FGc,[91 113 12]),spotstr = ['S- '];
		elseif eqlen(ps.FGc,[1 2 3]), spotstr = ['M+ '];
		elseif eqlen(ps.FGc,[2 3 4]), spotstr = ['M- '];
		end;
		testname = ['Spot ' spotstr NBstr 'test'],
		% now let's check to make sure test isn't already registered
		A = findassociate(cell,testname,'','');
		if ~isempty(A),
			warning(['Multiple ' testname ', using most recent ' T{t} '.']);
		end;
		cell = associate(cell,testname,'',T{t},'');
		% do the analysis at the end after all spot stims have been identified
	else,
		ss = sswhatvaries(myscript);
		% if chromhigh and chromlow vary, assume it is color exchange
		if ~isempty(intersect(ss,'chromhigh'))&~isempty(intersect(ss,'chromlow')),
			% check for previous tests and give warning
			A=findassociate(cell,'Color Exchange test','','');
			if ~isempty(A),
				warning(['Multiple Color Exchange tests, using most recent ' T{t} '.']);
			end;
			% now set the Color Exchange test to the current variable and do the analysis
			cell = associate(cell, 'Color Exchange test','',T{t},'');
			%cell = analyzesingleunitcolorexchange(ds, cell, cellname, plot);
		% if tFrequency varies, assume it is a temporal frequency test
		elseif ~isempty(intersect(ss,{'tFrequency'})),
			% check for previous tests and give warning
			A=findassociate(cell,'TF test','','');
			if ~isempty(A),
				warning(['Multiple TF tests, using most recent ' T{t} '.']);
			end;
			% now set the test to the current variable and do the analysis
			cell = associate(cell, 'TF test','',T{t},'');
			cell = analyzesingleunittf(ds, cell, cellname, plot);
		end;
	end;
end;

 % now that all spot stims have been registered as associates, do the analysis
cell = analyzelgnspotstims(ds, cell, cellname, plot);


% if any extra variables have been associated w/ cell, then include them
extravarfilename=[getscratchdirectory(ds) filesep 'EXTRAINFO_' name '_' int2str(ref) '_' int2str(index) '.mat'];
if exist(extravarfilename),
	g = load(extravarfilename);
	assoclist = g.assoclist;
	for i=1:length(assoclist), cell = associate(cell,assoclist(i)); end;
end;

if save, saveexpvar(ds, cell, cellname, 0); end;  % save the cell variable if user asks us
