function [err,fitr]=color_fit_rect_err(p,Lc,Sc,data)
%  COLOR_FIT_ERR Color_fit function helper function for fitting
%
%   ERR=COLOR_FIT_RECT_ERR(P,DATA)
%   P = [L S D] 
%   returns mean squared error of 
%     [L*abs(Lc)+S*abs(Sc)+D*(Lc-Sc)]+  
%           (where []+ indicates rectification)
%  

% x = -10:0.05:10; sigm = 2;
% RF = [ sin(x).*exp(-x.^2/(2*sigm^2)) ;  % S
%        sin(x).*exp(-x.^2/(2*sigm^2)) ;  % L
%        0*sin(x);    ];  % no rod input  % rod
% 
% RF(1,find(x<0)) = p(3)*RF(1,find(x<0));
% RF(1,find(x>0)) = p(4)*RF(1,find(x>0));
% RF(2,find(x<0)) = p(1)*RF(2,find(x<0));
% RF(2,find(x>0)) = p(2)*RF(2,find(x>0));


fitr=max(p(1)*abs(Lc)+p(2)*abs(Sc)+p(3)*(sign(Sc).*sign(Lc)).*(Sc-Lc),0);
% fitr = zeros(size(data));
% for g=1:length(Lc),
% 	fitr(g) = 0;
% 	for phase=0:pi/12:2*pi-pi/12,
% 		stim = [Sc(g)*sin(x+phase); Lc(g)*sin(x+phase); 0*sin(x)];
% 		fitr(g)=fitr(g)+max(0,sum(sum(RF .* stim)));
% 	end;
% end;

err=0;
d = (data-fitr);
err=err+sum(sum(d.*d));
