function [respstructlist, testdirlist, paramlist] = testnamelist2respstruct(cell, testnamelist, f0orf1)
% TESTNAMELIST2RESPSTRUCT - load response structures from 'STR test' associates
%
% [RESPSTRUCTLIST, TESTDIRLIST, PARAMLIST] = TESTNAMELIST2RESPSTRUCT(CELL, ...
%    TESTNAMELIST, F0_OR_F1_OR_F2)
%
% Given a CELL (MEASUREDDATA object) and a cell array of TESTNAMELIST of 
% stimuus testdirlist in the form "TESTNAME test" (such as 'orientation test'),
% this function loads the directory name of where the test occurred and
% converts the 'resp' structure (in the associate 'TESTNAME resp', e.g.,
% 'orientation resp') to the format needed for analysis routines such as
% OTANALYSIS_COMPUTE.
%
%  F0_OR_F1_OR_F2 should be 0 if the mean firing rate is to be used, 1 if
%    the F1 component is to be analyzed, or 2 is F2 is to be analyzed.
%
% RESPSTRUCT is a structure  of response properties with fields:
%  curve    |    4xnumber of directions tested,
%           |      curve(1,:) is directions tested (degrees, compass coords.)
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each direction
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blankresp|    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
% If there is an associate "TESTNAME params" of the same form associated with
% CELL, then this is returned in PARAMLIST. If no such entry exists, then
% EMPTY is returned in PARAMLIST for that entry in TESTNAMELIST.


testdirlist = {};
respstructlist = {};
paramlist = {};

   % note 1: pull this out to another function
for j=1:length(testnamelist),
	s = findstr(upper(testnamelist{j}),' TEST');
	tas = findassociate(cell, testnamelist{j},'','');
	thetestnamepart = testnamelist{j}(1:s-1);
	paramshere = [];
	if ~isempty(tas) & was_recorded(cell,thetestnamepart),
		if ~isempty(s),
			resname = [testnamelist{j}(1:s) 'resp'];
			res = findassociate(cell, resname,'','');
			testdirname = tas.data;
			paramshere = findassociate(cell, [testnamelist{j}(1:s) 'params'], '', '');
			if ~isempty(paramshere),
				paramshere = paramshere.data;
			end
		else,
			res = tas;
			testdirname = 'N/A';
		end;
	        if isempty(res),
			cellname, s, keyboard;
		elseif ~isempty(res)&isfield(res.data,'f0curve')&(f0orf1==0),
			res.data.curve = res.data.f0curve{1};
			X = res.data.f0vals{1};
			res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
		elseif f0orf1==1&~isfield(res.data,'f1curve'),
			error(['F1 analysis requested but no F1 data for cell ' cellname ' for test ' testnamelist{j} '.']);
		elseif isfield(res.data,'f1curve')&(f0orf1==1),
			res.data.curve = res.data.f1curve{1};
			X = abs(res.data.f1vals{1});
			res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
		elseif isfield(res.data,'f2curve')&(f0orf1==2),
			res.data.curve = res.data.f2curve{1};
			X = abs(res.data.f2vals{1});
			res.data.ind = mat2cell(X,size(X,1),ones(1,size(X,2)));
		elseif f0orf1==2&~isfield(res.data,'f2curve'),
			error(['F2 analysis requested but no F2 data for cell ' cellname ' for test ' testnamelist{j} '.']);
		end;
		if isfield(res.data,'blank'),
			if ~isempty(res.data.blank(1))&isfield(res.data.blank(1),'f0curve')&(f0orf1==0),
				res.data.blankresp = res.data.blank(1).f0curve{1}(2:4,1);
				X = res.data.blank(1).f0vals{1};
				res.data.blankind = X;
			elseif f0orf1==1&~isfield(res.data.blank(1),'f1curve'),
				error(['F1 analysis requested but no F1 blank data for cell ' cellname ' for test ' testnamelist{j} '.']);
			elseif isfield(res.data.blank(1),'f1curve')&(f0orf1==1),
				res.data.blankresp = res.data.blank(1).f1curve{1}(2:4,1);
				X = abs(res.data.blank(1).f1vals{1});
				res.data.blankind = X;
			elseif isfield(res.data.blank(1),'f2curve')&(f0orf1==2),
				res.data.blankresp = res.data.blank(1).f2curve{1}(2:4,1);
				X = abs(res.data.blank(1).f2vals{1});
				res.data.blankind = X;
			elseif f0orf1==2&~isfield(res.data.blank(1),'f2curve'),
				error(['F2 analysis requested but no F2 data for cell ' cellname ' for test ' testnamelist{j} '.']);
			end;
		end;
		testdirlist = cat(2,testdirlist,testdirname);
		respstructlist = cat(2,respstructlist,res.data);
		paramlist = cat(2,paramlist,{paramshere});
	end;
end;

 % eliminate any duplicate directories
[testdirlist,I] = unique(testdirlist);
if ~isempty(respstructlist),
	respstructlist = respstructlist(I);
	paramlist = paramlist(I);
end;

 % eliminate any empty responses
I = [];
for j=1:length(respstructlist),
	if ~isempty(respstructlist{j}),
		I(end+1)=j;
	end;
end;
testdirlist = testdirlist(I);
respstructlist = respstructlist(I);
paramlist = paramlist(I);

