function [assoc]=ctanalysis_compute(resp)

%  CTANALYSIS_COMPUTE  Analyze reponses to contrast
%
%  [ASSOC]=CTANALYSIS_COMPUTE(RESP)
%
%  Analyzes contrast responses.
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of contrasts tested,
%           |      curve(1,:) is contrasts tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each CT
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
%  'CT Response curve'        |   Response curve (contrasts;mean;stddev;stderr)
%  'CT Blank Response'        |   [Mean stddev stderr] of blank response
%
%  'CT C50'                   |   Contrast that gives 50% of maximum, interpolated
%                                     (blank or spontaneous is subtracted)
%
%  'CT NK Fit'                |   CT Naka Rushton Fit R=C^N./(C^N+C50^N)
%                                     (blank or spontaneous is subtracted)
%  'CT NK Params'             |   [Max C50 N]
%  'CT NK ERR'                |   Error of fit: [squared_error]
%
%  'CT NKS Fit'               |   CT Naka Rushton Saturation Fit R=C^N./(C^(S*N)+C50^(S*N))
%                                     (blank or spontaneous is subtracted)
%  'CT NKS Params'            |   [Max C50 N S]
%  'CT NKS ERR'               |   Error of fit: [squared_error]
%
%  'CT sig resp p'            |   p value of ANOVA across conditions
%  'CT sig resp'              |   (0/1) Is above < 0.05?
%  'CT visual response p'     |   p value of ANOVA across conditions + 
%                             |     blank, if available
%  'CT visual response'       |   (0/1) Is above < 0.05?
%

assoclist = {'CT Response curve', 'CT sig resp p','CT sig resp','CT visual response p','CT visual response','CT Blank Response',...
	'CT C50','CT NK Fit','CT NK Params','CT NK ERR', 'CT NKS Fit','CT NKS Params','CT NKS ERR'};
 
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

if nargin==0, assoc = assoclist; return; end;

% significance
 
[ctsigp,ctvp] = neural_response_significance(resp);

blank = resp.spont(1);
if isfield(resp,'blankresp'),
	blank = resp.blankresp(1);
end;

rcurve = resp.curve(2,:) - blank;

% NK fit

[rm,b,n] = naka_rushton(resp.curve(1,:),rcurve);
cc = resp.curve(1,:);
nkfit = rm*(cc.^n)./(b.^n+(cc.^n));
nkfiterr = sum( (rcurve-nkfit).^2 );

[rm_s,b_s,n_s,s_s] = naka_rushton(resp.curve(1,:),rcurve);
nkfit_s = rm_s*(cc.^n_s)./(b_s.^(n_s*s_s)+(cc.^(n_s*s_s)));
nkfiterr_s = sum( (rcurve-nkfit_s).^2 );

% C50, interpolated
xx=0:0.01:1;
yy=interp1(resp.curve(1,:),rcurve,xx,'linear');
[Cmax,i] = max(yy);
[c50,j] = findclosest(yy,Cmax/2); c50 = c50/100;

 % associates

assoc(end+1) = ctassoc('CT C50',c50,'CT C50 by interpolation');
assoc(end+1) = ctassoc('CT NK Fit',[resp.curve(1,:) ; nkfit+blank],'CT NK Fit, R=rm*c^n/(c^n+c0^n)');
assoc(end+1) = ctassoc('CT NK Params',[rm b n],'CT NK Params [rm c50 n]');
assoc(end+1) = ctassoc('CT NK ERR',nkfiterr,'CT NK Fit squared error');
assoc(end+1) = ctassoc('CT NKS Fit',[resp.curve(1,:) ; nkfit_s+blank],'CT NKS Fit, R=rm*c^n/(c^(n*s)+c0^(n*s))');
assoc(end+1) = ctassoc('CT NKS Params',[rm_s b_s n_s s_s],'CT NKS Params [rm c50 n s]');
assoc(end+1) = ctassoc('CT NKS ERR',nkfiterr_s,'CT NKS Fit squared error');
assoc(end+1) = ctassoc('CT Response curve',resp.curve,'CT Response curve');
if isfield(resp,'blankresp'),
        assoc(end+1)=ctassoc('CT Blank Response',resp.blankresp,'blank response');
end;

assoc(end+1) = ctassoc('CT sig resp p',ctsigp,'CT response p value');
assoc(end+1) = ctassoc('CT sig resp',ctsigp<=0.05,'Is CT response significant?');
assoc(end+1) = ctassoc('CT visual response p',ctvp,'CT visual response (including blank) p value');
assoc(end+1) = ctassoc('CT visual response',ctvp<=0.05,'Is CT response across stims and blank significant?');

function myassoc = ctassoc(type,data,desc)
myassoc  = struct('type',type,'owner','ct','data',data,'desc',desc);
