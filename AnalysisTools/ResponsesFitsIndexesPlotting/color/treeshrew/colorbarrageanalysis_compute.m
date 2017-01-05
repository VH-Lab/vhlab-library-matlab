function [assoc]=colorbarrageanalysis_compute(respstruct)

%  COLORBARRAGEANALYSIS_COMPUTE - Analyze color exchange data
%
%  [ASSOC]=COLORBARRAGEANALYSIS_COMPUTE(RESPSTRUCT)
%
%  Analyzes the color exchange barrage tests.
%
%  Measures gathered from the CEB Test (associate name in quotes):
%
%  'CEB visual response'          |   0/1 Was response significant w/ P<0.05?
%  'CEB visual response p'        |   Anova p across stims and blank (if available)
%  'CEB varies'                   |   0/1 Was response significant across CE?
%  'CEB varies p'                 |   Anova p across stims
%  'CEB sig S cone'               |   0/1 Is S-cone response significant?
%  'CEB near S-isolating p values'|   P values of the 3 stims closest to
%                                 |        the S-cone isolating stim
%  'CEB sig L cone'               |   0/1 Is L-cone response significant?
%  'CEB near L-isolating p values'|   P values of the 3 stims closest to
%                                 |        the L-cone isolating stim
%  'CEB Response curve'           |   Responses to the 10 stimuli
%  'CEB Response struct'          |   Response structure including
%                                            individual trials information
%  'CEB Blank Response'           |   Response to the blank stimulus
%  'CEB Color Fit Params'         |   [l s err r^2], estimated contribution of l, s
%                                 |     err is squared error, r^2 is r squared 
%  'CEB Color Fit'                |   1st row is stim numbers, 2nd row is fit
%                                 |        to R=abs(l*Lc+s*Sc)
%  'CEB Peak Stim'                |   Which stim number was max?
%  'CEB Peak Type'                |   'L dominated','S dominated','opponent'
%                                 |       'unclear'
%  If the function is called with no arguments then ASSOC is a list of
%  associate types that COLOREXCHANGEANALYSIS_COMPUTE returns.

if nargin==0,
        % edit these to reflect new indices
	assoc = { 'CEB visual response','CEB visual response p','CEB varies','CEB varies p',...
        'CEB sig S cone','CEB near S-isolating p values','CEB Response curve','CEB Response struct',...
		'CEB Blank Response','CEB sig L cone','CEB near L-isolating p values',...
		'CEB Color Fit Params','CEB Color Fit','CEB Peak Stim','CEB Peak Type'};
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
cebtype='unclear';
if cepref>=6&cepref<=10,
	cebtype='opponent';
elseif cepref>=13,
	cebtype='L dominated';
elseif cepref<=3,
	cebtype='S dominated';
end;
assoc(end+1)=myassoc('CEB Peak Type',cebtype);
assoc(end+1)=myassoc('CEB Peak Stim',cepref);

  % if there is no real blank but there are 17 stims, assume the 17th is
  % blank
if ~isfield(respstruct,'blankind')&length(resp(1,:)==17),
    respstruct.blankresp = resp(2:4,17)';
    respstruct.blankind = respstruct.ind{17};
    resp = resp(:,1:16);
    respstruct.ind = respstruct.ind(1:16);
end;

 % is there any variation across stimuli?
[ceb_varies_p,ceb_visresp_p] = neural_response_significance(respstruct);

[h,p1] = ttest2(respstruct.ind{2},respstruct.blankind,0.05,'right');
[h,p2] = ttest2(respstruct.ind{3},respstruct.blankind,0.05,'right');
[h,p3] = ttest2(respstruct.ind{4},respstruct.blankind,0.05,'right');
 % are all three above blank?  must use higher alpha to have 0.05 prob
alpha = 0.25;
sigS = (p1<alpha)&(p2<alpha)&(p3<alpha);
[h,pl1] = ttest2(respstruct.ind{12},respstruct.blankind,0.05,'right');
[h,pl2] = ttest2(respstruct.ind{13},respstruct.blankind,0.05,'right');
[h,pl3] = ttest2(respstruct.ind{14},respstruct.blankind,0.05,'right');
 % are all three above blank?  must use higher alpha to have 0.05 prob
alpha = 0.25;
sigL = (pl1<alpha)&(pl2<alpha)&(pl3<alpha);

berr = Inf;  sb = 0; lb = 0; r2b = 0;
[Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(2); % cone contrasts

for i=1:20, % use 20 initial seeds to find global minimum
	[l,s,err,r2]=color_fit(Lc,Sc,resp(2,1:16)-respstruct.blankresp(1),randn/10,randn/10);
	if err<berr,
			sb = s; lb = l; berr = err; r2b = r2;
	end;
end;
bfit = [1:16 ;abs(lb*Lc+sb*Sc)+respstruct.blankresp(1)];

assoc(end+1)=myassoc('CEB varies',ceb_varies_p<0.05);
assoc(end+1)=myassoc('CEB varies p',ceb_varies_p);
if exist('ceb_visresp_p')==1,
	assoc(end+1)=myassoc('CEB visual response',ceb_visresp_p<0.05);
	assoc(end+1)=myassoc('CEB visual response p',ceb_visresp_p);
end;
assoc(end+1)=myassoc('CEB near S-isolating p values',[p1 p2 p3]);
assoc(end+1)=myassoc('CEB sig S cone',sigS);
assoc(end+1)=myassoc('CEB Response curve',resp);
assoc(end+1)=myassoc('CEB Response struct',respstruct);
if isfield(respstruct,'blankresp'),
	assoc(end+1)=myassoc('CEB Blank Response',respstruct.blankresp);
end;
assoc(end+1)=myassoc('CEB Color Fit Params',[l s err r2]);
assoc(end+1) = myassoc('CEB Color Fit',bfit);

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

