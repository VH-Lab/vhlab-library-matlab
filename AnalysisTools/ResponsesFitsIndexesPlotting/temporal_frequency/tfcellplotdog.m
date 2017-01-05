function tfcellplotdog(cell,cellname, assoc_prefix, check_simple_complex)
% TFCELLPLOT - Examine a cell's temporal frequency fit and plot
%
%  TFCELLPLOTDOG(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Plots the DOG fit for temporal frequency, along with mean responses
%  and error bars.  Also shows LOW/HIGH cut-offs for DOG in blue, and
%  LOW/HIGH cut-offs based on interpolation of the raw data in red.

assoc_name{1} = ['TF DOG Fit'];
assoc_name{2} = ['TF Response curve'];
assoc_name{3} = ['TF DOG Low'];
assoc_name{4} = ['TF DOG High'];
assoc_name{5} = ['TF Low'];
assoc_name{6} = ['TF High'];

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
plot(A{1}.data(1,:),A{1}.data(2,:),'b');

hold on;

 % plot the raw data
h = myerrorbar(A{2}.data(1,:),A{2}.data(2,:),A{2}.data(4,:),'b');
delete(h(2)); % remove the line

 % now add the cut-offs

x_axis = A{1}.data(1,:);

colors = ['bbrr'];

for i=3:6,
	z = findclosest(x_axis,A{i}.data(1));
	%[A{i}.data(1) A{1}.data(1,z)  A{1}.data(2,z) ];
	plot(A{i}.data(1)*[1 1],A{1}.data(2,z)*[0 1],[colors(i-2) '--'],'linewidth',2);
end;

 % set the axis

title(cellname,'interp','none');

a = axis;
axis([0 40 a(3) a(4)]);

box off;
