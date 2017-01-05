function [assoc] = otfitbootstrap(respstruct)

% OTFITBOOTSTRAP - Uses bootstrap to perform multiple orientation fits
%
%  ASSOC = OTFITBOOPSTRAP(RESPSTRUCT)
%
%
%  RESPSTRUCT is a structure  of response properties with fields:
%  curve    |    4xnumber of directions tested,
%           |      curve(1,:) is directions tested
%           |      curve(2,:) is mean responses
%           |      curve(3,:) is standard deviation
%           |      curve(4,:) is standard error
%  ind      |    cell list of individual trial responses for each direction
%  spont    |    spontaneous responses [mean stddev stderr]
%  spontind |    individual spontaneous responses
%  Optionally:
%  blank    |    response to a blank trial: [mean stddev stderr]
%  blankind |    individual responses to blank
%
%
%  Returns in ASSOC a list of associates (see HELP ASSOCIATE):
%
%  Measures derived from raw responses:
%  'OT Bootstrap Individual Responses' |   Resampled response curves
%  'OT Bootstrap Carandini Fit Params' |   Fit parameters

 % get ready to call Mark Mazurek's bootstrap function

if nargin==0,
    assoc = {'OT Bootstrap Individual Responses','OT Bootstrap Carandini Fit Params'};
    return;
end;
trialdata = [respstruct.ind{:}];
predictor = respstruct.curve(1,:);  % predictor means the independent variable methinks
fitfunc = 'otfit_carandini';
niter = 100;
simdataflag = 2; % bootstrap mode
verbose = 1;

da = median(diff(respstruct.curve(1,:))); % get the angle step

[maxresp,if0]=max(respstruct.curve(2,:)); 
otpref = [respstruct.curve(1,if0)];

extraparams = {[da/2 da 40 60 90], predictor, 0, maxresp, otpref, 'widthseeddummywillbereplaced', 'widthint' ,[da/2 180],'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(respstruct.curve(2,:)) max(respstruct.curve(2,:))]};

[parammtx,data2fit,extraout] = resampparams_MC('otfit_carandini',predictor,trialdata,niter,simdataflag,extraparams,verbose);

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

assoc(end+1) = struct('type','OT Bootstrap Individual Responses','owner','','data',data2fit,'desc','Individual responses (ntrials x condition x niter).');
assoc(end+1) = struct('type','OT Bootstrap Carandini Fit Params','owner','','data',parammtx,'desc','[Rsp Rp Op sigm Rn] x niter');

