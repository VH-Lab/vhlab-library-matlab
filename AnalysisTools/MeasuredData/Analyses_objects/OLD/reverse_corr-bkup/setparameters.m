function nrc = setparameters(rc, parameters)

%  Part of the NeuralAnalysis package
%
%  NEWRCOBJ = SETPARAMETERS(REVERSE_CORROBJ, PARAMETERS)
%
%  Sets PARAMETERS for the REVERSE_CORR object REVERSE_CORROBJ.  It will return
%  an error if the parameters are not in the proper form.  See
%  'help reverse_corr' for information on the parameters.
%
%  See also:  REVERSE_CORR

I = getinputs(rc);
p = getparameters(I.stimtime(1).stim);
bg = 1;
for i=1:length(p.values),
  if eqlen(p.BG,p.values(1,:)), bg = i; break; end;
end;
default_p = struct('interval',[0.3 0.7],'showrast',1,'show1drev',1,...
	'normalize',0,'chanview',0,'colorbar',1,'clickbehav',0,...
	'pseudoscreen',[0 0 1600 1200],'datatoview',[1 0 0],'showdata',1,...
	'show1drevprs',[ 1 0.001 -0.050 +0.050 0],'bgcolor',bg);
if isempty(parameters)|(ischar(parameters)&strcmp(parameters,'default')),
	parameters = default_p; end;

[good,err]=verifyparameters(parameters,getinputs(rc));

rc.RCparams = parameters;
%configuremenu(rc); rc = compute(rc); draw(rc);
nrc = rc;
