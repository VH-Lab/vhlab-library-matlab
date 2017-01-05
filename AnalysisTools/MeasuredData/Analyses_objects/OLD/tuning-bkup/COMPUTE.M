function tcn = compute(tc)

% Part of the NeuralAnalysis package
%
%    TCN = COMPUTE(MY_TUNING_CURVE)
%
%  Performs computations for the TUNING_CURVE object MY_TUNING_CURVE and returns
%  a new object.  
%
%  See also:  ANALYSIS_GENERIC/compute, TUNING_CURVE

p = getparameters(tc); I = getinputs(tc);

interval = []; cinterval = [];
df = mean(diff(I.st(1).mti{1}.frameTimes));
dp = struct(getdisplayprefs(get(I.st(1).stimscript,1)));
scint = []; sint = [];
cinterval = [0 I.st(1).mti{1}.frameTimes(end)-I.st(1).mti{1}.frameTimes(1)+df];
if length(I.st(1).mti)>=2,
    %disp('setting interval');
    %interval = [-round(cinterval(2)*0.1/p.res)*p.res  ...
    %        cinterval(2)+I.st(1).mti{2}.frameTimes(1)-I.st(1).mti{1}.frameTimes(end)-df];
    if dp.BGposttime>0,
        interval = [ cinterval(1) cinterval(2)+dp.BGposttime];
        scint = [ cinterval(2) cinterval(2)+dp.BGposttime];
        sint  = [ cinterval(1) cinterval(2)+dp.BGposttime];
        spontlabel='stimulus / spontaneous';
    elseif dp.BGpretime>0,
        interval = [ cinterval(1)-dp.BGpretime cinterval(2)];
        scint = [ cinterval(1)-dp.BGpretime cinterval(1)];
        sint  = [ cinterval(1)-dp.BGpretime cinterval(2)];
        spontlabel='spontaneous / stimulus';
    else, interval = cinterval;
    end;
else, % if only one stim, really shouldn't happen
    spontlabel='raw activity';
    interval = cinterval;
end;
%interval, cinterval,scint,sint,
   



curve_x = []; curve_y = [];
ind = 1;  
for i=1:length(I.st),
   o = getDisplayOrder(I.st(i).stimscript);
   n = numStims(I.st(i).stimscript); s=1;
   for j=1:n,
      ps = getparameters(get(I.st(i).stimscript,j));
      curve_x(s) = getfield(ps,I.paramname);
      condnames{s} = [I.paramname '=' num2str(curve_x(s))];
      stimlist = find(o==j);
      for k=1:length(stimlist),
          trigs{s}(k)=I.st(i).mti{stimlist(k)}.frameTimes(1);
          if ~isempty(scint),spon{1}(stimlist(k))=trigs{s}(k);end;
      end;
      s = s + 1;
   end;
end;

[curve_x,inds]=sort(curve_x); trigs={trigs{inds}}; condname={condnames{inds}};

spontval = []; 
inp.condnames = condnames; inp.spikes = I.spikes; inp.triggers=trigs;
RAparams.res = p.res; RAparams.interval=interval; RAparams.cinterval=cinterval;
RAparams.showcbars=1; RAparams.fracpsth=0.5; RAparams.normpsth=1; RAparams.showvar=0;
RAparams.psthmode = 0; RAparams.showfrac = 1; tc.internals.rast = raster(inp,RAparams,[]);
if ~isempty(scint),RAparams.cinterval=scint;RAparams.interval=sint;inp.triggers=spon;
    inp.condnames = {spontlabel};
    tc.internals.spont=raster(inp,RAparams,[]);
    sc = getoutput(tc.internals.spont);
    spontval = [mean(sc.ncounts') mean(sc.ctdev')];
end;

c = getoutput(tc.internals.rast);
curve_y=c.ncounts';curve_var=c.ctdev';curve_err=c.stderr';
curve = [curve_x; curve_y; curve_var; curve_err];

% find maxes and mins
[dummy,maxes] = max(curve_y); maxes = curve_x(maxes);
[dummy,mins] = min(curve_y); mins = curve_x(mins);

tc.computations=struct('curve',curve,'maxes',maxes,'mins',mins,'spont',spontval);
tcn = tc;
