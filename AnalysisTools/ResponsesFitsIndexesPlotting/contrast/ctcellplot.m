function ctcellplot(cell,cellname, assoc_prefix, check_simple_complex)
% CTCELLPLOT - Examine a cell's contrast fits and plot
%
%  CTCELLPLOT(CELL, CELLNAME, ASSOC_PREFIX, CHECK_SIMPLECOMPLEX)
%
%  Plots the fits for contrast, along with mean responses and error bars.  
%
%

assoc_name{1} = ['CT NKS Fit'];
assoc_name{2} = ['CT Response curve'];
assoc_name{3} = ['CT NK Fit'];

[f1f0,rmg,c50,si,sig_ct] = extract_oridir_indexes(cell)

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

 % plot the fits
cols = ['b_kr'];

for i=[1 3],
	if ~isreal(A{i}.data(2,:)), 
		disp(['Complex value discovered']);
		A{i}.data(2,:) = abs(A{i}.data(2,:));
	end;
	plot(A{i}.data(1,:),A{i}.data(2,:),cols(i));
	hold on;
end;

hold on;

 % plot the raw data
h = myerrorbar(A{2}.data(1,:),A{2}.data(2,:),A{2}.data(4,:),'b');
delete(h(2)); % remove the line

 % now add the cut-offs

x_axis = A{1}.data(1,:);

colors = ['bbrr'];

 % set the axis

title([cellname ',c50=' num2str(c50) ',rmg=' num2str(rmg) ',si=' num2str(si) '.'],'interp','none');

a = axis;
axis([0 1 a(3) a(4)]);

box off;
