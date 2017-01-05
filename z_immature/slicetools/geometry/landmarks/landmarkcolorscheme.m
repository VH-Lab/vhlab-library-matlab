function lmcs = landmarkcolorscheme(oldlmcs, doedit);

if nargin<1|isempty(oldlmcs),
	lmcs.selectcolor = [1 1 0];
	lmcs.selectmarker = '.';
	lmcs.selectmarkersize = 6;
	lmcs.selectlinestyle = '-';

	lmcs.homecfcolor = [0 0 1];
	lmcs.homecfmarker = '.';
	lmcs.homecfmarkersize = 6;
	lmcs.homecflinestyle = '-';

	lmcs.projectcfcolor = [1 0 0];
	lmcs.projectcfmarker = 'o';
	lmcs.projectcfmarkersize = 6;
	lmcs.projectcflinestyle = '-';

	lmcs.customlabel = '';
	lmcs.customlabelappend = '';
	lmcs.showlabel = 0;
	lmcs.labeloffset = [0 0];
else, lmcs = oldlmcs;
end;

if nargin>1&doedit,
	name = 'Landmark color scheme: ';
	prompt = fieldnames(lmcs);
	numlist = [];
	for i=1:length(prompt),
		val = getfield(lmcs,prompt{i});
		if ischar(val),
			defaultanswer{i} = val;
		else,
			defaultanswer{i} = mat2str(val);
			numlist(end+1) = i;
		end;
	end;
	answer = inputdlg(prompt,name,1,defaultanswer);
	if ~isempty(answer),
		for i=1:length(prompt),
			val = answer{i};
			if ~isempty(intersect(i,numlist)), val = str2num(val); end;
			lmcs=setfield(lmcs,prompt{i},val);
		end;
	end;
end;

