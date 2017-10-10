%plot features of intrinsic_mouse_md_sf_analysis2.m"
function [freqOut responseOutput lineOutput] = responsePlot_raw_noback(base_directory, animal_number, fighand, color, norm, varargin)

% if norm = 1, normalize. If norm = 0, don't normalize.

image_scale = [ -0.001 0.001];

assign(varargin{:});

z = loadStructArray([base_directory filesep 'sf_responses.txt'])
z = z(animal_number),

Sfdat= intrinsic_mouse_md_sf_analysis2_steveedit(base_directory, animal_number);



fn = fieldnames(z);
errorToPlot = []

for i=1:length(fn),
    dirname = getfield(z,fn{i});
    stimlist = load([base_directory filesep dirname filesep 'stims.mat'],'-mat');
    for n=2,
        stim = get(stimlist.saveScript,n);
        s = load([base_directory filesep dirname filesep 'singlecondition' sprintf('%.4d',n) '.mat']);
        bino = load([base_directory filesep dirname filesep 'roi_binoV1.mat']);
        mono = load([base_directory filesep dirname filesep 'roi_monoV1.mat']);
        unresp = load([base_directory filesep dirname filesep 'roi_unresponsive.mat']);
    end;
%     
%     [responses] = intrinsic_roi_responses(dirname, 'roi_binoV1.mat', varargin)
%     errorToPlot = responses(4,n)
end;


% first plots (1) ODI using sf 0.05, then (2) right hemisphere, left eye,
% then (3) is right hemisphere, rigght eye, and (4) is left  hemisphere,
% left eye, ALL 3 plotted along log sf


sf_resp_info = loadStructArray([base_directory filesep 'sf_responses.txt']);
sf_resp_info = sf_resp_info(animal_number);

condition_names = {'', 'CONTRAHEM_IPSIEYE'};

titles = {'', 'Contra Hem, Deprived Eye - Raw Signal Minus Blank Screen, Binocular Cortex'};

% Analyze the data

for n=1:2
    n
    sf_resp_info = loadStructArray([base_directory filesep 'sf_responses.txt']);
    try
        sf_resp_info = sf_resp_info(n);
    catch
        break
    end
    sf_resp_info
    for i=2,
        i
        myindex = -1;
        for j=1:length(Sfdat),
            if strcmp(Sfdat(j).condition_name,condition_names{i}) & strcmp(Sfdat(j).roi_name,'roi_binoV1'),
                myindex = j
            end;
        end;
        if myindex==-1, error(['did not find a match.']); end;
        %x_sfs=Sfdat(myindex).sfs
        %can select to normalize or not, 1 = normalized, 0 = not
        A=(Sfdat(myindex).sf_responses_raw)
        x_sfs = A(1,:)
        y_response=A(2,:)
        errormonkey = A(4,:)
        if norm == 1
           normalization=max(y_response);
           y_response=(1/normalization).*y_response;
        
        end
           
        
        figure(fighand);
        hold on;
        scatter(x_sfs,y_response,'filled', color);
        hold on;
        
%         % calculate the fit line from defining variables, and graph it
%         interpolatedSFS=logspace(log10(Sfdat(myindex).sfs(1)),log10(Sfdat(myindex).sfs(8)),50);
%         fitvalues=Sfdat(myindex).Cgaussfit;
%         fittedValues=(fitvalues.Rsp+fitvalues.Rp*exp(-(interpolatedSFS-fitvalues.P).^2/2/(fitvalues.sigm)^2));
%         %normalization has different scale
%         if norm == 1
%             fittedValues=(1/normalization)*fittedValues
%         end
%         plot(interpolatedSFS,fittedValues,'--')
 %       plot(x_sfs,y_response, color);
        hold on;
        
        errorbar(x_sfs,y_response,errormonkey, errormonkey, 'o')
       %set(gca,'xscale','log');
        title(titles(i));
        box off;
        
        xlabel('Spatial Frequency (Hz)');
        ylabel('Response (Arbitrary Units)');
        title(titles{i});
        
        hold on;
    end;

    frequencyOutput = Sfdat(myindex).sfs;
    responseOutput =Sfdat(myindex).sf_responses;
    lineOutput =Sfdat(myindex).line;

 %start by narrowing response values for line, select max and find index value

[maxval, index] = max(y_response)

xfit=[];
yfit=[];

for i=1:numel(x_sfs)
    if i >= index && y_response(i) > 0
        xfit = [xfit,x_sfs(i)]
        yfit = [yfit,y_response(i)]
    end
    if y_response(i) < 0
        break;
    end
end

 
%old line fit, will use new one below    
%[slope,offset,threshold,exponent,curve, gof,fitinfo] = linepowerthresholdfit(-xfit,yfit,'offset_start', 0,'offset_range', [0 0],'exponent_start',1, 'exponent_range',[1 1] );
[slope, threshold, curve, gof,fitinfo] = linethresholdfit(-xfit,yfit)

% output the cutoff frequency from linepowerthreshold
freqOut = -1*threshold
%    x = sort(rand(20,1));
%     y = linepowerthreshold(x,3,0.3,0.5,1);
%        % limit search to exponents = 1
%     [slope,offset,t,exponent,thefit]=linepowerthresholdfit(x,y,'exponent_start',1,'exponent_range',[1 1]);
    x_sfs2 = 0.01:0.01:0.8;
    %  Y = SLOPE * RECTIFY(X - THRESHOLD)
    y_line = slope*rectify(-x_sfs2-threshold)
    plot(x_sfs2,y_line,'b--');
    hold on;
    
    
    % Save the figure
    name = [base_directory(end-9:end),'_',num2str(animal_number),'_noback.png']
    fullFileName = fullfile(base_directory, name)
    saveas(gca,fullFileName)
    %export_fig(fullFileName,  gca); % For example handleToAxes can be gca or gcf

%     plot(x,thefit,'rx');
%     box off;   


end

