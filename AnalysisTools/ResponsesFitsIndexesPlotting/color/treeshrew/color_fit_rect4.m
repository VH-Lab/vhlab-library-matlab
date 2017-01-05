function [se,si,le,li,err,r2,fit] = color_fit_rect4(Lc,Sc,data,SE0, SI0, LE0, LI0);
% COLOR_FIT_RECT4 Fit L and S responses to color-exchange-style stims
%
%  [SE,SI,LE,LI,ERR,R2] = COLOR_FIT_RECT4(LC,SC,RESPONSES,SE0,SI0,LE0,LI0)
%
%  Finds the best fit to the function
%     fitr=[Se*[Sc] + Si*[-Sc] + Le*[Lc] + Li*[-Lc]] + ...
%             [Se*[-Sc] + Si*[Sc] + Le*[-Lc] + Li*[Lc]];
%  
%  Where [] denotes rectification above 0. 
%           (where []+ indicates rectification)
%  where *C is the *-cone contrast present in the stimulus.  Contrast
%  should be in the interval [-1 1], where sign indicates relative 
%  contrast phase.  
%  SE0, SI0, LE0, LI0 are the initial conditions for the search.
%  ERR is squared error of fit, and R^2 is r squared.
  

% initial conditions
xo = [SE0 SI0 LE0 LI0];
options= optimset('Display','off','MaxFunEvals',10000,'TolX',1e-6);
[x] = fminsearch(@(x) color_fit_rect4_err(x,Lc,Sc,data),xo,options);
if abs(x(1))>abs(x(2)), se = x(1); si = x(2); le = x(3); li = x(4);
else, se = x(2); si = x(1); le = x(4); li = x(3);
end;
[err,fit] = color_fit_rect4_err(x,Lc,Sc,data);
r2 = 1 - err/(sum((data-mean(data)).^2));
