function [err,fitr]=color_fit_rect4_rods_err(p,Lc,Sc,Rc,data)
%  COLOR_FIT_RECT4_RODS_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_RECT4_RODS_ERR(P,Lc,Sc,DATA)
%   P = [Se Si Le Li Re Li] 
%   returns mean squared error of 
%     fitr=[Se*[Sc] + Si*[-Sc] + Le*[Lc] + Li*[-Lc]] + ...
%             [Se*[-Sc] + Si*[Sc] + Le*[-Lc] + Li*[Lc]];
%  
%  Where [] denotes rectification above 0. 
%
%

fitr=rectify(p(1)*rectify(Sc)+p(2)*rectify(-Sc)+p(3)*rectify(Lc)+p(4)*rectify(-Lc)+p(5)*rectify(Rc)+p(6)*rectify(-Rc))+...
    rectify(p(1)*rectify(-Sc)+p(2)*rectify(Sc)+p(3)*rectify(-Lc)+p(4)*rectify(Lc)+p(5)*rectify(-Rc)+p(6)*rectify(Rc));
d = (data-fitr);
err=sum(sum(d.*d))+sum((abs(p)/100000).^2);
