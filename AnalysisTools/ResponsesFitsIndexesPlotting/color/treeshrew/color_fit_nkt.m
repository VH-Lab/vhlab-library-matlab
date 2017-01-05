function [l,s,r50,N,err,r2,fit] = color_fit_nkt(Lc,Sc,data,L0,S0,r50_0,N0);
% COLOR_FIT Fit L and S responses to color-exchange-style stims
%
%  [L,S,R50,N,ERR,R2] = COLOR_FIT(LC,SC,RESPONSES,L0,S0,Lc00,Sc00)
%
%  Finds the best fit to the function
%    R(LC,SC) = ABS(L*LC./(abs(LC)+Lc0)+S*SC./(abs(SC)+Sc0))
%  where *C is the *-cone contrast present in the stimulus and *c0 is the
%  half maximum of the contrast response function.  Contrast
%  should be in the interval [-1 1], where sign indicates relative 
%  contrast phase.  L is constrained to be greater than or equal to zero,
%  so the sign of S indicates phase of S relatively to L.
%
%  L0 and S0 are the initial conditions for the search.
%  ERR is squared error of fit, and R^2 is r squared.
  

% initial conditions
xo = [L0 S0 r50_0 N0];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit_nkt_err(x,Lc,Sc,data),xo,options);
if x(1)<0, x(1:2) = -x(1:2); end;
l=x(1);s=x(2);
c0Int = [0.2 1] * max(data);
NInt = [1 5];
r50=c0Int(1)+diff(c0Int)/(1+abs(x(3)));
N=NInt(1)+diff(NInt)/(1+abs(x(4)));
[err,fit] = color_fit_nkt_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));