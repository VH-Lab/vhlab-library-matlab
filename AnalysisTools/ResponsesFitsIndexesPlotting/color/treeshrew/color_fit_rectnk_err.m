function [err,fitr]=color_fit_rect2nk_err(p,Lc,Sc,data)
%  COLOR_FIT_NK_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_NK_ERR(P,DATA)
%   P = [L S LC0 SC0] 
%   returns mean squared error of 
%   RECTIFY(L*LC./(abs(LC)+Lc0)+S*SC./(abs(SC)+Sc0)) with data 
%
%   Where RECTIFY is rectification above 0.
%  

c0Int = [0.1 0.5];
lc0=c0Int(1)+diff(c0Int)/(1+abs(p(4)));
sc0=c0Int(1)+diff(c0Int)/(1+abs(p(5)));
NInt = [1 5];
lcN=NInt(1)+diff(NInt)/(1+abs(p(6)));
scN=NInt(1)+diff(NInt)/(1+abs(p(7)));

Lc = naka_rushton_func(Lc,lc0,lcN);
Sc = naka_rushton_func(Sc,sc0,scN);

fitr=max(p(1)*abs(Lc)+p(2)*abs(Sc)+p(3)*(sign(Sc).*sign(Lc)).*(Sc-Lc),0);
d = (data-fitr);
err=sum(sum(d.*d));
