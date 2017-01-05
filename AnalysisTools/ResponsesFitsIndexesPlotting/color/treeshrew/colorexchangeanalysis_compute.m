function [assoc]=colorexchangeanalysis_compute(respstruct)

%  COLOREXCHANGEANALYSIS_COMPUTE - Analyze color exchange data
%
%  [ASSOC]=COLOREXCHANGEANALYSIS_COMPUTE(RESPSTRUCT)
%
%  Analyzes the color exchange tests.
%
%  Measures gathered from the CE Test (associate name in quotes):
%
%  'CE visual response'           |   0/1 Was response significant w/ P<0.05?
%  'CE visual response p'         |   Anova p across stims and blank (if available)
%  'CE varies'                    |   0/1 Was response significant across CE?
%  'CE varies p'                  |   Anova p across stims
%  'sig S cone'                   |   0/1 Is S-cone response significant?
%  'near S-isolating p values'    |   P values of the 3 stims closest to
%                                 |        the S-cone isolating stim
%  'CE Response curve'            |   Responses to the 10 stimuli
%  'CE Response struct'           |   Response structure including
%                                            individual trials information
%  'CE Blank Response'            |   Response to the blank stimulus
%  'CE Color Fit Params'          |   [l s err r^2], estimated contribution of l, s
%                                 |     err is squared error, r^2 is r squared 
%  'CE Color Fit'                 |   1st row is stim numbers, 2nd row is fit
%                                 |        to R=abs(l*Lc+s*Sc)
%
% Experimental, may be present or not:
%  'CE Color NK Fit Params'       |   [l s lc0 sc0 err r^2], estimated
%                                          contribution of l,s, half
%                                          maximum of cone contrasts, err, r^2
%  'CE Color NK Fit'              |   1st row is stim numbers, 2nd row is fit
%                                 |        to R=abs(l*NR(Lc)+s*NR(Sc))
%                                 |        NR(c)=c./(abs(c)+c0)
%  'CE Color C Fit Params'
%  'CE Color C Fit'
%
%  If the function is called with no arguments then ASSOC is a list of
%  associate types that COLOREXCHANGEANALYSIS_COMPUTE returns.

do_naka_rushton = 1;

if nargin==0,
        % edit these to reflect new indices
	assoc = { 'CE visual response','CE visual response p','CE varies','CE varies p',...
        'sig S cone','near S-isolating p values','CE Response curve','CE Response struct',...
		'CE Blank Response',...
		'CE Color Fit Params','CE Color Fit','CE Color NK Fit Params','CE Color NK Fit'};
	return;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

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

  % if there is no real blank but there are 11 stims, assume the 11th is
  % blank
if ~isfield(respstruct,'blankind')&length(resp(1,:)==11),
    respstruct.blankresp = resp(2:4,11)';
    respstruct.blankind = respstruct.ind{11};
    resp = resp(:,1:10);
    respstruct.ind = respstruct.ind(1:10);
end;

 % is there any variation across stimuli?
[ce_varies_p,ce_visresp_p] = neural_response_significance(respstruct);

[h,p1] = ttest2(respstruct.ind{4},respstruct.blankind,0.05,'right');
[h,p2] = ttest2(respstruct.ind{5},respstruct.blankind,0.05,'right');
[h,p3] = ttest2(respstruct.ind{6},respstruct.blankind,0.05,'right');
 % are all three above blank?  must use higher alpha to have 0.05 prob
alpha = 0.25;
sigS = (p1<alpha)&(p2<alpha)&(p3<alpha);

berr = Inf;  sb = 0; lb = 0; r2b = 0;
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(1); % cone contrasts

for i=1:20, % use 20 initial seeds to find global minimum
	[l,s,err,r2]=color_fit(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10);
	if err<berr,
			sb = s; lb = l; berr = err; r2b = r2;
	end;
end;
bfit = [1:10 ;abs(lb*Lc+sb*Sc)+respstruct.blankresp(1)];

if do_naka_rushton,
	berrNk = Inf; sbnk=0;lbnk=0;lc0b=0.5;sc0b=0.5; r2bnk=0; snb=0; lnb=0;
	for i=1:20, % use 20 initial seeds to find global minimum
		[l,s,lc0,sc0,ln,sn,err,r2]=color_fit_nk(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10,0.5,0.5,0,0);
		if err<berrNk,
				sbnk = s; lbnk = l; lc0b=lc0; sc0b=sc0; berrNk = err; r2bnk = r2; lnb=ln;snb=sn;
		end;
	end;
	bfitnk = [1:10 ;abs(lbnk*naka_rushton_func(Lc,lc0b,lnb)+sbnk*naka_rushton_func(Sc,sc0b,snb))+respstruct.blankresp(1)];
	assoc(end+1)=myassoc('CE Color NK Fit Params',[lbnk sbnk lc0b sc0b lnb snb berrNk r2bnk]);
	assoc(end+1) = myassoc('CE Color NK Fit',bfitnk);
	
	cParams.err = Inf; cParams.l=0; cParams.s=0; cParams.c=0; cParams.r2=0; cParams.fit=0;
	for i=1:20,
		[l,s,c,err,r2,myfit]=color_fitc(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10);
		if err<cParams.err,
			cParams.err=err; cParams.l=l; cParams.s=s; cParams.c=c; cParams.r2=r2; cParams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		cParams.fit = [1:10; cParams.fit];
		assoc(end+1) = myassoc('CE Color C Fit',cParams);
	end;
	
	DParams.err = Inf; DParams.l=0; DParams.s=0; DParams.d=0; DParams.r2=0; DParams.fit=0;
	for i=1:20,
		[l,s,d,err,r2,myfit]=color_fit_rect(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10,randn/10);
		if err<DParams.err,
			DParams.err=err; DParams.l=l; DParams.s=s; DParams.d=d; DParams.r2=r2; DParams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		DParams.fit = [1:10; DParams.fit];
		assoc(end+1) = myassoc('CE Color D Fit',DParams);
	end;

	combparams.err = Inf; combparams.l1=0; combparams.s1=0; combparams.l2=0; combparams.s2=0; combparams.r2=0; combparams.fit=0;
	for i=1:20,
		[l1,s1,l2,s2,err,r2,myfit]=color_fit2(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10,randn/10,randn/10);
		if err<combparams.err,
			combparams.err=err; combparams.l1=l1; combparams.s1=s1; combparams.l2=l2; combparams.s2=s2; combparams.r2=r2; combparams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		combparams.fit = [1:10; combparams.fit];
		assoc(end+1) = myassoc('CE Color Comb Fit',combparams);
	end;

	nktparams.err = Inf; nktparams.l=0; nktparams.s=0; nktparams.r50=0; nktparams.N=0; nktparams.r2=0; nktparams.fit=0;
	for i=1:20,
		[l,s,r50,N,err,r2,myfit]=color_fit_nkt(Lc,Sc,resp(2,1:10)-respstruct.blankresp(1),randn/10,randn/10,0,2);
		if err<nktparams.err,
			nktparams.err=err; nktparams.l=l; nktparams.s=s; nktparams.r50=r50; nktparams.N=N; nktparams.r2=r2; nktparams.fit=myfit;
		end;
	end;
	if ~isnan(err),
		nktparams.fit = [1:10; nktparams.fit];
		assoc(end+1) = myassoc('CE Color NKT Fit',nktparams);
	end;
end;

assoc(end+1)=myassoc('CE varies',ce_varies_p<0.05);
assoc(end+1)=myassoc('CE varies p',ce_varies_p);
if exist('ce_visresp_p')==1,
	assoc(end+1)=myassoc('CE visual response',ce_visresp_p<0.05);
	assoc(end+1)=myassoc('CE visual response p',ce_visresp_p);
end;
assoc(end+1)=myassoc('near S-isolating p values',[p1 p2 p3]);
assoc(end+1)=myassoc('sig S cone',sigS);
assoc(end+1)=myassoc('CE Response curve',resp);
assoc(end+1)=myassoc('CE Response struct',respstruct);
if isfield(respstruct,'blankresp'),
	assoc(end+1)=myassoc('CE Blank Response',respstruct.blankresp);
end;
assoc(end+1)=myassoc('CE Color Fit Params',[lb sb berr r2b]);
assoc(end+1) = myassoc('CE Color Fit',bfit);

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

