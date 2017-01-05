function [err,fitr]=color_fit_rect3nk_err(p,Lc,Sc,data)
%  COLOR_FIT_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_RECT3NK_ERR(P,Lc,Sc,DATA)
%   P = [D L_S] 
%   returns mean squared error of 
%     fitr=max(p(1)*(sign(Sc).*sign(Lc)).*(Sc-p(2)*Lc),0);
%  

c0Int = [0.1 0.5];
lc0=c0Int(1)+diff(c0Int)/(1+abs(p(3)));
sc0=c0Int(1)+diff(c0Int)/(1+abs(p(4)));
NInt = [1 5];
lcN=NInt(1)+diff(NInt)/(1+abs(p(5)));
scN=NInt(1)+diff(NInt)/(1+abs(p(6)));

Lc = naka_rushton_func(Lc,lc0,lcN);
Sc = naka_rushton_func(Sc,sc0,scN);

fitr=max(p(1)*(sign(Sc).*sign(Lc)).*(Sc-p(2)*Lc),0);

err=0;
d = (data-fitr);
err=err+sum(sum(d.*d));
