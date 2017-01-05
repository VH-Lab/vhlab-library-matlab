function [d,l_s,lc0,sc0,lcN,scN,err,r2,fit] = color_fit_rect3(Lc,Sc,data,D0,L_S0, LC0, SC0, LN0, SN0);
% COLOR_FIT Fit L and S responses to color-exchange-style stims
%
%  [D,L_S,LC0,SC0,LCN,SCN,ERR,R2] = COLOR_FIT_RECT3(LC,SC,RESPONSES,DO, L_S0)
%
%  Finds the best fit to the function
%    R(LC,SC) = [L*abs(Lc)+S*abs(Sc)+D*(Lc-Sc)]+  
%           (where []+ indicates rectification)
%  where *C is the *-cone contrast present in the stimulus.  Contrast
%  should be in the interval [-1 1], where sign indicates relative 
%  contrast phase.  L and S are the pure L and S cone contributions,
%  and D is the contribution of the cone differences.
%
%  L0, S0, and DO are the initial conditions for the search.
%  ERR is squared error of fit, and R^2 is r squared.
  

% initial conditions
xo = [D0 L_S0 LC0 SC0 LN0 SN0];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit_rect3nk_err(x,Lc,Sc,data),xo,options);
d=x(1); l_s=x(2);
c0Int = [0.1 0.5];
NInt = [1 5];
lc0=c0Int(1)+diff(c0Int)/(1+abs(x(3)));
sc0=c0Int(1)+diff(c0Int)/(1+abs(x(4)));
lcN=NInt(1)+diff(NInt)/(1+abs(x(5)));
scN=NInt(1)+diff(NInt)/(1+abs(x(6)));
[err,fit] = color_fit_rect3nk_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));
