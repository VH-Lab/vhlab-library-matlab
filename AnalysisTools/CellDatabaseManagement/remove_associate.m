function remove_associate(ds, type)
% REMOVE_ASSOCIATE - Remove an associate from all experiment variables in a dirstruct
%
%  REMOVE_ASSOCIATE(DS, TYPE)
%
%  Removes the associate with type TYPE from all experiment variables
%  in the dirstruct DS. If any changes are made, then the experiment variables
%  are saved back to disk.
%
%  TYPE may be a single string or a cell array of strings, if more than one 
%  associate type is to be removed.
%
%  See also: ASSOCIATE, SAVEEXPVAR
% 

[vars,varnames]=load2celllist(getexperimentfile(ds),'*','-mat');

changemade = 0;

if isa(char,type),
	type = {type};
end;

for i=1:length(vars),
	if isa(vars{i},'measureddata'),
		for j=1:length(type),
			[a,i]=findassociate(vars{i},type{j},'','');
			if ~isempty(a),
				vars{i} = disassociate(vars{i},i);
				changesmade = 1;
			end;
		end;
	end;
end;

if changesmade,
	saveexpvar(ds,vars,varnames);
end;


