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

curve_x = []; curve_y = []; interval = []; cinterval = [];
      scint = []; sint = []; pst=0;pre=0;
ind = 1;  
for i=1:length(I.st),
   o = getDisplayOrder(I.st(i).stimscript);
   n = numStims(I.st(i).stimscript); s=1;
   interval = zeros(n,2); cinterval = zeros(n,2);  % assume length(I.st)==1
   for j=1:n,
      ps = getparameters(get(I.st(i).stimscript,j));
      curve_x(s) = getfield(ps,I.paramname);
      condnames{s} = [I.paramname '=' num2str(curve_x(s))];
      stimlist = find(o==j);
      for k=1:length(stimlist),
          trigs{s}(k)=I.st(i).mti{stimlist(k)}.frameTimes(1);
          spon{1}(stimlist(k))=trigs{s}(k);
      end;

      df = mean(diff(I.st(1).mti{1}.frameTimes));
      dp = struct(getdisplayprefs(get(I.st(1).stimscript,j)));
      %Cinterval(j,:) = [0
      %I.st(1).mti{stimlist(1)}.frameTimes(end)-I.st(1).mti{stimlist(1)}.fr
      %ameTimes(1)+df];
      Cinterval(j,:) = [0 diff(I.st(1).mti{stimlist(1)}.startStopTimes([2 4]))];
      if length(I.st(1).mti)>=2,
        if dp.BGposttime>0, pst = pst + 1;
          interval(j,:) = [ Cinterval(j,1) Cinterval(j,2)+dp.BGposttime];
        elseif dp.BGpretime>0, pre=pre+1;
          interval(j,:) = [ Cinterval(j,1)-dp.BGpretime Cinterval(j,2)];
        else, interval(j,:) = Cinterval(j,:);
        end;
      else, % if only one stim, really shouldn't happen
      spontlabel='raw activity';
      interval(j,:) = Cinterval(j,:);
      end;

      s = s + 1;
   end;
end;

sint = [ min(interval(:,1)) max(interval(:,2)) ];
if pre==0&pst>0,  %BGposttime used
     spontlabel='stimulus / spontaneous';
     scint = [ max(Cinterval(:,2)) max(interval(:,2))];
elseif pst==0&pre>0,  % BGpretime used
     spontlabel='spontaneous / stimulus';
     scint = [ min(interval(:,1)) min(Cinterval(:,1)) ];
     if scint(2)-scint(1)>1
       scint(1)=scint(1)+0.5;
       % added half a second in order to separate off-response from
       % spontaneous rate, 
       % only when theres is at least 0.5 s left to average 
       % Alexander 24 June 2003
     end
else,
     spontlabel='trials';
     scint = sint;
end;

switch p.int_meth,
  case 0, %
     cinterval = [Cinterval(:,1)+p.interval(1) Cinterval(:,2)-p.interval(2)];
  case 1, % 
     cinterval = [Cinterval(:,1)+p.interval(1) Cinterval(:,1)+p.interval(2)];
end;

%cinterval, interval, scint, sint,

[curve_x,inds]=sort(curve_x); trigs={trigs{inds}}; condname={condnames{inds}};

spontval = []; 
inp.condnames = condnames; inp.spikes = I.spikes; inp.triggers=trigs;
RAparams.res = p.res; RAparams.interval=interval; RAparams.cinterval=cinterval;
RAparams.axessameheight = 1;
RAparams.showcbars=1; RAparams.fracpsth=0.5; RAparams.normpsth=1; RAparams.showvar=0;
RAparams.psthmode = 0; RAparams.showfrac = 1; tc.internals.rast = raster(inp,RAparams,[]);
if ~isempty(scint),RAparams.cinterval=scint;RAparams.interval=sint;inp.triggers=spon;
    inp.condnames = {spontlabel};
    tc.internals.spont=raster(inp,RAparams,[]);
    sc = getoutput(tc.internals.spont);
    spontval = [mean(sc.ncounts') mean(sc.ctdev')];
else, tc.internals.spont = [];
end;

c = getoutput(tc.internals.rast);
curve_y=c.ncounts';curve_var=c.ctdev';curve_err=c.stderr';
curve = [curve_x; curve_y; curve_var; curve_err];

% find maxes and mins
[dummy,maxes] = max(curve_y); maxes = curve_x(maxes);
[dummy,mins] = min(curve_y); mins = curve_x(mins);

tc.computations=struct('curve',curve,'maxes',maxes,'mins',mins,...
                       'spont',spontval,'spontrast',tc.internals.spont,...
                       'rast',tc.internals.rast);
tcn = tc;
