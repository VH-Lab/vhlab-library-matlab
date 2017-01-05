function [parammtx,data2fit, extraout] = resampparams_MC(fitfunc,predictor,trialdata,niter,...
  simdataflag,extraparams,verbose, passfulldata)
% [parammtx,datamtx, extraout] = resampparams_MC(fitfunc,predictor,trialdata,...
%   niter,simdataflag,extraparams,verbose)
% Randomly resamples data and fits them to create a distribution of fit
% parameters that can be used to calculate confidence intervals,
% standar derrors, etc. on fit parameters.  The resampling can be done
% using a bootstrap approach (resampling the original data set with
% replacement) or by simulation using normal variates with the sample mean
% and standard deviation.
%
% INPUTS:
% fitfunc -- string with name of desired fitting function.
% predictor -- the values of the predictor variable corresponding to each
%   data point.
% trialdata -- length(predictor)-by-ntrials matrix of trial-wise data.
% niter -- number of iterations for Monte Carlo resampling.
%   OPTIONAL: Can set 'niter' to 0 to fit original data.
% simdataflag -- if set to 1, data resampling will occur via simulation of
%   new data using a normal distribution with estimates of mean and std
%   dev from the original data; otherwise, resampling is done from the
%   original data set by a bootstrap procedure (i.e., resampling with
%   replacement).
% extraparams -- This variable must be a cell array containing all the
%   input variables required by the desired fitting function.  It will get
%   broken into individual values (using the {:} command) and passed to the
%   fitting function.
%   --for otfit_carandini***-class functions:
%     the 1st arg of extraparams needs to be the desired list of width
%     seeds; the rest are passed to the fitting function.
% verbose -- if set to 1, this prints a log of the progress to the command
%   window.  Or can pass an fid and the log will be printed to this file.
% passfulldata - if set to 1, this will pass the full simulated trial data
%   to the fit function fitfun. In this case, the input argument
%   'data' will be a cell list of 2 items, the first being the
%   [predictor mean std_err] and the second being
%   the simulated trial data.
%
% OUTPUTS:
% parammtx -- an niter-by-number_of_fit_params matrix of
%   resampled/recalculated fit parameters.
% datamtx -- an niter-by-number_of_data_points matrix of 
%   resampled data
% extraout -- a cell array collecting all other output params
%
% IMPORTANT NOTE:
% This function assumes that the fitting function is called as follows:
% [paramvect,***out] = fitfunc(data,***in), where
% -- 'data' is [predictor mean std_err]
% -- '***in' is to be replaced by 'extraparams'
% -- 'paramvect' is a column vector of fit params
% -- '***out' are saved in 'extraout'
%
%   --The only exception it knows how to handle is SVH's 'otfit_carandini'
% class (as of 7/5/07).  It assumes these adhere to the following:
% (1) the error from the fit is returned as the second-to-last
% output arg; (2) in the output args, all args prior to the first vector
% output are fit parameters; (3) the fit function name is
% 'otfit_carandini_***'; (4) the width seed (widthhint) is the 5th input
% arg; (5) 'angles' and 'data' input args need to be row vectors; 

if(~exist('verbose','var'))
  verbose = 0;
  isverbose = 0;
else
  isverbose = 1;
  fid = verbose;
end

if ~exist('passfulldata','var'),
	passfulldata = 0;
	shouldpassfulldata = 0;
else,
	shouldpassfulldata = 1;
end;

if(strmatch('otfit_carandini',fitfunc))
  % Place the name of the fit function as the first arg of 'extraparams';
  % my otfit_carandini_wrapper will know how to decode this.
  extraparams = [fitfunc extraparams];
  fitfunc = 'otfit_carandini_wrapper';
end


%%% Fix the shape of input params
if(size(predictor,1)==1)
  predictor = predictor';
end

npred = length(predictor);
if(size(trialdata,2)==npred)
  trialdata = trialdata';
end

if(npred~=size(trialdata,1))
  error('Size disagreement between predictor and trialdata')
end

ntrials = size(trialdata,2);

%%%%%%
% Create the matrix of replicated data
if(isverbose)
  fprintf(fid,'Replicating data...');
end
data2fit = nan*ones(npred,ntrials,niter);

if(niter==0)
  % Fit the original data
  data2fit = trialdata;
elseif(niter>0 & simdataflag==1)
  % Replicate the data through simulation
  meandata = nanmean(trialdata,2);
  stddata = nanstd(trialdata')';
  for i_iter = 1:niter
    data2fit(:,:,i_iter) = normrnd(repmat(meandata,1,ntrials),...
      repmat(stddata,1,ntrials));
  end
elseif(niter>0 & simdataflag~=1)
  % Replicate the data through sampling with replacement
  randind = ceil(ntrials*rand(ntrials,npred,niter));

  for i_iter = 1:niter
    myinds = (randind(:,:,i_iter)-1)*npred+repmat(1:npred,ntrials,1);
    data2fit(:,:,i_iter) = trialdata(myinds)';
  end
end

% Now fix niter if it was entered as 0
if(niter==0)
  niter = 1;
end

if(isverbose)
  fprintf(fid,'done!\n');
end


%%%%%%
% Perform the fits
if(isverbose)
  fprintf(fid,'Performing fit (of %d)...',niter);
end

for i_iter = 1:niter
  if(isverbose)
    fprintf(fid,'%d',i_iter);
  end

  data1 = squeeze(data2fit(:,:,i_iter));
  md = nanmean(data1,2);
  ed = nanstd(data1')'/sqrt(ntrials);
  data = [predictor md ed];

  nout = nargout(fitfunc);
  if(nout<0)
    % Means there's a varargout call -- so, we don't know how many extra
    % output params there are!  Thus, don't save them.  Not the most
    % elegant solution but I don't think there's anything else to do
    % (that's not ridiculously slow, that is).
    neout = 0;
  else    
    neout = nargout(fitfunc)-1;
  end

  if shouldpassfulldata,  % pass the full trial data
	data = {data; data1'};
  end;
  
  if(neout>=1)
    eout = cell(neout,1);
    [fitp eout{:}] = feval(fitfunc,data,extraparams{:});
    if(all(size(eout)==[1 1]))
      eout = eout{1};
    end
  else
    fitp = feval(fitfunc,data,extraparams{:});
  end
  % If the fit param vector is a column vector, flip it
  if(size(fitp,2)==1),fitp=fitp';end
  
  if i_iter==1
    % If this is the first time through, initialize the matrix of saved
    % parameters
    nfit = size(fitp,2);
    parammtx = nan*ones(niter,nfit);
    
    extraout = cell(niter,1);
  end

  parammtx(i_iter,:) = fitp;

  if(neout>=1)
    if(iscell(eout) & all(size(eout)==[1 1]))
      extraout(i_iter) = {eout{1}};
    else
      extraout(i_iter) = {eout};
    end
  end

  if(isverbose)
    ps = [];
    for i_s = 1:length(num2str(i_iter))
      ps = [ps '\b'];
    end
    fprintf(fid,ps);
  end

end
if(isverbose)
  fprintf(fid,'done!\n');
end



function [params_out ee] = otfit_carandini_wrapper(data,varargin)
% [params_out ee] = otfit_carandini_wrapper(data,varargin)
% Wrapper function for calling SVH's 'otfit_carandini***' function
% class from resampparams_MC.  Needed because resampparams_MC calls all
% fitting functions as (data,extraparams) -- that is, it assumes that data is
% the first argument.
%
% INPUT ARGS:
% data -- 'data' as formatted in resampparams_MC.
% varargin -- needs to have the name of the desired fitting function (a string)
%   as its first value, followed by all the required and desired input
%   params (the latter should have been sent to resampparams_MC and are
%   just passed along to this function).
%  -Another thing: the 2nd component of 'varargin' should be a list of
%   width seeds to use; the function will fit using each width seed and
%   keep the fit with the lowest error.
%
% OUTPUT ARGS:
% params_out -- a vector of fit params
% ee -- a cell list of all other output args from the fitting function

% Check something before proceding: if the user included 'data' on the end
% of 'varargin' (which is how the otfit functions are called normally), trim
% it off -- it will be replaced below.
if(strcmp(varargin{end-1},'data'))
  varargin = varargin(1:end-2);
end

% Get the name of the desired fitting function 
fname = varargin{1};

% Extract the means from 'data'
meanvals = data(:,2);
if(size(meanvals,2)==1)
  meanvals = meanvals';
end

widthseeds = varargin{2};

% Rearrange the input variables; add 'data' at the end in compliance with
% SVHs functions.
argin = varargin(3:end);
argin = {argin{:} 'data' meanvals};
% There be some fancy syntactic footwork, no?  Cells are teh cool.

% Now make sure the angles vector is row-oriented
angles = argin{1};
if(size(angles,2)==1)
  angles = angles';
  argin{1} = angles;
end

[maxresp,if0]=max(meanvals); 
otpref = [angles(1,if0)];
argin{3} = maxresp;
argin{4} = otpref;

for jj=1:length(argin),
    if strcmp(argin{jj},'Rpint'),
        argin{jj+1} = [0 3*maxresp];
    elseif strcmp(argin{jj},'Rnint'),
        argin{jj+1} = [0 3*maxresp];
    elseif strcmp(argin{jj},'spontint'),
        argin{jj+1} = [ min(meanvals) max(meanvals) ];
    end;
end;

% Execute
nao = nargout(fname);
if(isempty(widthseeds))
  outp = cell(nao,1);
  [outp{:}] = feval(fname,argin{:});
else
  errors = Inf;
  for i_ws = 1:length(widthseeds)
    ws = widthseeds(i_ws);
    argin{5} = ws;

    outpt = cell(nao,1);
    [outpt{:}] = feval(fname,argin{:});
    ert = outpt{end-1};
  
    if ert<errors
      outp = outpt;
      errors = ert;
    end
  end
end

% Need to identify how many of the output params are fit params
% Here's how I'll do this: in the extant functions, the first n output
% args corresponding to the fit params are each scalars; then comes
% fitcurve, a vector.  Thus, I'll look through the output args until I get
% to a vector, then take all the args before the vector and call them fit
% parameters.
nfit = nao;  % Default value -- will get replaced if a non-scalar is found
for i_o = 1:nao
  o1 = outp{i_o};
  if(~isscalar(o1))
    nfit = i_o-1;
    break
  end
end

params_out = cell2mat(outp(1:nfit))';
ee = {outp(nfit+1:end)};
