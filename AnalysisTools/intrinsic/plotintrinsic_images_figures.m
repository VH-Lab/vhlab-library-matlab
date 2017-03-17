%plot features of intrinsic_mouse_md_sf_analysis2.m"
function testingRealm = plotintrinsic_images_figures(base_directory, animal_number, varargin)

image_scale = [ -0.001 0.001];

assign(varargin{:});

z = loadStructArray([base_directory filesep 'sf_responses.txt']);
z = z(animal_number);

Sfdat= intrinsic_mouse_md_sf_analysis2(base_directory, animal_number);


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


sf_resp_info = loadStructArray([base_directory filesep 'sf_responses.txt']);

ODstruct = intrinsic_mouse_od_analysis_v2_5(base_directory, sf_resp_info.CONTRAHEM_CONTRAEYE, sf_resp_info.CONTRAHEM_IPSIEYE);
f2 = figure;
subplot(2,2,1);
bar(ODstruct.odindex);
axis([0 2 -1 1])
title('Ocular Dominance Index')
hold on;

% set the indices for null, rhem leye, rhem reye, lhem leye
indices = [0, 6, 8, 2]

condition_names = {'', 'CONTRAHEM_IPSIEYE', 'CONTRAHEM_CONTRAEYE', 'IPSIHEM_IPSIEYE'};

titles = {'', 'Contra Hem, Deprived Eye', 'Contra Hem, Non-Deprived', 'Ipsi Hem, Deprived'}

% Analyze the data

for i=2:4,
    subplot(2,2,i);
    myindex = -1;
    for j=1:length(Sfdat),
        if strcmp(Sfdat(j).condition_name,condition_names{i}) & strcmp(Sfdat(j).roi_name,'roi_monoV1'),
            myindex = j;
        end;
    end;
    if myindex==-1, error(['did not find a match.']); end;
    x_sfs=Sfdat(myindex).sfs;
    y_response=Sfdat(myindex).sf_responses;
    scatter(x_sfs,y_response);
    set(gca,'xscale','log');
    title(titles(i));
    box off;
    
    xlabel('Spatial Frequencies');
    ylabel('Response');
    title('');
    
    hold on;
end;



