function sfcellplotdog(cell,cellname, assoc_prefix, check_simple_complex)
% SFCELLPLOT - Examine a cell's spatial frequency fit and plot
%
%  SFCELLPLOTDOG(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Plots the DOG fit for spatial frequency, along with mean responses
%  and error bars.  Also shows LOW/HIGH cut-offs for DOG in blue, and
%  LOW/HIGH cut-offs based on interpolation of the raw data in red.

cols = ['rrrbbb']; % colors

assoc_name{1} = ['CONT Ach OT Carandini Fit'];
assoc_name{2} = ['CONT Ach OT Response curve'];
assoc_name{3} = ['CONT Ach OT Blank Response'];

l = length(assoc_name); % current length of assoc_name

for i=1:l, assoc_name{end+1} = strrep(assoc_name{i},'CONT','IPSI'); end

if check_simple_complex,
        f1_f0f1 = extract_oridir_indexes(cell);
        if ~isempty(f1_f0f1),
                if 2*f1_f0f1>=1,
                        F0 = findstr(assoc_prefix,'F0');
                        assoc_prefix(F0:F0+1) = 'F1';
                end;
        end;
end;

for i=1:length(assoc_name),
	A{i} = findassociate(cell,[assoc_prefix ' ' assoc_name{i}],'','');
end;

hold off;

 % plot the fit

for i=[1 1+3],
	plot(A{i}.data(1,:),A{i}.data(2,:),cols(i));
	hold on;
end;

 % plot the raw data
for i=[2 2+3],
	h = myerrorbar(A{i}.data(1,:),A{i}.data(2,:),A{i}.data(4,:),cols(i));
	delete(h(2)); % remove the line
end;

 % now plot blanks
for i=[3 3+3],
	plot([0 360],A{i}.data(1)*[1 1],[cols(i) '--'],'linewidth',0.6);
end;


title(cellname,'interp','none');

[odi,cl,il] = odicell(cell,assoc_prefix);

matchaxes(gca,0,360,'axis','axis');
h = autoplacetext({  ['odi=' num2str(odi,2)],  ['cl=' num2str(cl,2)],  ['il=' num2str(il,2)]   });


box off;
