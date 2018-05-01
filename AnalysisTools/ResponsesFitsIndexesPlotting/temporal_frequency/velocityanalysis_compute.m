function [assoc]=velocityanalysis_compute(resp)
%  VELOCITYANALYSIS_COMPUTE  Analyze reponses to temporal frequencies
% %  [ASSOC]=VELOCITYANALYSIS_COMPUTE(RESP)
%
%  Analyzes temporal frequency responses.
%
%  RESP is a structure list of response properties with fields:
%  curve    |    4xnumber of temporal frequencies tested,
%           |      curve(1,:) is temporal frequencies tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each TF
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
%  'VT Response curve'        |   Response curve (tfs;mean;stddev;stderr)
%  'VT Pref'                  |   VT w/ max response
%  'VT Low'                   |   low VT with half of max response 
%  'VT High'                  |   high VT with half of max response
%
%        Same as above with 'blank' or 'spont' rate subtracted
%  'VT Low TF'                |   low VT with half of max response 
%  'VT High TF'               |   high VT with half of max response
%
%  'VT sig resp p'            |   p value of ANOVA across conditions
%  'VT sig resp'              |   (0/1) Is above < 0.05?
%  'VT visual response p'     |   p value of ANOVA across conditions + 
%                             |     blank, if available
%  'VT visual response'       |   (0/1) Is above < 0.05?
%
%  Difference of gaussians fit:
%  'VT DOG params'            |   'r0 re se ri si'
%  'VT DOG Fit'               |   1st row has VT values, 2nd has responses
%  'VT DOG R2'                |   R^2 error
%  'VT DOG Low'               |   Low cut-off, as measured with DOG
%  'VT DOG High'              |   High cut-off, as measured with DOG
%  'VT DOG Pref'              |   VT Pref, as measured with DOG
%
%  Cubic spline "Fit":
%  'VT spline Fit'            |   1st row has VT values, 2nd has responses
%  'VT spline Pref'           |   VT Pref, as measured with spline
%  'VT spline Low'            |   Low cut-off, as measured with spline
%  'VT spline High'           |   High cut-off, as measured with spline
%

assoclist = { 'VT Low TF','VT High TF',...
	'VT Response curve','VT Pref','VT Low','VT High',...
	'VT sig resp p','VT sig resp','VT visual response p','VT visual response','VT Blank Response',...
	'VT DOG params','VT DOG Fit','VT DOG R2','VT DOG Low','VT DOG High','VT DOG Pref',...
	'VT spline Fit','VT spline Pref','VT spline Low','VT spline High'};

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

if nargin==0, assoc = assoclist; return; end;

r0=resp.spont(1);
if isfield(resp,'blankresp'),
	r0 = resp.blankresp(1);
end;

resp.curve(1,1:size(resp.curve,2)/2) = -1 * resp.curve(1,1:size(resp.curve,2)/2);
[sorted,order] = sort(resp.curve(1,:));
resp.curve = resp.curve(1:4,order);

% from the raw curve
[mf,preftf]=max(resp.curve(2,:));
prefVT = resp.curve(1,preftf(1));
[lowv, maxv, highv] = compute_halfwidth(resp.curve(1,:),resp.curve(2,:));
[lowvsp, maxvsp, highvsp] = compute_halfwidth(resp.curve(1,:),resp.curve(2,:)-r0);

 % significance
 
[tfsigp,tfvp] = neural_response_significance(resp);

 % DOG fit
re = mf; ri = mf; se = maxv; si = 5+5*randn;
rcurve = resp.curve;

search_options=optimset('fminsearch');
search_options.TolFun=1e-3;
search_options.TolX=1e-3;
%search_options.MaxFunEvals='300*numberOfVariables';
search_options.Display='off';

norm_error_overall = Inf;
dog_par_overall = [];

for jj=1:10,
	re = mf; ri = mf; se = maxv; si = 5+5*randn;
	dog_par=fminsearch('dog_error',[r0 re se ri si],search_options,...
		[rcurve(1,:) 60 70],[rcurve(2,:) r0 r0], ...
		[rcurve(4,:) mean(rcurve(4,:)) mean(rcurve(4,:))] 	    )';

	norm_error=dog_error(dog_par, [rcurve(1,:) 60 70],[rcurve(2,:) r0 r0]);

	if norm_error<norm_error_overall,
		dog_par_overall = dog_par;
	end;
end;

norm_error = norm_error_overall;
dog_par = dog_par_overall;

tfrange_interp=logspace( log10(min( min(abs(rcurve(1,:))),0.01)),log10(50),50);
if isempty(dog_par),
	norm_error = Inf;
	r2 = -Inf;
	response=NaN*tfrange_interp;
else,
	norm_error=dog_error(dog_par, [rcurve(1,:) ],[rcurve(2,:)]);
	r2 = norm_error - ((rcurve(2,:)-mean(rcurve(2,:)))*(rcurve(2,:)'-mean(rcurve(2,:))));
	response=dog(dog_par',tfrange_interp);
end;

	
[lowdog, prefdog, highdog] =   compute_halfwidth(tfrange_interp,response);

fitx = min(rcurve(1,:)):1:max(rcurve(1,:));
if fitx(end)~=max(rcurve(1,:)), fitx(end+1) = max(rcurve(1,:)); end;
fity = interp1([rcurve(1,:)],[rcurve(2,:)], fitx,'spline');
[lowspline, prefspline, highspline] = compute_halfwidth(fitx,fity);

assoc(end+1) = tfassoc('VT Response curve',rcurve,'VT Response curve');
if isfield(resp,'blankresp'),
        assoc(end+1)=tfassoc('VT Blank Response',resp.blankresp,'VT blank resp');
end;
assoc(end+1) = tfassoc('VT Pref',preftf,'VT Pref');
assoc(end+1) = tfassoc('VT Low',lowv,'VT Low cut-off (half-max)');
assoc(end+1) = tfassoc('VT High',highv,'VT High cut-off (half-max)');

assoc(end+1) = tfassoc('VT Low TF',lowvsp,'VT Low cut-off (half-max) TF');
assoc(end+1) = tfassoc('VT High TF',highvsp,'VT High cut-off (half-max) TF');

assoc(end+1) = tfassoc('VT sig resp p',tfsigp,'VT response p value');
assoc(end+1) = tfassoc('VT sig resp',tfsigp<=0.05,'Is VT response significant?');
assoc(end+1) = tfassoc('VT visual response p',tfvp,'VT visual response (including blank) p value');
assoc(end+1) = tfassoc('VT visual response',tfvp<=0.05,'Is VT response across stims and blank significant?');

assoc(end+1) = tfassoc('VT DOG Pref',prefdog,'VT Pref difference of gaussians');
assoc(end+1) = tfassoc('VT DOG Low',lowdog,'VT Low cut-off (half-max from DOG)');
assoc(end+1) = tfassoc('VT DOG High',highdog,'VT High cut-off (half-max from DOG)');
assoc(end+1) = tfassoc('VT DOG R2',r2,'VT DOG r^2 of fit');
assoc(end+1) = tfassoc('VT DOG Fit',[tfrange_interp; response],'VT DOG Fit, 1st row is TF, 2nd row is response');

assoc(end+1) = tfassoc('VT spline Pref',prefspline,'VT Pref spline');
assoc(end+1) = tfassoc('VT spline Low',lowspline,'VT Low cut-off (half-max from spline)');
assoc(end+1) = tfassoc('VT spline High',highspline,'VT High cut-off (half-max from spline)');
assoc(end+1) = tfassoc('VT spline Fit',[fitx; fity],'VT spline Fit, 1st row is TF, 2nd row is response');

function myassoc = tfassoc(type,data,desc)
myassoc  = struct('type',type,'owner','tf','data',data,'desc',desc);
