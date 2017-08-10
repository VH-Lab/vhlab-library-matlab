function [Rsp,Rp,P,sigm,FITCURVE,ERR] = Chelsea_gaussfit(frequencies, responses, varagrin)

% GAUSSFIT Fits data to a Gaussian
%
%  [Rsp,Rp,P,sigm,FITCURVE,ERR]=GAUSSFIT(VALUES,...
%         SPONTHINT, MAXRESPHINT, OTPREFHINT, WIDTHHINT,'DATA',DATA) 


offset = 0;

maxguess = max(responses);

sfhint = 0.02;

curvehint = 0.19;

[Rsp,Rp,P,sigm,FITCURVE,ERR] = gaussfit(frequencies',offset,maxguess,sfhint,curvehint,'data',responses')
