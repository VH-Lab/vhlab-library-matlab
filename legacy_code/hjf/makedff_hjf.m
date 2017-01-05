function [ cellnames, dataraw, datafiltered, dff, t ] = makedff_hjf( expdir, sitename, dirname )
%MAKEDFF_HJF Computes and plots df/f
%   (write documentation)

    smooth = 120;

    ds = dirstruct(expdir);
    
    filename = [getscratchdirectory(ds) filesep sitename '_' dirname '_raw'];
    
    g = load(filename,'-mat');
    
    cellnames = g.listofcellnames;
    t = g.t;
    dataraw = g.data;
    
    sr = 1/median(diff(t{1}));
    [b,a]=cheby1(4,0.8,0.05/(0.5*sr),'high');
    
    for i=1:length(dataraw),
        datafiltered{i} = filtfilt(b,a,dataraw{i});
        % try padding here 
        fpadded{i} = [ mean(dataraw{i}(1:round(smooth*sr)))*ones(1,round(smooth*sr)) dataraw{i}(:)'  mean(dataraw{i}(end:-1:end-round(smooth*sr)))*ones(1,round(smooth*sr))];
        f{i} = conv2(fpadded{i},ones(1,round(smooth*sr))./sum(ones(1,round(smooth*sr))),'same');
        f{i} = f{i}(round(smooth*sr)+1:end-round(smooth*sr));
        dff{i} = (dataraw{i}'-f{i})./f{i};
    end;
end

% data052310=load('10_t00010_raw','-mat');
% raw052310=data052310.data{1};
% time052310=data052310.t{1};
% figurepalette('show');
% •	Create subplots in sigtool
% •	Plot of raw052310 against time052310 gives calcium raw signal plot like fitzlabbulk load.
% delf052310=(raw052310-mean(raw052310(6:15,1)))/mean(raw052310(6:15,1))*100;
% •	No special code written for baseline yet. Baseline manually selected by looking at spike2 stimulation plot. Usually a 5 sec window before pulse stimulation is used as baseline. 
% •	Plot of delf052310 against time052310 gives ?f/f plot
% dy052310=diff(delf052310)./diff(time052310);
% •	Gives rate of change of delf052310.  
% xd052310=time052310(1:end-1);
% •	Plot of dy052310 against xd052310 gives d(?f/f)/dt (%/s). Used to detect above threshold responses as positive Calcium signal to reconstruct AP timing. Threshold set at 2.58 SD of baseline values. Deviation from spike2 stimulation data depends on frame rate. Not perfect as it does give false positives and false negatives. Need to think of other ways of signal detection.
% Alternative d(?f/f)/dt plot 1
% SR052310=1/median(diff(time052310));
% F2delf052310=(delf052310(9:end)-delf052310(1:end-8))*SR052310;
% fxd052310=time052310(5:end-4);
% •	Plot of F2delf052310 against fxd052310 gives d(?f/f) over longer intervals. Good for detecting burst of AP that causes calcium signal to summate over time. 
% Alternative d(?f/f)/dt plot 2 
% [b052310,a052310]=cheby1(4,0.8,2/(0.5*SR052310),'high');
% Fdelf052310= filtfilt(b052310,a052310,delf052310);
% [b052310,a052310]=cheby1(4,0.8,1/(0.5*SR052310),'high');
% Fdelf052310= filtfilt(b052310,a052310,delf052310);
% Or 
% [b052310,a052310]=cheby1(4,0.8,1/(0.2*SR052310),'high');
% Fdelf052310= filtfilt(b052310,a052310,delf052310);
% [b052310,a052310]=cheby1(4,0.8,3/(0.2*SR052310),'high');
% [b052310,a052310]=cheby1(4,0.8,2.5/(0.2*SR052310),'high');
% 
% Link all subplots together:
% ax(1)=subplot(5,1,1);ax(2)=subplot(5,1,2);ax(3)=subplot(5,1,3);ax(4)=subplot(5,1,4);ax(5)=subplot(5,1,5);
% linkaxes(ax,'x');
% 
% To bring in calcium data (linescan): e.g.
% 
% headerls05261=readprairielsconfig('l00001-001.xml');
% rawls05261=double(imread('l00001-001_Ch2_Image_Line000001.tif'));
% time05261=(1:1:size(rawls05261,1))';
% ctime05261=(time05261*2.344*(1.0e-3))+2.87069;
% •	Allocation of timing to pixel is not perfect. All pixels within a single line scan (typically about 2.8ms) is currently treated as simultaneous. Pixel time is corrected to correspond to spike2 stimulation time by shutter opening time.  
% figure;imagesc(rawls05261);
% cellls05261=rawls05261(:,246:364);
% •	No script for automatic selection of region of interest yet. Region of interest covering cell is selected manually from imagesc. Including dark background introduces lots of noise and mask changes in ROI. No script written for drift correction yet.
% acellls05261=mean(cellls05261,2);
% Fcellls05261=mean(acellls05261(1336:2615,:));
% •	No special code written for baseline yet. Baseline manually selected by looking at spike2 stimulation plot. Usually a 5 sec window before pulse stimulation is used as baseline. 
% •	
% DFoverFls05261=((acellls05261-Fcellls05261)/Fcellls05261)*100;
% •	Plot of DFoverFls05261 against ctime05261 gives ?f/f plot. Line scan data of single trials are noisy. Need to do multiple trials or spike triggered averaging.
%  
% SR05261=1/median(diff(ctime05261));
% F2delfls05261=(DFoverFls05261(125:end)-DFoverFls05261(1:end-124))*SR05261;
% fxd05261ls=ctime05261(63:end-62);
% •	Plot of dy052310 against xd052310 gives d(?f/f)/dt (%/s). Used to detect above threshold responses as positive Calcium signal to reconstruct AP timing. Threshold set at 2.58 SD of baseline values. Deviation from spike2 stimulation data depends on frame rate.
% 
% irawls05261=rawls05261';
% imagesc(ctime05261,[1:size(irawls05261,1)],irawls05261);
% •	Plots colour plot with corrected timing.
% 
% ax(1)=subplot(4,1,1);ax(2)=subplot(4,1,2);ax(3)=subplot(4,1,3);ax(4)=subplot(4,1,4);
% linkaxes(ax,'x');
% axis tight
