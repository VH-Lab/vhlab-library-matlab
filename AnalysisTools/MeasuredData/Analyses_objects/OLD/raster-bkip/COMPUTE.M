function newra = compute(ra)

%  NEWRA = COMPUTE(RASTEROBJ)
%
%  Compute rasters, PSTH, and other internal data structures.  These are
%  returned via a call to GETOUTPUT.
%
%  See also:  RASTER, GETOUTPUT

I = getinputs(ra); p = getparameters(ra);

mi = min(p.interval); mx = max(p.interval);
mic= min(p.cinterval); mxc= max(p.cinterval);

trigs = I.triggers;

edges= [mi : p.res : mx]; bins = edges-p.res/2;
cstart=round((mic-mi)/p.res)+1; cstop=round((mxc-mi)/p.res);
ra.internals.cs = [ cstart cstop];
cind = cstart:cstop;
dt = mxc - mic;

variation = zeros(length(trigs),(cstop-cstart+1));
counts    = zeros(length(trigs),(cstop-cstart+1));
ncounts   = zeros(length(trigs),1);
ctdev     = zeros(length(trigs),1);

for k=1:length(trigs),
    rast_x = []; rast_y = [];
    vals{k} = zeros(length(bins),length(trigs{k}));
    ccounts{k} = zeros(length(bins),1);

    N(k) = length(trigs{k});
    for i=1:length(trigs{k}),
      try, g = get_data(I.spikes,[trigs{k}(i)+mi trigs{k}(i)+mx]);
      catch, g = []; warning(['Could not get data: ' lasterr]); end;
      n = histc(g-trigs{k}(i),edges);
      if size(n,2)>size(n,1),n=n'; end;
        if ~isempty(n),
          vals{k}(:,i) = n;
          ccounts{k} = ccounts{k} + n;
          rast_x=[rast_x bins(find(n))];
          rast_y=[rast_y repmat(i,1,length(find(n)))];
          %cind, size(n),
	  zzzzz=sum(n(cind));
          nncounts{k}(i) = zzzzz;
        else, vals{k}(:,i) = 0; nncounts{k}(i) = 0;
        end;
    end;
    %size(counts(k,:)); size(ccounts{k}(cind));
    counts(k,:) = ccounts{k}(cind)';
    ncounts(k) = sum(counts(k,:));
    
    %size(sum(vals{k}(cind,:)));
    ctdev(k) = std(sum(vals{k}(cind,:)));
    cvariation{k} = std(vals{k}')';
    variation(k,:) = cvariation{k}(cind)';
    rast{k} = [ rast_x; rast_y];
end;
ra.internals.counts=ccounts;
ra.internals.variation = cvariation;
ra.internals.bins = bins;

ra.computations = struct('rast',{rast},'bins',bins(cstart:cstop),...
	'counts',{counts},'variation',{variation},'ncounts',ncounts./(dt*N'),...
	'ctdev',ctdev/dt,'stderr',(ctdev/dt)./sqrt(N'),'N',N');

newra = ra;
