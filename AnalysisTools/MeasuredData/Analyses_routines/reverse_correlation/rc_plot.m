function out=rc_plot(input)
% RC_PLOT - Plot raw and bootstrap statistic versions of reverse-correlation grid
%
%  OUT = RC_PLOT(INPUT)
%
%  Given an INPUT structure with fields:
%     'REV_CORR' an NUM_TIMESTEPSxNUM_GRIDPOINTSxNUM_REPS matrix that is the best
%          linear filter between the stimulus and the data
%     'XC_STIMSIGNAL', an NUM_TIMESTEPSxNUM_GRIDPOINTSxNUM_REPS matrix that is the 
%          correlation between the stimulus and the data
%     'XC_STIMSTIM', a NUM_TIMESTEPSx1 vector that is the autocorrelation of the stimulus
%     'AVG_REVCORR' an NUM_TIMESTEPSxNUM_GRIDPOINTSx1 matrix that is the average (over stimulus repetitions)
%          linear filter between the stimulus and the data
%     'AVG_XCSTIMSIGNAL', an NUM_TIMESTEPSxNUM_GRIDPOINTSx1 matrix that is the average (over stimulus repetitions)
%          correlation between the stimulus and the data
%     'AVG_XC_DECONVOLVED', an NUM_TIMESTEPSxNUM_GRIDPOINTSx1 matrix that is the deconvolved average (over stimulus repetitions)
%          correlation between the stimulus and the data, representing the best linear filter between the stimulus and data
%
%  Makes a figure that plots the AVG_XC_DECONVOLVED and the AVG_XCSTIMSIGNAL in pcolor elements, and 
%  also a bootstrap based significance measure (see RC_BOOTSTRAP).
%
%  The bootstrap outputs for REV_CORR and XC_STIMSIGNAL are returned in OUT.
% 

out = [];

figure;
titles = {'Kernel','Stim x Signal'};

V = prod(input.gridsize);

for i=1:2,
        if i==1,
                plotvar = input.avg_xc_deconvolved;
                bsvar = input.rev_corr;
        else,
                plotvar = input.avg_xcstimsignal;
                bsvar = input.xc_stimsignal;
        end;

        subplot(2,3,1+3*(i-1));
        if size(plotvar,2)==1,
                imagesc(1:V,input.kerneltimes,plotvar);
                set(gca,'ydir','reverse');
                xlabel('Space (grid positions)');
                ylabel('Time (s)');
        else,
                pcolor(1:V,input.kerneltimes,mean(plotvar,3)); shading flat;
                xlabel('Space (grid positions)');
                ylabel('Time (s)');
        end;
        title(titles{i});
        colormap(gray(256));
        subplot(2,3,2+3*(i-1));
        [bs{i},bsimg{i}] = rc_bootstrap(bsvar,1000);
        image(1:V,input.kerneltimes,bsimg{i});
        set(gca,'ydir','normal');
        xlabel('Space (grid positions)');
        ylabel('Time (s)');
        
        subplot(2,3,3+3*(i-1));
        plotvar_mn = mean(plotvar,1);
        plotvar_mn = reshape(plotvar_mn,input.gridsize(2), input.gridsize(1));
        imagesc(1:input.gridsize(1),1:input.gridsize(2),plotvar_mn);
        set(gca,'ydir','reverse');
        xlabel('Space X (grid positions)');
        ylabel('Space Y (grid positions)');
        
end;

out = var2struct('bs','bsimg');
