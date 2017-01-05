function [l,s,d,err,r2,fit] = color_fit_rect(Lc,Sc,data,L0,S0,D0);
% COLOR_FIT Fit L and S responses to color-exchange-style stims
%
%  [L,S,D,ERR,R2] = COLOR_FIT(LC,SC,RESPONSES,L0,S0,D0)
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
xo = [L0 S0 D0];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit_rect_err(x,Lc,Sc,data),xo,options);
l=x(1); s=x(2); d=x(3);
[err,fit] = color_fit_rect_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));