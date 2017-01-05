function [err,fitr]=color_fit_err2(p,Lc,Sc,data)
%  COLOR_FIT_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_ERR(P,DATA)
%   P = [L1 S1 L2 S2] 
%   returns mean squared error of  ABS(ABS(P(1)*LC+P(2)*SC)) with data 
%  
  
fitr=abs((p(1))*Lc+p(2)*Sc)+sign(p(3))*abs((p(3))*Lc+p(4)*Sc);
d = (data-fitr);
err=sum(sum(d.*d));
