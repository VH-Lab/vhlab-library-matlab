close all;

prefix = ['V:\Projects\ChelseaISI\'];
explist = {'2017-07-30','2017-07-31', '2017-07-06','2017-07-10','2017-08-05', '2017-08-05','2017-07-31','2017-07-30'...
    ,'2017-08-10','2017-07-21','2017-08-24','2017-09-01','2017-08-10','2017-08-24','2017-09-01'}
animalnum = [1 1 1 1 1 2 2 2 1 1 1 1 2 2 2];
conditioncode = 'mmmmmbbbrrrrkkk'
%fighand = [111122233334444] %to be determined/worked on later once we know
%how we are analyzing each animal
twodayIntersect = []; 
noDepTwointersect = [];
sixdaydepIntercept=[];
noDepSixintercept=[];



for i=1:length(explist),
    close all;
    
    
    [prefix explist{i}]
    % plot and or analyze if .mat files have not yet been created
    [freqOut responseOutput lineOutput] = responsePlot_raw([prefix explist{i}],animalnum(i), 1, conditioncode(i), 0);
    %here I want to say that if it is a certain condition then store freq,
    % in different matrices
    if conditioncode(i) == 'm'
        twodayIntersect = [twodayIntersect, freqOut]
    end
    if conditioncode(i) == 'r'
        sixdaydepIntercept = [sixdaydepIntercept, freqOut]
    end
    if conditioncode(i) == 'b'
        noDepTwointersect = [noDepTwointersect, freqOut]
    end
    if conditioncode(i) == 'k'
        noDepSixintercept = [noDepSixintercept, freqOut]
    end
end;


%  twodayIntersect = [];
% 
% [freq a aline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-07-30', 1, 1, 'm',0)
% twodayIntersect = [twodayIntersect, freq]
% close all;
% [freq b bline]= responsePlot_raw('V:\Projects\ChelseaISI\2017-07-31', 1, 1, 'm',0)
% twodayIntersect = [twodayIntersect, freq]
% close all;
% 
% % [freq c cline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-07-06', 1, 1, 'm',0)
% % twodayIntersect = [twodayIntersect, freq]
% [freq e]=plotintrinsic_images_figures_justcontra_normalized_bino('V:\Projects\ChelseaISI\2017-07-10', 1, 1, 'g')
%[freq
%f]=plotintrinsic_images_figures_justcontra_normalized('V:\Projects\ChelseaISI\2017-07-22',
%1, 1, 'c') %this one has the ROIs that need to be manually edited but
%currently getting an error
%  close all;
% [freq g gline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-08-05', 1, 1, 'm',0)
% 
% twodayIntersect = [twodayIntersect, freq]

%***********************************************


% close all;
% [freq cc ccline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-08-05', 2, 2, 'k',0)
% noDepTwointersect = [noDepTwointersect, freq]
% close all;
% [freq bb bbline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-07-31', 2, 2, 'k',0)
% noDepTwointersect = [noDepTwointersect, freq]
% close all;
% [freq aa aaline]=responsePlot_raw('V:\Projects\ChelseaISI\2017-07-30', 2, 2, 'k',0)
% noDepTwointersect = [noDepTwointersect, freq]
% close all;
%[freq cc] =plotintrinsic_images_figures_justcontra_normalized('V:\Projects\ChelseaISI\2017-07-07', 1, 1, 'k')

%***********************************************
% 
% [freq a2 a2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-08-10', 1, 3, 'r',0)
% close all;
% sixdaydepIntercept = [sixdaydepIntercept, freq]
% [freq b2 b2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-07-21', 1, 3, 'r',0)
% sixdaydepIntercept = [sixdaydepIntercept, freq]
% close all;
% [freq c2 c2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-08-24', 1, 3, 'r',0)
% sixdaydepIntercept = [sixdaydepIntercept, freq]
% close all;
% [freq d2 d2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-09-01', 1, 3, 'r',0)
% sixdaydepIntercept = [sixdaydepIntercept, freq]
% close all;
%***********************************************

% 
% [freq cc2 cc2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-09-01', 2, 3, 'k',0)
% noDepSixintercept = [noDepSixintercept, freq]
% close all;

% [freq aa2 aa2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-08-10', 2, 3, 'k',0)
% close all;
% noDepSixintercept = [noDepSixintercept, freq]
% [freq bb2 bb2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-08-24', 2, 3, 'k',0)
% close all;
% noDepSixintercept = [noDepSixintercept, freq]
%***********************************************



names = {'Two Day';'Two Day WT';'Six Day'; 'Six Day WT'}

DataAverages = [mean(twodayIntersect),mean(noDepTwointersect), mean(sixdaydepIntercept), mean(noDepSixintercept)]

f2 = figure;

bar(DataAverages, 'FaceColor', [0.5 0.5 0.5])

hold on;
%scatter([1,1,1,1],twodayIntersect)
set(gca,'xticklabel',names)
scatter([1,1,1,1,1],twodayIntersect, 'filled')
scatter([2,2,2],noDepTwointersect, 'filled')
scatter([3,3,3,3],sixdaydepIntercept, 'filled')
scatter([4,4,4],noDepSixintercept, 'filled')


%[freq dd2 dd2line]= responsePlot_raw('V:\Projects\ChelseaISI\2017-09-05', 1, 3, 'k')
%[freq e2]= plotintrinsic_images_figures_justcontra_normalized_bino('V:\Projects\ChelseaISI\2017-09-06', 1, 1, 'r')