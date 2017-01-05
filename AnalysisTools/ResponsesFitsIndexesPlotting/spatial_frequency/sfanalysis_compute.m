function [assoc]=sfanalysis_compute(resp)

%  SFANALYSIS_COMPUTE  Analyze reponses to spatial frequencies
%
%  [ASSOC]=SFANALYSIS_COMPUTE(RESP)
%
%  Analyzes spatial frequency responses.
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of spatial frequencies tested,
%           |      curve(1,:) is spatial frequencies tested
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
%  'SF Response curve'        |   Response curve (sfs;mean;stddev;stderr)
%  'SF Pref'                  |   SF w/ max response
%  'SF Low'                   |   low SF with half of max response 
%  'SF High'                  |   high SF with half of max response
%
%               same as above, but with 'blank' or 'spont' subtracted
%  'SF Low SP'                |   low SF with half of max response 
%  'SF High SP'               |   high SF with half of max response
%
%  'SF sig resp p'            |   p value of ANOVA across conditions
%  'SF sig resp'              |   (0/1) Is above < 0.05?
%  'SF visual response p'     |   p value of ANOVA across conditions + 
%                             |     blank, if available
%  'SF visual response'       |   (0/1) Is above < 0.05?
%
%  Difference of gaussians fit:
%  'SF DOG params'            |   'r0 re se ri si'
%  'SF DOG Fit'               |   1st row has SF values, 2nd has responses
%  'SF DOG R2'                |   R^2 error
%  'SF DOG Low'               |   Low cut-off, as measured with DOG
%  'SF DOG High'              |   High cut-off, as measured with DOG
%  'SF DOG Pref'              |   SF Pref, as measured with DOG


assoclist = {'SF Response curve','SF Pref','SF Low','SF High',...
	'SF Low SP','SF High SP',...
	'SF sig resp p','SF sig resp','SF visual response p','SF visual response','SF Blank Response',...
	'SF DOG params','SF DOG Fit','SF DOG R2','SF DOG Low','SF DOG High','SF DOG Pref'};

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

if nargin==0, assoc = assoclist; return; end;

r0=resp.spont(1);
if isfield(resp,'blankresp'),
	r0 = resp.blankresp(1);
end;

% from the raw curve
[mf,prefsf]=max(resp.curve(2,:));
prefsf = resp.curve(1,prefsf(1));
[lowv, maxv, highv] = compute_halfwidth(resp.curve(1,:),resp.curve(2,:)-r0);
[lowvsp, maxvsp, highvsp] = compute_halfwidth(resp.curve(1,:),resp.curve(2,:)-r0);

 % significance
 
[sfsigp,sfvp] = neural_response_significance(resp);

 % DOG fit

re = mf; ri = mf; se = maxv; si = 0.1;
rcurve = resp.curve;

search_options=optimset('fminsearch');
search_options.TolFun=1e-3;
search_options.TolX=1e-3;
%search_options.MaxFunEvals='300*numberOfVariables';
search_options.Display='off';
dog_par=fminsearch('dog_error',[r0 re se ri si],search_options,...
				[rcurve(1,:) ],[rcurve(2,:)], ...
				[rcurve(4,:) ] 	    )';

norm_error=dog_error(dog_par, [rcurve(1,:) ],[rcurve(2,:)]);
r2 = norm_error - ((rcurve(2,:)-mean(rcurve(2,:)))*(rcurve(2,:)'-mean(rcurve(2,:))));

sfrange_interp=logspace( log10(min( min(rcurve(1,:)),0.01)),log10(3),50);
response=dog(dog_par',sfrange_interp);
	
[lowdog, prefdog, highdog] =   compute_halfwidth(sfrange_interp,response);

assoc(end+1) = sfassoc('SF Response curve',rcurve,'SF Response curve');
if isfield(resp,'blankresp'),
        assoc(end+1)=sfassoc('SF Blank Response',resp.blankresp,'SF Blank Response');
end;
assoc(end+1) = sfassoc('SF Pref',prefsf,'SF Pref');
assoc(end+1) = sfassoc('SF Low',lowv,'SF Low cut-off (half-max)');
assoc(end+1) = sfassoc('SF High',highv,'SF High cut-off (half-max)');

assoc(end+1) = sfassoc('SF Low SP',lowvsp,'SF Low cut-off (half-max)');
assoc(end+1) = sfassoc('SF High SP',highvsp,'SF High cut-off (half-max)');

assoc(end+1) = sfassoc('SF sig resp p',sfsigp,'SF response p value');
assoc(end+1) = sfassoc('SF sig resp',sfsigp<=0.05,'Is SF response significant?');
assoc(end+1) = sfassoc('SF visual response p',sfvp,'SF visual response (including blank) p value');
assoc(end+1) = sfassoc('SF visual response',sfvp<=0.05,'Is SF response across stims and blank significant?');


assoc(end+1) = sfassoc('SF DOG Pref',prefdog,'SF Pref difference of gaussians');
assoc(end+1) = sfassoc('SF DOG Low',lowdog,'SF Low cut-off (half-max from DOG)');
assoc(end+1) = sfassoc('SF DOG High',highdog,'SF High cut-off (half-max from DOG)');
assoc(end+1) = sfassoc('SF DOG R2',r2,'SF DOG r^2 of fit');
assoc(end+1) = sfassoc('SF DOG Fit',[sfrange_interp; response],'SF DOG Fit, 1st row is SF, 2nd row is response');

function myassoc = sfassoc(type,data,desc)
myassoc  = struct('type',type,'owner','sf','data',data,'desc',desc);
