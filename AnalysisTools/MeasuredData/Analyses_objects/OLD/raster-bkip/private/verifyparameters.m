function [good,errormsg] = verifyparameters(p)

proceed = 1;
errormsg = '';

if proceed,
        % check that all arguments are present and appropriately sized
        fieldNames = {'res','interval','fracpsth','normpsth',...
		'showvar','psthmode','showfrac','cinterval','showcbars'};
        fieldSizes = {[1 1],[1 2],[1 1],[1 1],[1 1],[1 1],[1 1],[1 2],[1 1]};
        [proceed,errormsg] = hasAllFields(p, fieldNames, fieldSizes);
end;

if proceed,
	mi=min(p.interval);mx=max(p.interval);
	cmi=min(p.cinterval);cmx=max(p.cinterval);
	if cmi<mi|cmx>mx,
		proceed=0;errormsg='cinterval must be in interval.';
	end;
	if p.res<=0,proceed=0;errormsg='res must be >0.'; end;
        fieldNames = {'normpsth','showvar','psthmode','showcbars'};
	for i=1:length(fieldNames),
		eval(['if ~isboolean(p.' fieldNames{i} '),proceed=0;' ...
		   'errormsg=''' fieldNames{i} ' must be 0 or 1.''; end;']);
	end;
	if p.fracpsth>1|p.fracpsth<0,proceed=0;errormsg='fracpsth not in 0..1.';
        end;
	if p.showfrac>1|p.showfrac<0,proceed=0;errormsg='showfrac not in 0..1.';
        end;
end;

good = proceed;
