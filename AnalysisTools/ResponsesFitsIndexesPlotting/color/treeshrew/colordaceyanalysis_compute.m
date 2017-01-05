function [assoc]=colordaceyanalysis_compute(respstruct)

%  COLORDACEYANALYSIS_COMPUTE - Analyze color exchange data
%
%  [ASSOC]=COLORDACEYANALYSIS_COMPUTE(RESPSTRUCT)
%
%  Analyzes the color exchange Dacey-like tests.
%
%  Measures gathered from the CED Test (associate name in quotes):
%
%  'CED visual response'          |   0/1 Was response significant w/ P<0.05?
%  'CED visual response p'        |   Anova p across stims and blank (if available)
%  'CED varies'                   |   0/1 Was response significant across CE?
%  'CED varies p'                 |   Anova p across stims
%  'CED sig S cone'               |   0/1 Is S-cone response significant?
%  'CED near S-isolating p values'|   P values of the 3 stims closest to
%                                 |        the S-cone isolating stim
%  'CED sig L cone'               |   0/1 Is L-cone response significant?
%  'CED near L-isolating p values'|   P values of the 3 stims closest to
%                                 |        the L-cone isolating stim
%  'CED Response curve'           |   Responses to the 10 stimuli
%  'CED Response struct'          |   Response structure including
%                                            individual trials information
%  'CED Blank Response'           |   Response to the blank stimulus
%  'CED Color Fit Params'         |   [l s err r^2], estimated contribution of l, s
%                                 |     err is squared error, r^2 is r squared 
%  'CED Color Fit'                |   1st row is stim numbers, 2nd row is fit
%                                 |        to R=abs(l*Lc+s*Sc)
%  'CED Peak Stim'                |   Which stim number was max?
%  'CED Peak Type'                |   'L dominated','S dominated','opponent'
%                                 |       'unclear'
%  If the function is called with no arguments then ASSOC is a list of
%  associate types that COLOREXCHANGEANALYSIS_COMPUTE returns.

if nargin==0,
        % edit these to reflect new indices
	assoc = { 'CED visual response','CED visual response p','CED varies','CED varies p',...
        'CED sig S cone','CED near S-isolating p values','CED Response curve','CED Response struct',...
		'CED Blank Response','CED sig L cone','CED near L-isolating p values',...
		'CED Color Fit Params','CED Color Fit','CED Peak Stim','CED Peak Type'};
	return;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

do_naka_rushton = 1;

maxresp = []; 
fdtpref = []; 
circularvariance = [];
tuningwidth = [];

resp = respstruct.curve;  % example: find the maximum location
  %%% resp(1,:) is the 'x' variable; if the user selected 'analyzebystimnumber',
  %%% it will be equal to 1..numStims.  You 
  %%% might want to edit resp(1,:) to reflect stimulus parameter rather
  %%% than stimulus number; see how this is done in tpotanalysis

[maxresp,if0]=max(resp(2,:)); 
cepref = [resp(1,if0)];  % which stim position is max?
CEDtype='unclear';
if cepref>=5&cepref<=9,
	CEDtype='opponent';
elseif cepref>=10,
	CEDtype='L dominated';
elseif cepref<=4,
	CEDtype='S dominated';
end;
assoc(end+1)=myassoc('CED Peak Type',CEDtype);
assoc(end+1)=myassoc('CED Peak Stim',cepref);

  % if there is no real blank but there are 14 stims, assume the 14 is
  % blank
if ~isfield(respstruct,'blankind')&length(resp(1,:)==14),
    respstruct.blankresp = resp(2:4,14)';
    respstruct.blankind = respstruct.ind{14};
    resp = resp(:,1:13);
    respstruct.ind = respstruct.ind(1:13);
end;

 % is there any variation across stimuli?
[CED_varies_p,CED_visresp_p] = neural_response_significance(respstruct);

[h,p1] = ttest2(respstruct.ind{2},respstruct.blankind,0.05,'right');
[h,p2] = ttest2(respstruct.ind{3},respstruct.blankind,0.05,'right');
[h,p3] = ttest2(respstruct.ind{4},respstruct.blankind,0.05,'right');
 % are all three above blank?  must use higher alpha to have 0.05 prob
alpha = 0.25;
sigS = (p1<alpha)&(p2<alpha)&(p3<alpha);
[h,pl1] = ttest2(respstruct.ind{8},respstruct.blankind,0.05,'right');
[h,pl2] = ttest2(respstruct.ind{9},respstruct.blankind,0.05,'right');
[h,pl3] = ttest2(respstruct.ind{10},respstruct.blankind,0.05,'right');
 % are all three above blank?  must use higher alpha to have 0.05 prob
alpha = 0.25;
sigL = (pl1<alpha)&(pl2<alpha)&(pl3<alpha);

berr = Inf;  sb = 0; lb = 0; r2b = 0;
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(3); % cone contrasts

for i=1:20, % use 20 initial seeds to find global minimum
	[l,s,err,r2,fitb]=color_fit(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10);
	if err<berr,
			sb = s; lb = l; berr = err; r2b = r2; bfit = fitb;
	end;
end;
bfit = [1:13 ;bfit+respstruct.blankresp(1)];

if do_naka_rushton,
	berrNk = Inf; sbnk=0;lbnk=0;lc0b=0.5;sc0b=0.5; r2bnk=0; snb=0; lnb=0;
	for i=1:20, % use 20 initial seeds to find global minimum
		[l,s,lc0,sc0,ln,sn,err,r2]=color_fit_nk(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,0.5,0.5,0,0);
		if err<berrNk,
				sbnk = s; lbnk = l; lc0b=lc0; sc0b=sc0; berrNk = err; r2bnk = r2; lnb=ln;snb=sn;
		end;
	end;
	bfitnk = [1:13 ;abs(lbnk*naka_rushton_func(Lc,lc0b,lnb)+sbnk*naka_rushton_func(Sc,sc0b,snb))+respstruct.blankresp(1)];
	assoc(end+1)=myassoc('CED Color NK Fit Params',[lbnk sbnk lc0b sc0b lnb snb berrNk r2bnk]);
	assoc(end+1) = myassoc('CED Color NK Fit',bfitnk);

    berrR=Inf; bfitR = []; sbR = []; lbR = []; rbR = []; r2bR = [];
    for i=1:20, % use 20 initial seeds to find global minimum
        [l,s,r,err,r2,fitb]=color_fit_rods(Lc,Sc,Rc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,randn/10);
        if err<berrR,
                sbR = s; lbR = l; rbR = r; berrR = err; r2bR = r2; bfitR = fitb;
        end;
    end;
    if ~isempty(bfitR), 
        bfitR = [1:13 ;bfit+respstruct.blankresp(1)];
    end;
    assoc(end+1) = myassoc('CED Color R Fit Params',[lbR sbR rbR berrR r2bR]);
    assoc(end+1) = myassoc('CED Color R Fit',bfitR);    
    
	cParams.err = Inf; cParams.l=0; cParams.s=0; cParams.c=0; cParams.r2=0; cParams.fit=0;
	for i=1:20,
		[l,s,c,err,r2,myfit]=color_fitc(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10);
		if err<cParams.err,
			cParams.err=err; cParams.l=l; cParams.s=s; cParams.c=c; cParams.r2=r2; cParams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		cParams.fit = [1:13; cParams.fit];
		assoc(end+1) = myassoc('CED Color C Fit',cParams);
	end;
	
	DParams.err = Inf; DParams.l=0; DParams.s=0; DParams.d=0; DParams.r2=0; DParams.fit=0;
	for i=1:20,
		[l,s,d,err,r2,myfit]=color_fit_rect(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,randn/10);
		if err<DParams.err,
			DParams.err=err; DParams.l=l; DParams.s=s; DParams.d=d; DParams.r2=r2; DParams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		DParams.fit = [1:13; DParams.fit];
		assoc(end+1) = myassoc('CED Color D Fit',DParams);
	end;

        R3Params.err = Inf; R3Params.l=0; R3Params.s=0; R3Params.d=0; R3Params.r2=0; R3Params.fit=0;
        for i=1:20,
                [d,l_s,err,r2,myfit]=color_fit_rect3(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10);
                if err<R3Params.err,
                        R3Params.err=err; R3Params.l_s=l_s; R3Params.d=d; R3Params.r2=r2; R3Params.fit=myfit;
                end;
        end;
        if ~isnan(err),
                R3Params.fit = [1:13; R3Params.fit+respstruct.blankresp(1)];
                assoc(end+1) = myassoc('CED Color R3 Fit',R3Params);
        end;

        R3NKParams.err = Inf; R3NKParams.l=0; R3NKParams.s=0; R3NKParams.d=0; R3NKParams.r2=0; R3NKParams.fit=0;
        for i=1:20,
                [d,l_s,lc0,sc0,ln0,sn0,err,r2,myfit]=color_fit_rect3nk(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,0.5,0.5,0,0);
                if err<R3NKParams.err,
                        R3NKParams.err=err; R3NKParams.l_s=l_s; R3NKParams.d=d; R3NKParams.r2=r2; R3NKParams.fit=myfit;
                        R3NKParams.lc0 = lc0; R3NKParams.sc0 = sc0; R3NKParams.ln0 = ln0; R3NKParams.sn0 = sn0;
                end;
        end;
        if ~isnan(err),
                R3NKParams.fit = [1:13; R3NKParams.fit+respstruct.blankresp(1)];
                assoc(end+1) = myassoc('CED Color R3NK Fit',R3NKParams);
        end;

        R4Params.err = Inf; R4Params.l=0; R4Params.s=0; R4Params.d=0; R4Params.r2=0; R4Params.fit=0;
        for i=1:20,
                [se,si,le,li,err,r2,myfit]=color_fit_rect4(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn,randn,randn,randn);
                if err<R4Params.err,
                        R4Params.err=err; R4Params.se=se; R4Params.si=si; R4Params.le=le; R4Params.li=li; R4Params.r2=r2; R4Params.fit=myfit;
                end;
        end;
        if ~isnan(err),
                R4Params.fit = [1:13; R4Params.fit+respstruct.blankresp(1)];
                assoc(end+1) = myassoc('CED Color R4 Fit',R4Params);
        end;

        R4NKParams.err = Inf; R4NKParams.l=0; R4NKParams.s=0; R4NKParams.d=0; R4NKParams.r2=0; R4NKParams.fit=0;
        for i=1:20,
                [se,si,le,li,lc0,sc0,ln0,sn0,err,r2,myfit]=color_fit_rect4nk(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn,randn,randn,randn,0.5,0.5,0,0);
                if err<R4NKParams.err,
                        R4NKParams.err=err; R4ParamsNK.se=se; R4ParamsNK.si=si; R4ParamsNK.le=le; R4ParamsNK.li=li; R3NKParams.r2=r2; R4NKParams.fit=myfit;
                        R4NKParams.lc0 = lc0; R4NKParams.sc0 = sc0; R4NKParams.ln0 = ln0; R4NKParams.sn0 = sn0;
                end;
        end;
        if ~isnan(err),
                R4NKParams.fit = [1:13; R4NKParams.fit+respstruct.blankresp(1)];
                assoc(end+1) = myassoc('CED Color R4NK Fit',R3NKParams);
        end;

	berrNkR = Inf;sbnkR = 0; lbnkR = 0; lc0bR=0; sc0bR=0; r2bnkR = 0; lnbR=0;snbR=0;
                rbnkR = 0; rc0bR=0; rnbR=0;
	for i=1:20, % use 20 initial seeds to find global minimum
		[l,s,r,lc0,sc0,rc0,ln,sn,rn,err,r2]=color_fit_nk_rods(Lc,Sc,Rc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,randn/10,0.5,0.5,0.5,0,0,0);
		if err<berrNkR,
				sbnkR = s; lbnkR = l; lc0bR=lc0; sc0bR=sc0; berrNkR = err; r2bnkR = r2; lnbR=ln;snbR=sn;
                rbnkR = r; rc0bR=rc0; rnbR=rn;
		end;
	end;
	bfitnkR = [1:13 ;abs(lbnkR*naka_rushton_func(Lc,lc0bR,lnbR)+sbnkR*naka_rushton_func(Sc,sc0bR,snbR)+rbnkR*naka_rushton_func(Rc,rc0bR,rnbR))+respstruct.blankresp(1)];
	assoc(end+1)=myassoc('CED Color NKR Fit Params',[lbnkR sbnkR rbnkR lc0bR sc0bR rc0bR lnbR snbR rnbR berrNkR r2bnkR]);
	assoc(end+1) = myassoc('CED Color NKR Fit',bfitnkR);        

    R4RParams.err = Inf; R4RParams.se=0; R4RParams.si=0; R4RParams.le=0; R4RParams.li=0; R4RParams.r2=0; R4RParams.fit=0; R4RParams.re=0; R4RParams.ri=0;
    for i=1:40,
            [se,si,le,li,re,ri,err,r2,myfit]=color_fit_rect4_rods(Lc,Sc,Rc,resp(2,1:13)-respstruct.blankresp(1),randn,randn,randn,randn,randn,randn);
            if sqrt(err)+sum(abs([se si le li re ri]))/100<sqrt(R4RParams.err)+sum(abs([R4RParams.se R4RParams.si R4RParams.le R4RParams.li R4RParams.re R4RParams.ri]))/100,
                    R4RParams.err=err; R4RParams.se=se; R4RParams.si=si; R4RParams.le=le; R4RParams.li=li; R4RParams.r2=r2; R4RParams.fit=myfit;
                    R4RParams.re = re; R4RParams.ri = ri;
            end;
    end;
    if ~isnan(err),
            R4RParams.fit = [1:13; R4RParams.fit+respstruct.blankresp(1)];
            assoc(end+1) = myassoc('CED Color R4R Fit',R4RParams);
    end;    
    
	combparams.err = Inf; combparams.l1=0; combparams.s1=0; combparams.l2=0; combparams.s2=0; combparams.r2=0; combparams.fit=0;
	for i=1:20,
		[l1,s1,l2,s2,err,r2,myfit]=color_fit2(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,randn/10,randn/10);
		if err<combparams.err,
			combparams.err=err; combparams.l1=l1; combparams.s1=s1; combparams.l2=l2; combparams.s2=s2; combparams.r2=r2; combparams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		combparams.fit = [1:13; combparams.fit];
		assoc(end+1) = myassoc('CED Color Comb Fit',combparams);
	end;

	nktparams.err = Inf; nktparams.l=0; nktparams.s=0; nktparams.r50=0; nktparams.N=0; nktparams.r2=0; nktparams.fit=0;
	for i=1:20,
		[l,s,r50,N,err,r2,myfit]=color_fit_nkt(Lc,Sc,resp(2,1:13)-respstruct.blankresp(1),randn/10,randn/10,0,2);
		if err<nktparams.err,
			nktparams.err=err; nktparams.l=l; nktparams.s=s; nktparams.r50=r50; nktparams.N=N; nktparams.r2=r2; nktparams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		nktparams.fit = [1:13; nktparams.fit];
		assoc(end+1) = myassoc('CED Color NKT Fit',nktparams);
	end;
end;

assoc(end+1)=myassoc('CED varies',CED_varies_p<0.05);
assoc(end+1)=myassoc('CED varies p',CED_varies_p);
if exist('CED_visresp_p')==1,
	assoc(end+1)=myassoc('CED visual response',CED_visresp_p<0.05);
	assoc(end+1)=myassoc('CED visual response p',CED_visresp_p);
end;
assoc(end+1)=myassoc('CED near S-isolating p values',[p1 p2 p3]);
assoc(end+1)=myassoc('CED sig S cone',sigS);
assoc(end+1)=myassoc('CED Response curve',resp);
assoc(end+1)=myassoc('CED Response struct',respstruct);
if isfield(respstruct,'blankresp'),
	assoc(end+1)=myassoc('CED Blank Response',respstruct.blankresp);
end;
assoc(end+1)=myassoc('CED Color Fit Params',[l s err r2]);
assoc(end+1) = myassoc('CED Color Fit',bfit);

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

