function [err,fitr]=color_fit_err(p,Lc,Sc,data)
%  COLOR_FIT_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_ERR(P,DATA)
%   P = [L S C] 
%   returns mean squared error of  C+ABS(ABS(P(1)*LC+P(2)*SC)) with data 
%  
  
fitr=p(3)+abs((p(1))*Lc+p(2)*Sc);
err=0;
d = (data-fitr);
err=err+sum(sum(d.*d));
