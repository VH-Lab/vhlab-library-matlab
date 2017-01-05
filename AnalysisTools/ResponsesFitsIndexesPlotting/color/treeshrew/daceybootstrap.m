function [assoc] = daceybootstrap(respstruct)

% DACEYFITBOOTSTRAP - Uses bootstrap to perform multiple orientation fits
%
%  ASSOC = DACEYFITBOOPSTRAP(RESPSTRUCT)
%
%
%  RESPSTRUCT is a structure  of response properties with fields:
%  curve    |    4xnumber of directions tested,
%           |      curve(1,:) is directions tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each direction
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blank    |    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
%
%  Returns in ASSOC a list of associates (see HELP ASSOCIATE):
%
%  Measures derived from raw responses:
%  'OT Bootstrap Individual Responses' |   Resampled response curves
%  'OT Bootstrap Carandini Fit Params' |   Fit parameters

 % get ready to call Mark Mazurek's bootstrap function

if nargin==0,
    assoc = {'CEDE Bootstrap Individual Responses','CEDE Bootstrap Color R4 Fit',...
       'CEDE Bootstrap Color Fit','CEDE Bootstrap Color NK Fit','CEDE Bootstrap Color R4R Fit','CEDE Bootstrap Color R Fit'};
    return;
end;

trialdata = [respstruct.ind{:}];
niter = 100;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

data2fit=resample_responses(trialdata',2,niter);

conds = size(data2fit,1)-1;

assoc(end+1) = struct('type','CEDE Bootstrap Individual Responses','owner','','data',data2fit,'desc','Individual responses (ntrials x condition x niter).');

LINP = struct('l',0,'s',0,'err',0,'r2',9,'fit',0); LINP=LINP([]);
NKP=struct('err',0,'s',0,'l',0,'lc50',0,'sc50',0,'ln',0,'sn',0,'r2',0,'fit',0);
RP = struct('l',0,'s',0,'r',0,'err',0,'r2',9,'fit',0); RP=RP([]);
R4P = struct('err',1,'se',1,'si',1,'le',1,'li',1,'r2',1,'fit',1); R4P = R4P([]);
R4RP = struct('err',1,'se',1,'si',1,'le',1,'li',1,'r2',1,'fit',1,'re',1,'ri',1); R4RP = R4RP([]);

if conds==12,
    [Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(3); % cone contrasts
elseif conds==16,
    [Lc,Sc,Rc]=TreeshrewConeContrastsColorExchange(4); % cone contrasts
else, error('unknown length of stims.');
end;

for n=1:niter,
        data = squeeze(data2fit(1:end-1,:,n));
        bl = nanmean(data2fit(end,:,n)); 
        md = nanmean(data');

        LINParams.l=0;LINParams.s=0;LINParams.err=Inf;LINParams.r2=0;LINParams.fit=0;
        for i=1:20, % use 20 initial seeds to find global minimum
            [l,s,err,r2,fitb]=color_fit(Lc,Sc,md-bl,randn/10,randn/10);
            if err<LINParams.err,
                    LINParams.s=s;LINParams.l=l;LINParams.err=err;LINParams.r2=r2;LINParams.fit=fitb;
            end;
        end;
        if ~isempty(LINParams.fit), 
            LINParams.fit = [1:16 ;LINParams.fit+bl];
        end;        
        LINP(n)=LINParams;

        NKParams.err = Inf; NKParams.s=0; NKParams.l=0; NKParams.lc50=0; NKParams.sc50=0; NKParams.ln=0; NKParams.sn=0;
        NKParams.r2 = 0; NKParams.fit = 0;
        for i=1:20, % use 20 initial seeds to find global minimum
            [l,s,lc0,sc0,ln,sn,err,r2,fit]=color_fit_nk(Lc,Sc,md-bl,randn/10,randn/10,0.5,0.5,0,0);
            if err<NKParams.err,
                NKParams.err = err; NKParams.s=s; NKParams.l=l; NKParams.lc50=lc0; NKParams.sc50=sc0;
                NKParams.ln=ln; NKParams.sn=sn; NKParams.r2 = r2; NKParams.fit=fit;
            end;
        end;
        if ~isempty(NKParams.fit),
            NKParams.fit = [1:conds ;NKParams.fit+bl];
        end;
        NKP(n)=NKParams;
        
        RodParams.l=0;RodParams.s=0;RodParams.r=0;RodParams.err=Inf;RodParams.r2=0;RodParams.fit=0;
        for i=1:20, % use 20 initial seeds to find global minimum
            [l,s,r,err,r2,fitb]=color_fit_rods(Lc,Sc,Rc,md-bl,randn/10,randn/10,randn/10);
            if err<RodParams.err,
                    sbR = s; lbR = l; rbR = r; berrR = err; r2bR = r2; bfitR = fitb;
                    RodParams.l=l;RodParams.s=s;RodParams.r=r;RodParams.err=err;RodParams.r2=r2;RodParams.fit=fitb;
            end;
        end;
        if ~isempty(RodParams.fit), 
            RodParams.fit = [1:conds ; RodParams.fit+bl];
        end;
        RP(n) = RodParams;
        
        
        R4Params.err = Inf; R4Params.se=0; R4Params.si=0; R4Params.le=0; R4Params.li=0; R4Params.r2=0; R4Params.fit=0;
        for i=1:40,
                [se,si,le,li,err,r2,myfit]=color_fit_rect4(Lc,Sc,md-bl,randn,randn,randn,randn);
                if sqrt(err)+sum(abs([se si le li]))/100<sqrt(R4Params.err)+sum(abs([R4Params.se R4Params.si R4Params.le R4Params.li]))/100,
                        R4Params.err=err; R4Params.se=se; R4Params.si=si; R4Params.le=le; R4Params.li=li; R4Params.r2=r2; R4Params.fit=myfit;
                end;
        end;
        if ~isnan(err),
                R4Params.fit = [1:conds; R4Params.fit+bl];
        end;
        R4P(n) = R4Params;

        R4RParams.err = Inf; R4RParams.se=0; R4RParams.si=0; R4RParams.le=0; R4RParams.li=0; R4RParams.r2=0; R4RParams.fit=0; R4RParams.re=0; R4RParams.ri=0;
        for i=1:40,
                [se,si,le,li,re,ri,err,r2,myfit]=color_fit_rect4_rods(Lc,Sc,Rc,md-bl,randn,randn,randn,randn,randn,randn);
                if sqrt(err)+sum(abs([se si le li re ri]))/100<sqrt(R4RParams.err)+sum(abs([R4RParams.se R4RParams.si R4RParams.le R4RParams.li R4RParams.re R4RParams.ri]))/100,
                        R4RParams.err=err; R4RParams.se=se; R4RParams.si=si; R4RParams.le=le; R4RParams.li=li; R4RParams.r2=r2; R4RParams.fit=myfit;
                        R4RParams.re = re; R4RParams.ri = ri;
                end;
        end;
        if ~isnan(err),
                R4RParams.fit = [1:conds; R4RParams.fit+bl];
        end;     
        R4RP(n) = R4RParams;
end;

assoc(end+1) = struct('type','CEDE Bootstrap Color R4 Fit','owner','','data',R4P,'desc','');
assoc(end+1) = struct('type','CEDE Bootstrap Color R4R Fit','owner','','data',R4RP,'desc','');
assoc(end+1) = struct('type','CEDE Bootstrap Color Fit','owner','','data',LINP,'desc','');
assoc(end+1) = struct('type','CEDE Bootstrap Color R Fit','owner','','data',RP,'desc','');
assoc(end+1) = struct('type','CEDE Bootstrap Color NK Fit','owner','','data',NKP,'desc','');

