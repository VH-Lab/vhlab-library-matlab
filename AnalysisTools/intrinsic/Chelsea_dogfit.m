function [A,dog_sse, fitvalues_dog] = Chelsea_dogfit(frequencies, responses, varargin)

%DOGFIT- difference of gaussian function for the classical surround
%suppression model
%takes data and returns fit parameters (a1 through a6)
%Inputs: x is stimulus length, r is response of a neuron
%Outputs: A is the parameters a1-a7, sse is the sum squared error, and
%fitvalues is the difference of gaussian distribution


% offset = 0;
% 
maxguess = max(responses);
sfhint = 0.02;
% 
curvehint = 0.19;

s = fitoptions('Method','NonlinearLeastSquares','Lower',[0 0 min(frequencies) 0 min(frequencies)],'Upper',[maxguess 3*maxguess max(frequencies) 3*maxguess max(frequencies)],'StartPoint',[0, maxguess, 0.02, 0.1*maxguess, 0.1]) 


f = fittype('a+b*exp(-x/c^2) - d*exp(-x^2/e^2)','options',s);
%[A,dog_sse, fitvalues_dog] = dogfit(frequencies,responses);

[c,gof] = fit(frequencies, responses, f);

A = coeffvalues(c);
fitvalues_dog = c(frequencies);
dog_sse = gof.sse;
