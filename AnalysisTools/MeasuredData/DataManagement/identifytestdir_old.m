function [types,data,labeleddirs] = identifytestdir(md,t,ds,nameref,unlabeleddirs)

%  IDENTIFYTESTDIR - Identifies stimulus type in test directory
%
%  [TYPES,DATA,LABELEDDIRS] = IDENTIFYTESTDIR(MD,DIR,DS,NAMEREF,UNLABELEDDIRS)
%
%  IDENTIFTYTESTDIR provides a framework for linking recorded 
%  stimulus scripts with appropriate analyses.  It attempts to
%  identify stimulus scripts present in test directories and
%  provide a label that analysis software can find.
%
%  
%
%  This function first checks for the existence of any
%  user-defined identifytestdir functions.  See
%  IDENTIFYTESTDIRGLOBALS for help in creating such a function.
%  
%  If no user-defined functions can identify the stimulus,
%  then the 
%  
%  
%  This function has been defined to be augmented by user .m files.
%  The global 
%
%  
  
types= {}; data = {}; labeleddirs = {};

theassoc = findassociate(md,'','','');

try,
	stims = load([fixpath(getpathname(ds)) t filesep 'stims.mat'],'-mat');
	script = stims.saveScript;
catch,
	return;  % no stims to label here
end;

%desc = sswhatvaries(script);

identifytestdirglobals;

is_type=0;must_be_unique=1;must_ask=0;

for i=1:length(IDTestDir),
	[is_type,must_be_unique,must_ask,replaceexist,leave_self_unlabeled,leave_others_unlabeled] = feval(IDTestDir(i).function,...
		IDTestDir(i).type,script,md,nameref,t,unlabeleddirs,ds);
	if is_type, break; end;
end;

candidate_dirs = {};

if is_type,
	candidate_dirs = {t};
	ind=i; type=IDTestDir(ind).type;
	% if the measureddata object already has a label then let's not relabel it unless we have to
	if ~isempty(findassociate(md,type,'',''))&~IDreplace&~replaceexist,
		labeleddirs = {t};
		return;
	end;
	for i=1:length(unlabeleddirs), % are there any other candidate directories for this test label?
		otherscript = '';
		try,
			otherstims=load([fixpath(getpathname(ds)) unlabeleddirs{i} filesep 'stims.mat'],'-mat');
			otherscript=otherstims.saveScript;
		catch,

		end;
		if ~isempty(otherscript),
			[is_type2,mbu2,ma2]=feval(IDTestDir(ind).function,type,otherscript,md,nameref,...
				unlabeleddirs{i},setdiff(unlabeleddirs,unlabeleddirs{i}));
			if is_type2, candidate_dirs = cat(1,candidate_dirs,{unlabeleddirs{i}}); end;
		end;
	end;
	% are there any other test labels appropriate for these candidate directories?
	% build a list of candidate_types and preferences
	if (length(candidate_dirs)>1 | must_ask | IDmustask),
		if must_be_unique,
			[s,o]=listdlg('ListString',candidate_dirs,'name',...
				['Select ' type],'SelectionMode','single',...
				'PromptString',['Select unique ' type],...
				'CancelString','None');
		else,
			[s,o]=listdlg('ListString',candidate_dirs,'name',...
				['Select directories for ' type],'SelectionMode','multiple',...
				'PromptString',['Select ' type],...
				'CancelString','None');
		end;
		if isempty(s),
			types{1} = type; data{1} = '';
		else,
			for i=1:length(s),
				types{i}=type;data{i}=candidate_dirs{s(i)};% s will exist but it might be empty
			end;
		end;
		if ~leave_others_unlabeled,
			labeleddirs = candidate_dirs;
		else, labeleddirs = data{i};
		end;
		if leave_self_unlabeled, labeleddirs = setdiff(candidate_dirs,data{i}); end;
	else,
		types{1} = type; data{1} = t;
		if ~leave_others_unlabeled,  % this is not presently relevant
			labeleddirs = candidate_dirs;
		else,
			labeleddirs = candidate_dirs; 
		end;
		if leave_self_unlabeled, labeleddirs = setdiff(candidate_dirs,data{i}); end;
	end;
end;


