function [err,fitr]=color_fit_nkt_err(p,Lc,Sc,data)
%  COLOR_FIT_NK_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_NK_ERR(P,DATA)
%   P = [L S LC0 SC0] 
%   returns mean squared error of 
%   ABS(L*LC./(abs(LC)+Lc0)+S*SC./(abs(SC)+Sc0)) with data 
%  

c0Int = [0.2 1] * max(data);
NInt = [1 5];
r50=c0Int(1)+diff(c0Int)/(1+abs(p(3)));
N=NInt(1)+diff(NInt)/(1+abs(p(4)));
v=abs(p(1)*Lc+p(2)*Sc);
fitr=v.*naka_rushton_func(v,r50,N);
err=0;
d = (data-fitr);
err=err+sum(sum(d.*d));
