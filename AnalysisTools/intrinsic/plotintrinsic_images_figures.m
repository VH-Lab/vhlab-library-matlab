%plot features of intrinsic_mouse_md_sf_analysis2.m"
function testingRealm = plotintrinsic_images_figures(base_directory, animal_number, varargin)

image_scale = [ -0.001 0.001];

assign(varargin{:});

z = loadStructArray([base_directory filesep 'sf_responses.txt']);
z = z(animal_number);

f1 = figure;
%this will plot all four images of both eyes, and both hemispheres

fn = fieldnames(z);

for i=1:length(fn),
    dirname = getfield(z,fn{i});
    stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');
    for n=2,
        stim = get(stimlist.saveScript,n);
        s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
        s = s.imgsc;
        s = rescale(s,image_scale,[0 255]);
        bino = load([base_directory filesep dirname filesep 'roi_binoV1.mat']);
        mono = load([base_directory filesep dirname filesep 'roi_monoV1.mat']);
        unresp = load([base_directory filesep dirname filesep 'roi_unresponsive.mat']);
        subplot(2,2,i);
        image(s);
        colormap(gray(256));
        title(fn{i});
        hold on;
        plot(bino.xi,bino.yi,'b-');
        
    end;
end;


% first plots (1) ODI using sf 0.05, then (2) right hemisphere, left eye,
% then (3) is right hemisphere, rigght eye, and (4) is left  hemisphere,
% left eye, ALL 3 plotted along log sf
% is 6, 8, 2

ODstruct = intrinsic_mouse_od_analysis_v2_5('V:\Projects\ChelseaISI\2017-01-19', 't00003', 't00002');
f2 = figure;
subplot(2,2,1);
bar(ODstruct.odindex);
title('Ocular Dominance Index')
hold on;

% set the indices for null, rhem leye, rhem reye, lhem leye
indices = [0, 6, 8, 2]
titles = {'', 'Contra Hem, Deprived Eye', 'Contra Hem, Non-Deprived', 'Ipsi Hem, Deprived'}

% Analyze the data
Sfdat= intrinsic_mouse_md_sf_analysis2('V:\Projects\ChelseaISI\2017-01-19', 1)

for i=2:4,
    subplot(2,2,i);
    x_sfs=Sfdat(indices(i)).sfs;
    y_response=Sfdat(indices(i)).sf_responses;
    scatter(x_sfs,y_response);
    set(gca,'xscale','log');
    title(titles(i));
    hold on;
    %dirname = getfield(z,fn{i});
    %stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');

    %for n=2,
        %stim = get(stimlist.saveScript,n);
        %s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
        
     %   title
        
        
      %  title(fn{i});
       % hold on;
        %plot(bino.xi,bino.yi,'b-');
        
    %end;
end;





subplot(2,2,1)


subplot(2,2,2)
plot(ans(1).sfs,ans(1).sf_responses,'og')
hold on;
plot(ans(2).sfs,ans(2).sf_responses,'ob')

xlabel('Spatial Frequencies');
ylabel('Response');
title('');



hold on; % leave the current plot on the figure



