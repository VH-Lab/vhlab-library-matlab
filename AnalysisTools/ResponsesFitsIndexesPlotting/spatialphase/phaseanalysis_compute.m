function [assoc]=phaseanalysis_compute(resp)

%  PHASEANALYSIS_COMPUTE  Analyze reponses to different phases
%
%  [ASSOC]=PHASEANALYSIS_COMPUTE(RESP)
%
%  Analyzes responses at different spatial phases.
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of phases tested,
%           |      curve(1,:) is phases tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each SF
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blank    |    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
%  
%  If the function is called with no arguments, then the of associate
%  names that are computed by the function is returned.
%
%  Returns data in the form of 'associates' that can be added
%  to a measured data object:
%  'Phase Response curve'     |   Response curve (phases;mean;stddev;stderr)
%  'Phase Pref'               |   Phase w/ max response
%  'Phase Blank Response'     |   
%
%  'Phase sig resp p'         |   p value of ANOVA across conditions
%  'Phase sig resp'           |   (0/1) Is above < 0.05?
%  'Phase visual response p'  |   p value of ANOVA across conditions + 
%                             |     blank, if available
%  'Phase visual response'    |   (0/1) Is above < 0.05?
%

assoclist = {'Phase Response curve','Phase Pref','Phase Blank Response',...
	'Phase sig resp p','Phase sig resp','Phase visual response p','Phase visual response'};

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

if nargin==0, assoc = assoclist; return; end;

% from the raw curve
[mf,prefphase]=max(resp.curve(2,:));
prefphase = resp.curve(1,prefphase(1));

 % significance
 
[phasesigp,phasevp] = neural_response_significance(resp);

assoc(end+1) = sfassoc('Phase Response curve',resp.curve,'Phase Response curve');
assoc(end+1) = sfassoc('Phase Pref',prefphase,'Phase Pref');

assoc(end+1) = sfassoc('Phase sig resp p',phasesigp,'Phase response p value');
assoc(end+1) = sfassoc('Phase sig resp',phasesigp<=0.05,'Is Phase response significant?');
assoc(end+1) = sfassoc('Phase visual response p',phasevp,'Phase visual response (including blank) p value');
assoc(end+1) = sfassoc('Phase visual response',phasevp<=0.05,'Is Phase response across stims and blank significant?');
if isfield(resp,'blankresp'),
	assoc(end+1)=sfassoc('Phase Blank Response',resp.blankresp,'');
end;

function myassoc = sfassoc(type,data,desc)
myassoc  = struct('type',type,'owner','phase','data',data,'desc',desc);