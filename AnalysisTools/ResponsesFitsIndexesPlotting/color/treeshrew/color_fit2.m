function [l1,s1,l2,s2,err,r2,fit] = color_fit(Lc,Sc,data,L10,S10,L20,S20);
% COLOR_FIT2 Fit L and S responses to color-exchange-style stims
%
%  [L1,S1,L2,S2,ERR,R2] = COLOR_FIT2(LC,SC,RESPONSES,L10,S10,L20,S20)
%
%  Finds the best fit to the function
%    R(LC,SC) = ABS(L1*LC+S1*SC) + SIGN(L2)* ABS(L2*LC+S2*SC)
%  where *C is the *-cone contrast present in the stimulus.  Contrast
%  should be in the interval [-1 1], where sign indicates relative 
%  contrast phase.  L1 is constrained to be greater than or equal to zero,
%  so the sign of S1 indicates phase of S relatively to L.  Sign of L2
%  indicates excitatory or inhibitory contribution of second fit; if
%  L2 and S2 have same sign, then the second subunit is summing, or if they
%  have opposite sign, then it is opponent.
%
%  L10, S10, L20, S20 are the initial conditions for the search.
%  ERR is squared error of fit, and R^2 is r squared.
  

% initial conditions
xo = [L10 S10 L20 S20];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit2_err(x,Lc,Sc,data),xo,options);
if x(1)<0, x(1:2) = -x(1:2); end;
l1=x(1);s1=x(2);l2=x(3);s2=x(4);
[err,fit] = color_fit2_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));