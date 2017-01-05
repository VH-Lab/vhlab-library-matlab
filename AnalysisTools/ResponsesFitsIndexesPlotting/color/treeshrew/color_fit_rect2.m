function [l,s,err,r2,fit] = color_fit_rect2(Lc,Sc,data,L0,S0);
% COLOR_FIT_RECT2 Fit L and S responses to color-exchange-style stims
%
%  [L,S,ERR,R2] = COLOR_FIT_RECT2(LC,SC,RESPONSES,L0,S0)
%
%  Finds the best fit to the function
%    R(LC,SC) = [L*Lc+S*Sc]+  
%           (where []+ indicates rectification)
%  where *C is the *-cone contrast present in the stimulus.  Contrast
%  should be in the interval [-1 1], where sign indicates relative 
%  contrast phase.  L and S are the L and S cone contributions.
%
%  L0, and S0 are the initial conditions for the search.
%  ERR is squared error of fit, and R^2 is r squared.
  

% initial conditions
xo = [L0 S0];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit_rect2_err(x,Lc,Sc,data),xo,options);
l=x(1); s=x(2);
[err,fit] = color_fit_rect2_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));
