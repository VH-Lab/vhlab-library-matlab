function [err,fitr]=color_fit_sat_err(p,Lc,Sc,data)
%  COLOR_FIT_SAT_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_SAT_ERR(P,DATA)
%   P = [L S Cs] 
%   returns mean squared error of  SAT*ABS(ABS(P(1)*LC+P(2)*SC)) with data 
%   where SAT = simp_sat_cgain(totalcontrast, Cs)
%    Cs = saturating contrast between 0.5 and 1


Csint = [0.5 1];
cs = Csint(1)+diff(Csint)./(1+abs(p(3)));
Ts = totalcontrast(Lc,Sc,p(1),p(2));
fitr= simp_sat_cgain(Ts,cs) .* abs((p(1))*Lc+p(2)*Sc);
err=0;
d = (data-fitr);
err=err+sum(sum(d.*d));

