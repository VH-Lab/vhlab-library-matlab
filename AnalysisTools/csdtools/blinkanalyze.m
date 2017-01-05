function [means,stddev,stde] = blinkanalyze(stimfile,L)

%  BLINKANALYZE  Analyze responses to a blinking stim
%
%  Analyzes responses to a blinking stim
%
%  [MEANS,STDDEV,STDE] = BLINKANALYZE(STIMFILE, L)
%
%  STIMFILE is a 'stims.mat' file from the NewStim package
%  and L is a list of frame-triggered output waveforms.
%  It is assumed the first column of L is a list of sample times
%  and the remainder are frame-triggered waveforms in order of
%  presentation.

g = load(stimfile);
bl = get(g.saveScript,1);
gv = getgridvalues(bl);

for i=1:size(gv,1),
	indicies = find(gv(i,:)==2);
	means(:,i) = mean(L(:,indicies+1)')';
	stddev(:,i) = std(L(:,indicies+1)')';
	stde(:,i) = stderr(L(:,indicies+1)')';
end;
