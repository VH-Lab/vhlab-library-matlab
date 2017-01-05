function [good,errormsg] = verifyparameters(p,inputs)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'res','showrast','interp','drawspont'};
        fieldSizes = {[1 1],[1 1],[1 1],[1 1]};
        [proceed,errormsg] = hasAllFields(p, fieldNames, fieldSizes);
end;

if proceed,
	if p.res<=0,proceed=0;errormsg='res must be >0.'; end;
        fieldNames = {'showrast','drawspont'};
	for i=1:length(fieldNames),
		eval(['if ~isboolean(p.' fieldNames{i} '),proceed=0;' ...
		   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
	end;
	if p.interp<=0,proceed=0;errormsg='interp must be >0.';end;
end;

good = proceed;
