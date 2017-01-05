function h0 = plototresponse(cell,cellname,property,eb,fit,varargin)

% PLOTTPRESPONSE - Plots orientation responses for cell
%
%   H = PLOTTPRESPONSE(CELL,CELLNAME,PROPERTY,EB,FIT,...)
%
%  Plots tp response curves for a cell on the curent axes.
%
%  Known PROPERTY codes:
%
%     'OT Pref'
%     'OT Fit Pref'
%     'OT Fit Pref 2 Peak'
%     'POS Fit Pref'
%     'Recovery OT Fit Pref 2 Peak'
%
%  If EB is 1, then standard error is shown.
%  If FIT is 1, then the fit is shown if available. If FIT is 1 or there is
%    no available fit then linear interpolation is shown.
%
%  Extra variables can be passed as name/value pairs, e.g., 
%     PLOTPTRESPONSE(CELL,CELLNAME,PROPERTY,EB,FIT,'ds',ds)
%
%  If property is 'Recovery OT Fit Pref 2 Peak', and if a variable DS
%     is passed as an extra variable, then an additional figure is shown
%     with the views of the original cell positions.

if nargin==0,  % is show all callback command
	myud = get(gcbo,'userdata');
	if ~isempty(intersect(myud.property,{'OT Pref','OT Fit Pref','OT Fit Pref 2 Peak'})),
		proplist = {'POS Fit Pref'};
	else, proplist = {'OT Fit Pref 2 Peak'};
	end;
	for i=1:length(proplist),
		figure;
		plottpresponse(myud.cell,myud.cellname,proplist{i},myud.eb,myud.fit);
	end;
	return;
end;

dontclose = 1;
plotnonsig = 1;
usepolar=0;
subtractblank = 0;
plotblankrange = 0;
nopushbutton = 0;

assign(varargin{:});

fitx = [0 1]; fity = [0 1];
proceed = 1; altcurve = 0;
switch property,
case {'OT Pref','OT Fit Pref'},
	fitx = 0:359;
	resp = findassociate(cell,'Best orientation resp','','');
	resp = resp.data;
	if fit==1,
		fitd=findassociate(cell,'OT Carandini Fit','','');
		if isempty(fitd),
			fitd=findassociate(cell,'IT Carandini Fit','','');
		end;
		fity = fitd.data;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
case {'OT Fit Pref 2 Peak'},
	fitx = 0:359;
	resp = findassociate(cell,'Best orientation resp','','');
	resp = resp.data;
	if fit==1,
		fitd=findassociate(cell,'OT Carandini 2-peak Fit','','');
		fity = fitd.data;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
case {'POS Pref','POS Fit Pref'},
	posresp = findassociate(cell,'POS Response curve','','');
	resp.curve = posresp.data;
	if fit==1,
		fitd = findassociate(cell,'POS Fit','','');
		fitx = fitd.data(1,:); fity = fitd.data(2,:);
	end;
	xlab = 'position (pixels)'; ylab = '\DeltaF/F';
case {'Recovery OT Fit Pref 2 Peak'},
        fitx = 0:359;
        resp0 = findassociate(cell,'Recovery OT Response curve','','');
        resp.curve = resp0.data;
        if fit==1,
                fitd=findassociate(cell,'Recovery OT Carandini 2-peak Fit','','');
                fity = fitd.data;
        end;
	altresp0 = findassociate(cell,'OT Response curve','','');
	if ~isempty(altresp0),
		altcurve = 1;
		altresp.curve = altresp0.data;
		altfitx = fitx;
		if fit==1,
			altfitd = findassociate(cell,'OT Carandini 2-peak Fit','','');
			altfity = altfitd.data;
		end;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
	if exist('ds'),
		%disp(['here']);
	end;
case {'Recovery OT Fit Pref'},
        fitx = 0:359;
        resp0 = findassociate(cell,'TP ME Ach OT Response curve','','');
        resp.curve = resp0.data;
        if fit==1,
                fitd=findassociate(cell,'TP ME Ach OT Carandini Fit','','');
                fity = fitd.data(2,:);
        end;
	altresp0 = findassociate(cell,'TP Ach OT Response curve','','');
	if ~isempty(altresp0),
		altcurve = 1;
		altresp.curve = altresp0.data;
		altfitx = fitx;
		if fit==1,
			altfitd = findassociate(cell,'TP Ach OT Carandini Fit','','');
			altfity = altfitd.data(2,:);
		end;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
	if exist('ds'),
		%disp(['here']);
	end;
case 'Temporal frequency',
	fit_tf = findassociate(cell,'TP Ach TF DOG Fit','','');
	resp0 = findassociate(cell,'TP Ach TF Response curve','','');
	blankresp = findassociate(cell,'TP Ach TF Blank Response','','');
	fitx = fit_tf.data(1,:);
	resp.curve = resp0.data;
	resp.curve(2,:) =resp.curve(2,:)-blankresp.data(1);
	if fit==1,
		fity = fit_tf.data(2,:)-blankresp.data(1);
	end;
	xlab = 'Temporal frequency (Hz)';
	ylab = '\DeltaF/F';
case 'Temporal frequency spline',
	fit_tf = findassociate(cell,'TP Ach TF spline Fit','','');
	resp0 = findassociate(cell,'TP Ach TF Response curve','','');
	blankresp = findassociate(cell,'TP Ach TF Blank Response','','');
	fitx = fit_tf.data(1,:);
	resp.curve = resp0.data;
	resp.curve(2,:) = resp.curve(2,:) - blankresp.data(1);
	if fit==1,
		fity = fit_tf.data(2,:)-blankresp.data(1);
	end;
	xlab = 'Temporal frequency (Hz)';
	ylab = '\DeltaF/F';
case {'CONTRAIPSI'},
        fitx = 0:359;
        resp0 = findassociate(cell,'TP CONT Ach OT Response curve','','');
	blank0 = findassociate(cell,'TP CONT Ach OT Blank Response','','');
        resp.curve = resp0.data-blank0.data(1);
        if fit==1,
                fitd=findassociate(cell,'TP CONT Ach OT Carandini Fit','','');
                fity = fitd.data(2,:)-blank0.data(1);
        end;
	altresp0 = findassociate(cell,'TP IPSI Ach OT Response curve','','');
	altblank0 = findassociate(cell,'TP IPSI Ach OT Blank Response','','');
	if ~isempty(altresp0),
		altcurve = 1;
		altresp.curve = altresp0.data - altblank0.data(1);
		altfitx = fitx;
		if fit==1,
			altfitd = findassociate(cell,'TP IPSI Ach OT Carandini Fit','','');
			altfity = altfitd.data(2,:)-altblank0.data(1);
		end;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
	if exist('ds'),
		%disp(['here']);
	end;


case {'Recovery OT Fit Pref BS'},
    fitx = 0:359;
    blank0 = findassociate(cell,'TP ME Ach OT Blank Response','','');
    resp0 = findassociate(cell,'TP ME Ach OT Response curve','','');
    if ~isempty(resp0)&~isempty(blank0), resp0.data(2,:) = resp0.data(2,:)-blank0.data(1); end;
    resp.curve = resp0.data;
    if fit==1,
            fitd=findassociate(cell,'TP ME Ach OT Carandini Fit','','');
            fity = fitd.data(2,:)-blank0.data(1);
    end;
	altresp0 = findassociate(cell,'TP Ach OT Response curve','','');
    altblank0 = findassociate(cell,'TP Ach OT Blank Response','','');
	if ~isempty(altresp0),
		altcurve = 1;
        if ~isempty(altblank0), altresp0.data(2,:)=altresp0.data(2,:)-altblank0.data(1); end;
		altresp.curve = altresp0.data;
		altfitx = fitx;
		if fit==1,
			altfitd = findassociate(cell,'TP Ach OT Carandini Fit','','');
			altfity = altfitd.data(2,:)-blank0.data(1);
		end;
	end;
	xlab = 'direction (\circ)'; ylab = '\DeltaF/F';
	if exist('ds'),
		%disp(['here']);
	end;    
case {'Iont OT Fit Pref'},
    	iontotpvalue = findassociate(cell,'Iont OT visual response p','','');
		iontotresp = findassociate(cell,'Iont OT Response curve','','');
		iontotresp_fit = findassociate(cell,'Iont OT Carandini 2-peak Fit','','');
		iontcurrents = findassociate(cell,'Iont currents','','');
        iontblankvals = findassociate(cell,'Iont vis blank','','');
		for i=1:length(iontotresp.data),
			if iontcurrents.data(i)==0, c = 'k';
			elseif iontcurrents.data(i)>0, c = 'b';
			else, c = 'r';
			end;
			resp = iontotresp.data{i};
			fit = iontotresp_fit.data{i};
			hold on;
			if eb, heb=errorbar(resp(1,:),resp(2,:),resp(4,:),[c 'o']); set(heb,'linewidth',2); end;
			if fit, plot(0:359,fit,c,'linewidth',2);end;
            if eb, plot([-1000 1000],iontblankvals.data(i,[2 2]),[c '-']); end;
            if eb, plot([-1000 1000],iontblankvals.data(i,[2 2])+iontblankvals.data(i,4),[c '--']); end;
            if eb, plot([-1000 1000],iontblankvals.data(i,[2 2])-iontblankvals.data(i,4),[c '--']); end;
            
        end;
        A=axis; axis([min(resp(1,:)) max([resp(1,:) 180]) A([3 4])]);
		xlabel('Direction (\circ)')
		ylabel('\Delta F/F');
		title([cellname ',black=baseline,blue=GABA,red=GLUT'],'interp','none');
        proceed = 0;
case {'Spatial frequency'},
	if ~exist('usesig','var'), usesig = 0; end;
	sgr=plotrespnamesallcolors(cell,'TP','SF Response curve','SF DOG Fit',eb,fit,'SF visual response p',usesig,'',usepolar,subtractblank);
	if sgr,
		title(cellname,'interp','none');
		xlabel('Spatial frequency (cpd)');
		ylabel('\DeltaF/F');
	end;
	proceed = 0;
case {'Orientation/Direction','TP Ach OT Fit Pref','TP ME Ach OT Fit Pref','TP FE Ach OT Fit Pref'},
	respname = 'OT Response curve';
	fitname = 'OT Carandini Fit';
	if ~exist('usesig','var'), usesig = 0; end;
    strtoadd = '';
    if ~isempty(findstr(property,'ME')), strtoadd = ' ME';
    elseif ~isempty(findstr(property,'FE')), strtoadd = ' FE';
    end;
	sgr=plotrespnamesallcolors(cell,['TP' strtoadd],'OT Response curve','OT Carandini Fit',eb,fit,'OT visual response p',usesig,'OT Blank Response',usepolar,subtractblank,plotblankrange);
    if sgr,
   		title(cellname,'interp','none');
    end;
	if sgr&~usepolar,
		xlabel('Direction(\circ)');
		ylabel('\DeltaF/F');
		xch = get(gca,'children');
		mxxd = 180;
		for i=1:length(xch),
			try,
				xd = get(xch(i),'XData');
				if length(xd)<300,
					mxxd = max([mxxd get(xch(i),'XData')]);
				end;
			end;
		end;
		if mxxd>180, mxxd = 360; end;
		A=axis;
		axis([0 mxxd A([3 4])]); 
	end;
	proceed = 0;
case {'Direction Bootstrap Angles','Direction ME Bootstrap Angles','Direction FE Bootstrap Angles'},
    if ~isempty(findstr(property,'ME')), stradd=' ME';
    elseif ~isempty(findstr(property,'FE')), stradd=' FE';
    else, stradd = '';
    end;
    
    BSf = findassociate(cell,['TP' stradd ' Ach OT Bootstrap Carandini Fit Params'],'','');
    subplot(2,2,1);
    axis square;
    [x,y] = pol2cart(BSf.data(:,3)*pi/180,ones(size(BSf.data(:,3))));
    plot([zeros(size(BSf.data(:,3))) x]',[zeros(size(BSf.data(:,3))) y]','k-');
    axis([-1 1 -1 1]); box off; axis square;
    du=dpuncertainty(BSf.data(:,3));
    title(['Uncertainty: ' num2str(100*du)]);
    proceed=0;
    subplot(2,2,2);
    bins=[-Inf 0:5:360 Inf]; X_axis = 0:5:360+5/2;
    N=histc(BSf.data(:,3),bins);
    bar(X_axis,N(2:end-1)); A=axis; axis([0 360 A(3) A(4)]);  box off; axis square;
case {'Color exchange','TP sig S cone'}, 
	cer = findassociate(cell,'TP CE Response curve','','');
	ces = findassociate(cell,'TP sig S cone','','');
	cesv = findassociate(cell,'TP CE visual response p','','');
	ceb = findassociate(cell,'TP CE Blank Response','','');
	cefit=findassociate(cell,'TP CE Color Fit','','');
	cefitparams=findassociate(cell,'TP CE Color Fit Params','','');
	cefitc=findassociate(cell,'TP CE Color C Fit','','');
	cefitd=findassociate(cell,'TP CE Color D Fit','','');
	cefitcomb=findassociate(cell,'TP CE Color Comb Fit','','');
	cefitnk=findassociate(cell,'TP CE Color NK Fit','','');
	cefitnkt=findassociate(cell,'TP CE Color NKT Fit','','');
	titlestr = '';
	if ~isempty(cer)&~isempty(ces)&~isempty(cesv),
		if plotnonsig|(cesv.data<0.05), % if sig S and significant variation across all stims
			steps=[0 0 0.8;0 0.08 0.8;0 0.13 0.8;0 0.16 0.8;0 0.19 0.8;0 0.22 0.8;0 0.3 0.8;0 0.4 0.8;0 0.6 0.8;0 0.8 0.8];
			h=myerrorbar(-steps(:,2),cer.data(2,:),cer.data(4,:),cer.data(4,:));
			set(h,'color',[0 0 0],'linewidth',2);
			if ~isempty(ceb),
				hold on;
				plot([-100 100],ceb.data(1)*[1 1],'k-','linewidth',2);
				plot([-100 100],(ceb.data(1)+ceb.data(3))*[1 1],'k--','linewidth',2);
				plot([-100 100],(ceb.data(1)-ceb.data(3))*[1 1],'k--','linewidth',2);
			end;
			if fit==1&~isempty(cefit),
				plot(-steps(:,2),cefit.data(2,:),'m--','linewidth',2);
				titlestr = [' L = ' num2str(cefitparams.data(1),2) ', S = ' num2str(cefitparams.data(2),2) '.']; %...
					%', LC50=' num2str(cefitparams.data(3),2) ', SC50=' num2str(cefitparams.data(4),2) ...
					%', LN=' num2str(cefitparams.data(5),2) ', SN=' num2str(cefitparams.data(6),2) '.'];
				if ~isempty(cefitc), plot(-steps(:,2),cefitc.data.fit(2,:)+ceb.data(1),'b--'); end;
				if ~isempty(cefitd), plot(-steps(:,2),cefitd.data.fit(2,:)+ceb.data(1),'c','linewidth',4); end;
				if ~isempty(cefitcomb), plot(-steps(:,2),cefitcomb.data.fit(2,:)+ceb.data(1),'r--'); end;
				if ~isempty(cefitnkt), plot(-steps(:,2),cefitnkt.data.fit(2,:)+ceb.data(1),'g--'); end;
				if ~isempty(cefitnk), plot(-steps(:,2),cefitnk.data(2,:),'--','color',[0.8 0.8 0.8]); end;

			end;
			A = axis;
			axis([-.85 0.05 A([3 4])]);
			title([cellname titlestr],'interp','none');
			ylabel('\DeltaF/F');
			xlabel('Green gun gain');
			set(gca,'box','off','xdir','reverse');
		else, if ~dontclose, close(gcf); end;
		end;
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
case {'Color barrage'}, 
	cer = findassociate(cell,'TP CEB Response curve','','');
	ces = findassociate(cell,'TP CEB sig S cone','','');
	cesv = findassociate(cell,'TP CEB visual response p','','');
	ceb = findassociate(cell,'TP CEB Blank Response','','');
	cefit=findassociate(cell,'TP CEB Color Fit','','');
	cefitparams=findassociate(cell,'TP CEB Color Fit Params','','');
	titlestr = '';
	if ~isempty(cer)&~isempty(ces)&~isempty(cesv),
		if plotnonsig|(cesv.data<0.05), % if sig S and significant variation across all stims
			h=myerrorbar(cer.data(1,:),cer.data(2,:),cer.data(4,:),cer.data(4,:));
			set(h,'color',[0 0 0],'linewidth',2);
			if ~isempty(ceb),
				hold on;
				plot([-100 100],ceb.data(1)*[1 1],'k-','linewidth',2);
				plot([-100 100],(ceb.data(1)+ceb.data(3))*[1 1],'k--','linewidth',2);
				plot([-100 100],(ceb.data(1)-ceb.data(3))*[1 1],'k--','linewidth',2);
			end;
			if fit==1&~isempty(cefit),
				plot(cefit.data(1,:),cefit.data(2,:),'m--','linewidth',2);
				titlestr = [' L = ' num2str(cefitparams.data(1),2) ', S = ' num2str(cefitparams.data(2),2) '.']; %...
					%', LC50=' num2str(cefitparams.data(3),2) ', SC50=' num2str(cefitparams.data(4),2) ...
					%', LN=' num2str(cefitparams.data(5),2) ', SN=' num2str(cefitparams.data(6),2) '.'];
			end;
			A = axis;
			axis([0 17 A([3 4])]);
			title([cellname titlestr],'interp','none');
			ylabel('\DeltaF/F');
			xlabel('Stim number');
		else, if ~dontclose, close(gcf); end;
		end;
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
case {'Color Dacey'}, 
	cer = findassociate(cell,'TP CED Response curve','','');
	ces = findassociate(cell,'TP CED sig S cone','','');
	cesv = findassociate(cell,'TP CED visual response p','','');
	ceb = findassociate(cell,'TP CED Blank Response','','');
	cefit=findassociate(cell,'TP CED Color Fit','','');
	cefitparams=findassociate(cell,'TP CED Color Fit Params','','');
	cefitc=findassociate(cell,'TP CED Color C Fit','','');
	cefitd=findassociate(cell,'TP CED Color D Fit','','');
	cefitcomb=findassociate(cell,'TP CED Color Comb Fit','','');
	cefitnk=findassociate(cell,'TP CED Color NK Fit','','');
	cefitnkt=findassociate(cell,'TP CED Color NKT Fit','','');	
	titlestr = '';
	if ~isempty(cer)&~isempty(ces)&~isempty(cesv),
		if plotnonsig|(cesv.data<0.05), % if sig S and significant variation across all stims
			h=myerrorbar(cer.data(1,:),cer.data(2,:),cer.data(4,:),cer.data(4,:));
			set(h,'color',[0 0 0],'linewidth',2);
			if ~isempty(ceb),
				hold on;
				plot([-100 100],ceb.data(1)*[1 1],'k-','linewidth',2);
				plot([-100 100],(ceb.data(1)+ceb.data(3))*[1 1],'k--','linewidth',2);
				plot([-100 100],(ceb.data(1)-ceb.data(3))*[1 1],'k--','linewidth',2);
			end;
			if fit==1&~isempty(cefit),
				plot(cefit.data(1,:),cefit.data(2,:),'m--','linewidth',2);
				titlestr = [' L = ' num2str(cefitparams.data(1),2) ', S = ' num2str(cefitparams.data(2),2) '.']; %...
					%', LC50=' num2str(cefitparams.data(3),2) ', SC50=' num2str(cefitparams.data(4),2) ...
					%', LN=' num2str(cefitparams.data(5),2) ', SN=' num2str(cefitparams.data(6),2) '.'];
				if ~isempty(cefitc), plot(cefitc.data.fit(1,:),cefitc.data.fit(2,:)+ceb.data(1),'b--'); end;
				if ~isempty(cefitd), plot(cefitd.data.fit(1,:),cefitd.data.fit(2,:)+ceb.data(1),'c','linewidth',4); end;
				if ~isempty(cefitcomb), plot(cefitcomb.data.fit(1,:),cefitcomb.data.fit(2,:)+ceb.data(1),'r--'); end;
				if ~isempty(cefitnkt), plot(cefitnkt.data.fit(1,:),cefitnkt.data.fit(2,:)+ceb.data(1),'g--'); end;
				if ~isempty(cefitnk), plot(cefitnk.data(1,:),cefitnk.data(2,:),'--','color',[0.8 0.8 0.8]); end;
				
			end;
			A = axis;
			axis([0 14 A([3 4])]);
			title([cellname titlestr],'interp','none');
			ylabel('\DeltaF/F');
			xlabel('Stim number');
		else, if ~dontclose, close(gcf); end;
		end;
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
case {'Color Dacey Expanded'}, 
	cer = findassociate(cell,'TP CEDE Response curve','',''),
	ces = findassociate(cell,'TP CEDE sig S cone','',''),
	cesv = findassociate(cell,'TP CEDE visual response p','','');
	ceb = findassociate(cell,'TP CEDE Blank Response','','');
	cefit=findassociate(cell,'TP CEDE Color Fit','','');
	cefitparams=findassociate(cell,'TP CEDE Color Fit Params','','');
    cefitparamsnk=findassociate(cell,'TP CEDE Color NK Fit Params','','');
	cefitc=findassociate(cell,'TP CEDE Color C Fit','','');
	cefitd=findassociate(cell,'TP CEDE Color D Fit','','');
	cefitcomb=findassociate(cell,'TP CEDE Color Comb Fit','','');
	cefitnk=findassociate(cell,'TP CEDE Color NK Fit','','');
	cefitnkt=findassociate(cell,'TP CEDE Color NKT Fit','','');	
	titlestr = '';
    dinds = [1:12 15 16 13 14];
    dinds1 = [1:12];
    dinds2 = [15 16];
    dinds3 = [13 14];
    dinds1x = [1:12];
    dinds2x = [13 14];
    dinds3x = [15 16];    
	if ~isempty(cer)&~isempty(ces)&~isempty(cesv),
		if plotnonsig|(cesv.data<0.05), % if sig S and significant variation across all stims
			h=myerrorbar(cer.data(1,dinds1x),cer.data(2,dinds1),cer.data(4,dinds1),cer.data(4,dinds1),'',0.3);
			set(h,'color',[0 0 0],'linewidth',2);
            hold on;
			h=myerrorbar(cer.data(1,dinds2x),cer.data(2,dinds2),cer.data(4,dinds2),cer.data(4,dinds2),'',0.3);
			set(h,'color',[0 0 0],'linewidth',2);
			h=myerrorbar(cer.data(1,dinds3x),cer.data(2,dinds3),cer.data(4,dinds3),cer.data(4,dinds3),'k.',0.3);
			set(h,'color',[0 0 0],'linewidth',2);
			if ~isempty(ceb),
				plot([-100 100],ceb.data(1)*[1 1],'k-','linewidth',2);
				plot([-100 100],(ceb.data(1)+ceb.data(3))*[1 1],'k--','linewidth',2);
				plot([-100 100],(ceb.data(1)-ceb.data(3))*[1 1],'k--','linewidth',2);
			end;
			if fit==1&~isempty(cefit),
				plot(cefit.data(1,dinds1x),cefit.data(2,dinds1),'ms--','linewidth',2);
				plot(cefit.data(1,dinds2x),cefit.data(2,dinds2),'ms--','linewidth',2);
				plot(cefit.data(1,dinds3x),cefit.data(2,dinds3),'ms','linewidth',2);
                
                cefitparams = cefitnk;
				titlestr = [' L = ' num2str(cefitparamsnk.data(1),2) ', S = ' num2str(cefitparamsnk.data(2),2) '.'...
					', LC50=' num2str(cefitparamsnk.data(3),2) ', SC50=' num2str(cefitparamsnk.data(4),2) ...
					', LN=' num2str(cefitparamsnk.data(5),2) ', SN=' num2str(cefitparamsnk.data(6),2) '.'];
				%if ~isempty(cefitc), plot(cefitc.data.fit(1,:),cefitc.data.fit(2,:)+ceb.data(1),'b--'); end;
				%if ~isempty(cefitd), plot(cefitd.data.fit(1,:),cefitd.data.fit(2,:)+ceb.data(1),'c','linewidth',4); end;
				%if ~isempty(cefitcomb), plot(cefitcomb.data.fit(1,:),cefitcomb.data.fit(2,:)+ceb.data(1),'r--'); end;
				%if ~isempty(cefitnkt), plot(cefitnkt.data.fit(1,:),cefitnkt.data.fit(2,:)+ceb.data(1),'g--'); end;
				if ~isempty(cefitnk), plot(cefitnk.data(1,dinds1x),cefitnk.data(2,dinds1),'s-','color',[0.8 0.8 0.8],'linewidth',2); end;
				if ~isempty(cefitnk), plot(cefitnk.data(1,dinds2x),cefitnk.data(2,dinds2),'s-','color',[0.8 0.8 0.8],'linewidth',2); end;
				if ~isempty(cefitnk), plot(cefitnk.data(1,dinds3x),cefitnk.data(2,dinds3),'s','color',[0.8 0.8 0.8],'linewidth',2); end;
			end;
			A = axis;
			axis([0 17 A([3 4])]);
			title([cellname titlestr],'interp','none');
			ylabel('\DeltaF/F');
			xlabel('Stim number');
		else, if ~dontclose, close(gcf); end;
		end;
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
case {'Color Dacey Fig Plot'}, 
	cer = findassociate(cell,'TP CEDE Response curve','',''),
	ceb = findassociate(cell,'TP CEDE Blank Response','','');
	titlestr = '';
	if isempty(cer),
		cer = findassociate(cell,'TP CED Response curve','','');
		ceb = findassociate(cell,'TP CED Blank Response','','');
	end;
	if ~isempty(cer),
		hold on;
		if ~isempty(ceb),
			patch([-100 100 100 -100],ceb.data(1)+ceb.data(3)*[-1 -1 1 1],[0.8 0.8 0.8]);
			plot([-100 100],ceb.data(1)*[1 1],'k--','linewidth',2);
		end;
		h=myerrorbar(cer.data(1,1:12),cer.data(2,1:12),cer.data(4,1:12),cer.data(4,1:12),'',0.3);
		set(h,'color',[0 0 0],'linewidth',2);
		plot([12.5 12.5],[0 0.1],'k','linewidth',4);
		A = axis;
		axis([0 13 A([3 4])]);
		title([cellname titlestr],'interp','none');
		ylabel('\DeltaF/F');
		xlabel('Stim number');
		set(gca,'visible','off');
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
case {'Color Dacey Fit Fig Plot'}, 
	cer = findassociate(cell,'TP CEDE Response curve','',''),
	ceb = findassociate(cell,'TP CEDE Blank Response','','');
	cefit=findassociate(cell,'TP CEDE Color Fit','','');
	cefitd = findassociate(cell,'TP CEDE Color D Fit','','');
	cefitr4 = findassociate(cell,'TP CEDE Color R4 Fit','','');
	cefitparams=findassociate(cell,'TP CEDE Color Fit Params','','');
	cefitparamsnk=findassociate(cell,'TP CEDE Color NK Fit Params','','');
	cefitnk=findassociate(cell,'TP CEDE Color NK Fit','','');
    cefitr4nk=findassociate(cell,'TP CEDE Color R4NK Fit','','');
	if isempty(cer),
		cer = findassociate(cell,'TP CED Response curve','',''),
		ceb = findassociate(cell,'TP CED Blank Response','','');
		cefit=findassociate(cell,'TP CED Color Fit','','');
		cefitparams=findassociate(cell,'TP CED Color Fit Params','','');
		cefitparamsnk=findassociate(cell,'TP CED Color NK Fit Params','','');
		cefitnk=findassociate(cell,'TP CED Color NK Fit','','');	
		cefitd = findassociate(cell,'TP CED Color D Fit','','');
		cefitr4 = findassociate(cell,'TP CED Color R4 Fit','','');
        cefitr4nk=findassociate(cell,'TP CED Color R4NK Fit','','');        
	end;
	titlestr = '';
	hold on;
	if ~isempty(cer),
		if ~isempty(ceb),
			patch([-100 100 100 -100],ceb.data(1)+ceb.data(3)*[-1 -1 1 1],[0.8 0.8 0.8]);
			plot([-100 100],ceb.data(1)*[1 1],'k--','linewidth',2);
		end;
		h=myerrorbar(cer.data(1,1:12),cer.data(2,1:12),cer.data(4,1:12),cer.data(4,1:12),'',0.3);
		set(h,'color',[0 0 0],'linewidth',2);
		%delete(h(2));
		if fit==1&~isempty(cefit),
			if ~exist('modelnum'), [gf,modelnum]=colorgof2(cell); else, gf  = colorgof2(cell); end;
            plot(cefit.data(1,1:12),cefit.data(2,1:12),'m--','linewidth',2);
            plot(cefitnk.data(1,1:12),cefitnk.data(2,1:12),'g--','linewidth',2);
            if modelnum==2,
				plot(cefitnk.data(1,1:12),cefitnk.data(2,1:12),'k--','linewidth',2);
				titlestr = [' L = ' num2str(cefitparamsnk.data(1),2) ', S = ' num2str(cefitparamsnk.data(2),2) '.'...
					', LC50=' num2str(cefitparamsnk.data(3),2) ', SC50=' num2str(cefitparamsnk.data(4),2) ...
					', LN=' num2str(cefitparamsnk.data(5),2) ', SN=' num2str(cefitparamsnk.data(6),2) '.'];
			elseif modelnum==1,
				plot(cefit.data(1,1:12),cefit.data(2,1:12),'k:','linewidth',2);
				titlestr = [' L = ' num2str(cefitparams.data(1),2) ', S = ' num2str(cefitparams.data(2),2) '.'];
			elseif modelnum==3,
				plot(cefitd.data.fit(1,1:12),cefitd.data.fit(2,1:12),'k-.','linewidth',2);
				titlestr = ['L = ' num2str(cefitd.data.l,2) ', S = ' num2str(cefitd.data.s,2) '.'];
            elseif modelnum==4,
				plot(cefitr4.data.fit(1,1:12),cefitr4.data.fit(2,1:12),'k-.','linewidth',2);
				titlestr = ['SE = ' num2str(cefitr4.data.se,2) ', LE = ' num2str(cefitr4.data.le,2) 'SI = ' num2str(cefitr4.data.si,2) ', LI = ' num2str(cefitr4.data.li,2) '.'];
                myfig = gcf;
                figure;
                t1 = 0:0.001:pi; t2 = pi:0.001:2*pi; t3 = 0:.001:1; X = [ 0 0 1 1];
                [p_nlvsln, p_lnvsmn, p_rctvsln, p_nlvsrct, p_r4vsln, p_r4vsnl, linvsr4, nlvsr4, whichmodel]=isnonlinearcolor(cell);
                [gfLNK, gfmodelnum] = colorgof(cell);
                subplot(2,3,1);
                plot(t1,cefitr4.data.se*sin(t1),'b'); hold on;
                plot(t1,cefitr4.data.le*sin(t1),'g'); hold on;
                plot(t2,-cefitr4.data.si*sin(t2),'b'); hold on;
                plot(t2,-cefitr4.data.li*sin(t2),'g'); hold on;
                hold off; cla;
                p(1)=patch([1+X],[0 cefitr4.data.se cefitr4.data.se 0],[0 0 1]);
                p(2)=patch([2+X],[0 cefitr4.data.le cefitr4.data.le 0],[0 1 0]);
                p(3)=patch([3+X],[0 cefitr4.data.si cefitr4.data.si 0],[0 0 1]);
                p(4)=patch([4+X],[0 cefitr4.data.li cefitr4.data.li 0],[0 1 0]);
                set(p([1 3]),'facecolor',[0 0 1],'edgecolor',[0 0 1]);
                set(p([2 4]),'facecolor',[0 1 0],'edgecolor',[0 1 0]);
                hold on;
                plot([5 5],[0 1],'k','linewidth',2);
                text(3,1,['GF=' num2str(gf,2) '. WM=' int2str(whichmodel) '.']);
                title([cellname titlestr],'interp','none');
                ax=axis;
                axis([0 6 max(abs(ax([3 4])))*[-1 1]]);
                box off; axis off;
                subplot(2,3,2);
                plot(t1,cefitr4nk.data.se*sin(t1),'b'); hold on;
                plot(t1,cefitr4nk.data.le*sin(t1),'g'); hold on;
                plot(t2,-cefitr4nk.data.si*sin(t2),'b'); hold on;
                plot(t2,-cefitr4nk.data.li*sin(t2),'g'); hold on;
                hold off; cla;
                p(1)=patch([1+X],[0 cefitr4nk.data.se cefitr4nk.data.se 0],[0 0 1]);
                p(2)=patch([2+X],[0 cefitr4nk.data.le cefitr4nk.data.le 0],[0 1 0]);
                p(3)=patch([3+X],[0 cefitr4nk.data.si cefitr4nk.data.si 0],[0 0 1]);
                p(4)=patch([4+X],[0 cefitr4nk.data.li cefitr4nk.data.li 0],[0 1 0]);
                set(p([1 3]),'facecolor',[0 0 1],'edgecolor',[0 0 1]);
                set(p([2 4]),'facecolor',[0 1 0],'edgecolor',[0 1 0]);
                hold on;
                plot([5 5],[0 1],'k','linewidth',2);
				titlestr = ['SE = ' num2str(cefitr4nk.data.se,2) ', LE = ' num2str(cefitr4nk.data.le,2) 'SI = ' num2str(cefitr4nk.data.si,2) ', LI = ' num2str(cefitr4nk.data.li,2) '.'];
                title([cellname titlestr],'interp','none');
                ax=axis;
                axis([0 6 max(abs(ax([3 4])))*[-1 1]]);
                box off; axis off;                
                subplot(2,3,3);
                plot(t3,naka_rushton_func(t3,cefitr4nk.data.lc0,cefitr4nk.data.ln0),'g'); hold on;
                plot(t3,naka_rushton_func(t3,cefitr4nk.data.sc0,cefitr4nk.data.sn0),'b');
                axis([0 1 0 1]); box off; axis off;
                subplot(2,3,4);
                plot(t1,cefitparams.data(1)*sin(t1),'g'); hold on;
                plot(t1,cefitparams.data(2)*sin(t1),'b'); hold on;
                plot(t2,cefitparams.data(1)*sin(t2),'g'); hold on;
                plot(t2,cefitparams.data(2)*sin(t2),'b'); hold on;
				titlestr = [' L = ' num2str(cefitparams.data(1),2) ', S = ' num2str(cefitparams.data(2),2) '.']; 
                hold off; cla;
                p(1)=patch([1+X],[0 cefitparams.data(2) cefitparams.data(2) 0],[0 0 1]);
                p(2)=patch([2+X],[0 cefitparams.data(1) cefitparams.data(1) 0],[0 1 0]);
                set(p([1]),'facecolor',[0 0 1],'edgecolor',[0 0 1]);
                set(p([2]),'facecolor',[0 1 0],'edgecolor',[0 1 0]);
                hold on; plot([4 4],[0 0.5],'k','linewidth',2);
		%[COG,CAG,SOG,WM] = countmyopponencies(cell);
		COG=0; CAG=0;SOG=0;WM=0;
                if gfmodelnum==1, text(2.5, 0.5,['GF=' num2str(gfLNK,2) ';CW,CA,SP=' int2str([ COG CAG SOG])]); end;
                ax=axis;
                axis([0 6 max(abs(ax([3 4])))*[-1 1]]);
                title([cellname titlestr],'interp','none');
                box off; axis off;
                subplot(2,3,5);
                p(1)=patch([1+X],[0 cefitparamsnk.data(2) cefitparamsnk.data(2) 0],[0 0 1]);
                p(2)=patch([2+X],[0 cefitparamsnk.data(1) cefitparamsnk.data(1) 0],[0 1 0]);
                set(p([1]),'facecolor',[0 0 1],'edgecolor',[0 0 1]);
                set(p([2]),'facecolor',[0 1 0],'edgecolor',[0 1 0]);
                hold on; plot([4 4],[0 0.5],'k','linewidth',2);

                if gfmodelnum==2, text(2.5, 0.5,['GF=' num2str(gfLNK,2) ';CW,CA,SP=' int2str([ COG CAG SOG]) ]); end;
                ax=axis;
                axis([0 6 max(abs(ax([3 4])))*[-1 1]]);
                title([cellname titlestr],'interp','none');
                box off; axis off;
                subplot(2,3,6);
                plot(t3,naka_rushton_func(t3,cefitparamsnk.data(3),cefitparamsnk.data(5)),'g'); hold on;
                plot(t3,naka_rushton_func(t3,cefitparamsnk.data(4),cefitparamsnk.data(6)),'b');
                axis([0 1 0 1]); box off; axis off;
				titlestr = [' L = ' num2str(cefitparamsnk.data(1),2) ', S = ' num2str(cefitparamsnk.data(2),2) '.'...
					', LC50=' num2str(cefitparamsnk.data(3),2) ', SC50=' num2str(cefitparamsnk.data(4),2) ...
					', LN=' num2str(cefitparamsnk.data(5),2) ', SN=' num2str(cefitparamsnk.data(6),2) '.'];
                title([cellname titlestr],'interp','none');
                figure;
        		h=myerrorbar(cer.data(1,1:16),cer.data(2,1:16),cer.data(4,1:16),cer.data(4,1:16),'',0.3);    
                hold on;
                plot(cefitr4.data.fit(1,1:16),cefitr4.data.fit(2,1:16),'k--','linewidth',2);
				plot(cefitr4nk.data.fit(1,1:16),cefitr4nk.data.fit(2,1:16),'k:','linewidth',2);                
				plot(cefit.data(1,1:16),cefit.data(2,1:16),'m--','linewidth',2);                
				plot(cefitnk.data(1,1:12),cefitnk.data(2,1:12),'m:','linewidth',2);
                figure(myfig);
				titlestr = ['SE = ' num2str(cefitr4.data.se,2) ', LE = ' num2str(cefitr4.data.le,2) 'SI = ' num2str(cefitr4.data.si,2) ', LI = ' num2str(cefitr4.data.li,2) '.'];                
            elseif modelnum==5,
				plot(cefitr4nk.data.fit(1,1:12),cefitr4nk.data.fit(2,1:12),'k-.','linewidth',2);
				titlestr = ['SE = ' num2str(cefitr4nk.data.se,2) ', LE = ' num2str(cefitr4nk.data.le,2) 'SI = ' num2str(cefitr4nk.data.si,2) ', LI = ' num2str(cefitr4nk.data.li,2) '.'];
                myfig = gcf;
                figure;
                t1 = 0:0.001:pi; t2 = pi:0.001:2*pi;
                plot(t1,cefitr4nk.data.se*sin(t1),'b'); hold on;
                plot(t1,cefitr4nk.data.le*sin(t1),'g'); hold on;
                plot(t2,-cefitr4nk.data.si*sin(t2),'b'); hold on;
                plot(t2,-cefitr4nk.data.li*sin(t2),'g'); hold on;
                title([cellname titlestr],'interp','none');
                figure;
        		h=myerrorbar(cer.data(1,1:16),cer.data(2,1:16),cer.data(4,1:16),cer.data(4,1:16),'',0.3);    
                hold on;
                plot(cefitr4.data.fit(1,1:16),cefitr4.data.fit(2,1:16),'m--','linewidth',2);
				plot(cefitr4nk.data.fit(1,1:16),cefitr4nk.data.fit(2,1:16),'k--','linewidth',2);                
                figure(myfig);
			end;
        end;
		plot([12.5 12.5],[0 0.1],'k','linewidth',4);
		A = axis;
		axis([0 17 A([3 4])]);
		title([cellname titlestr],'interp','none');
		ylabel('\DeltaF/F');
		xlabel('Stim number');
	else, if ~dontclose, close(gcf); end;
	end;
	proceed = 0;
otherwise,
	proceed = 0;
	disp(['Do not know how to plot ' property '.']);
	return;
end;


if proceed,  % curve should be [xlocs; means; stddevs; stderrs]
	h = []; h2 =[];
	h1 = plot(resp.curve(1,:),resp.curve(2,:),'ko');
	hold on;
	if fit==1, h2 = plot(fitx,fity,'k');
	else, h2 = plot(resp.curve(1,:),resp.curve(2,:),'k');
	end;
	title([cellname ' ' property],'interp','none');
	if altcurve==1,
		h3 = plot(altresp.curve(1,:),altresp.curve(2,:),'bo');
		if fit==1, h4=plot(altfitx,altfity,'b');
		else, h4 = plot(altresp.curve(1,:),altresp.curve(2,:),'b');
		end;
	end;
end;

if eb==1&proceed,
    if length(resp.curve(1,:))>1, ebarwidth = 0.3*diff(resp.curve(1,[2 1]));
    else, ebarwidth = 1;
    end;
	h=myerrorbar(resp.curve(1,:),resp.curve(2,:),...
			resp.curve(4,:),resp.curve(4,:),'',ebarwidth);
	delete(h(2));
	set(h(1),'linewidth',1,'color',0*[1 1 1]);
	h = h(1);
	if altcurve==1,
		h_=myerrorbar(altresp.curve(1,:),altresp.curve(2,:),...
			altresp.curve(4,:),altresp.curve(4,:),'',ebarwidth);
		delete(h_(2));
		set(h_(1),'linewidth',1,'color',[0 0 1]);
		h_ = h_(1);
	end;
end;

if proceed,
	ylabel(ylab); xlabel(xlab);
	title(cellname,'interp','none');

	h0 = [h;h1;h2];

	set(gca,'box','off');
	A = axis;
	axis([min(fitx) max(fitx) A(3) A(4)]);


	myud = struct('cell',cell,'cellname',cellname,'property',property,'eb',eb,'fit',fit);

	if ~nopushbutton,
		mybt = uicontrol('style','pushbutton','string','all','units','normalized','position',[0.95 0.00 0.05 0.05],'callback','plottpresponse','userdata',myud);
	end;


end;


function somegoodresp=plotrespnamesallcolors(cell,begstr,respname,fitname,eb,fit,signame,usesig,blankrespname,usepolar,subtractblank,plotblankrange)
[allstimids,begStrs,plotcolors,longnames] = FitzColorID;
somegoodresp = 0;
axis;
hold on;
for i=1:length(allstimids)
	ras = findassociate(cell,[begstr ' ' begStrs{i} ' ' respname],'','');
	fita = findassociate(cell,[begstr ' ' begStrs{i} ' ' fitname],'','');
	siga = findassociate(cell,[begstr ' ' begStrs{i} ' ' signame],'','');
	if ~isempty(blankrespname), bra = findassociate(cell,[begstr ' ' begStrs{i} ' ' blankrespname],'','');
	else, bra = [];
	end;
	if isempty(siga), sigval = Inf; else, sigval = siga.data; end;
	if (usesig==0)|(usesig>0&sigval<0.05),
		somegoodresp = 1;
        if ~usepolar,
            if ~isempty(ras) & eb,
                if subtractblank&~isempty(bra),
                    h=myerrorbar(ras.data(1,:),ras.data(2,:)-bra.data(1),ras.data(4,:),ras.data(4,:));
                    set(h,'color',plotcolors(i,:));
                    delete(h(2));                   
                else,
                    h=myerrorbar(ras.data(1,:),ras.data(2,:),ras.data(4,:),ras.data(4,:));
                    set(h,'color',plotcolors(i,:));
                    delete(h(2));
                    if subtractblank&isempty(bra), warning(['No blank data to subtract.']); end;
                end;
            end;
            if ~isempty(fita) & fit,
                if subtractblank&~isempty(bra),
                    h=plot(fita.data(1,:),fita.data(2,:)-bra.data(1));
                    set(h,'linewidth',2,'color',plotcolors(i,:));		
                else,
                    h=plot(fita.data(1,:),fita.data(2,:));
                    set(h,'linewidth',2,'color',plotcolors(i,:));
                    if subtractblank&isempty(bra), warning(['No blank data to subtract.']); end;
                end;
            end;
            if ~isempty(bra)&(~subtractblank|plotblankrange),
                h=plot([-100000 100000],bra.data(1)*[1 1],'k');
                h1=plot([-100000 100000],(bra.data(1)+bra.data(3))*[1 1],'k--');
                h2=plot([-100000 100000],(bra.data(1)-bra.data(3))*[1 1],'k--');
                set(h,'linewidth',2);
                set(h1,'linewidth',2);
                set(h2,'linewidth',2);
            end;
        else,
            if ~isempty(ras),
                hh=mmpolar(ras.data(1,:)*pi/180,ras.data(2,:),'ko','style','compass','TTickDelta',45,'RGridLineWidth',2,'TGridLineWidth',2,'fontname','arial','border','off','fontsize',16);
                set(hh,'color',plotcolors(i,:));
                hold on;
            end;
            if ~isempty(fita)&fit,
                hh=mmpolar(fita.data(1,:)*pi/180,fita.data(2,:),'style','compass','TTickDelta',45,'RGridLineWidth',2,'TGridLineWidth',2,'fontname','arial','border','off','fontsize',16);
                set(hh,'linewidth',2,'color',plotcolors(i,:));
            end;
        end;
	end;

end;
if somegoodresp == 0, close(gcf); end;
