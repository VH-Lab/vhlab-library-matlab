function sfcellplotdog(cell,cellname, assoc_prefix, check_simple_complex)
% SFCELLPLOT - Examine a cell's spatial frequency fit and plot
%
%  SFCELLPLOTDOG(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Plots the DOG fit for spatial frequency, along with mean responses
%  and error bars.  Also shows LOW/HIGH cut-offs for DOG in blue, and
%  LOW/HIGH cut-offs based on interpolation of the raw data in red.

assoc_name{1} = ['SF DOG Fit'];
assoc_name{2} = ['SF Response curve'];
assoc_name{3} = ['SF DOG Low'];
assoc_name{4} = ['SF DOG High'];
assoc_name{5} = ['SF Low'];
assoc_name{6} = ['SF High'];

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
axis([0 1.8 a(3) a(4)]);

box off;
