function remove_associate(ds, type)
% REMOVE_ASSOCIATE - Remove an associate from all experiment variables in a dirstruct
%
%  REMOVE_ASSOCIATE(DS, TYPE)
%
%  Removes the associate with type TYPE from all experiment variables
%  in the dirstruct DS. If any changes are made, then the experiment variables
%  are saved back to disk.
% 

[vars,varnames]=load2celllist(getexperimentfile(ds),'*','-mat');

changemade = 0;

for i=1:length(vars),
	if isa(vars{i},'measureddata'),
		[a,i]=findassociate(vars{i},type,'','');
		if ~isempty(a),
			vars{i} = disassociate(vars{i},i);
			changesmade = 1;
		end;
	end;
end;

if changesmade,
	saveexpvar(ds,vars,varnames);
end;


