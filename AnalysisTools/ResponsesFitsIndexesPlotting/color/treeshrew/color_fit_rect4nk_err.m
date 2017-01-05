function [err,fitr]=color_fit_rect4nk_err(p,Lc,Sc,data)
%  COLOR_FIT_RECT4_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_RECT4_ERR(P,Lc,Sc,DATA)
%   P = [Se Si Le Li] 
%   returns mean squared error of 
%     fitr=[Se*[Sc] + Si*[-Sc] + Le*[Lc] + Li*[-Lc]] + ...
%             [Se*[-Sc] + Si*[Sc] + Le*[-Lc] + Li*[Lc]];
%  
%  Where [] denotes rectification above 0. 
%
%  Naka Rushton is applied.
%

c0Int = [0.1 0.5];
lc0=c0Int(1)+diff(c0Int)/(1+abs(p(5)));
sc0=c0Int(1)+diff(c0Int)/(1+abs(p(6)));
NInt = [1 5];
lcN=NInt(1)+diff(NInt)/(1+abs(p(7)));
scN=NInt(1)+diff(NInt)/(1+abs(p(8)));

Lc = naka_rushton_func(Lc,lc0,lcN);
Sc = naka_rushton_func(Sc,sc0,scN);

fitr=rectify(p(1)*rectify(Sc)+p(2)*rectify(-Sc)+p(3)*rectify(Lc)+p(4)*rectify(-Lc))+...
    rectify(p(1)*rectify(-Sc)+p(2)*rectify(Sc)+p(3)*rectify(-Lc)+p(4)*rectify(Lc));
d = (data-fitr);
err=sum(sum(d.*d))+sum((abs(p)/10000).^2);
