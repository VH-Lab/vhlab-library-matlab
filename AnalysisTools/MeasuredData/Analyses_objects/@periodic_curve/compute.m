function pcn = compute(pc)

% Part of the NeuralAnalysis package
%
%    PCN = COMPUTE(MY_PERIODIC_CURVE)
%
%  Performs computations for the PERIODIC_CURVE object MY_PERIODIC_CURVE
%  and
%  returns a new object.  
%
%  See also:  ANALYSIS_GENERIC/compute, PERIODIC_CURVE

p = getparameters(pc);
I = getinputs(pc);

if ~isempty(pc.internals.oldparams), 
	if eqlen(pc.internals.oldparams.paramnames,p.paramnames)&...
		pc.internals.oldparams.res==p.res&...
		pc.internals.oldparams.lag==p.lag,
			pcn=pc;
			return;
	end;
end;

% otherwise, we either have not computed previously or
% we have new parameter values which affects the computation and we must recompute

scint = {};
sint = {};
pst=0;
pre=0;

% isolate grating data to be analyzed, must have parameter value, not be
% a blank stim
inc = [];
[stims,mti,disporder] = mergestimscripttimestruct(I.st);
 
for i=1:length(stims),
	if ~isempty(p.paramnames),
		use = 1;
		par = getparameters(stims{i});
		for j=1:length(p.paramnames),
			b = isfield(par,I.paramnames{1});
			if length(I.paramnames)>1,
				b=b&isfield(par,I.paramnames{2});
			end;
			if ~isempty(I.blankid),
				b=b&~isempty(intersect(i,I.blankid));
			end; 
			if isfield(par,p.paramnames{j})&b,
				for k=1:length(p.values{j}),
					if getfield(par,p.paramnames{j})~=p.values{j}{k},
						use=0;
					end;
				end;
			else,
				use=0;
			end;
		end;
		if use==1,
			inc = cat(2,inc,i);
		end;
	elseif isempty(intersect(i,I.blankid)),
		inc = cat(2,inc,i);
	end;
end;

disp('Analysis: Computing PERIODICCURVE responses');

vars={};
vals={};
if length(I.paramnames)==1,
	vals{1}=[];
end;


for i=inc,
	par = getparameters(stims{inc(i)});
	if length(I.paramnames)==1,
		vals{1} = cat(2,vals{1},i);
	else,
		used=0;
		for j=1:length(vars),
			if eqlen(vars{j},getfield(par,I.paramnames{2})),
				vals{j} = cat(2,vals{j},i);
				used=1;
			end;
		end;
		if ~used,
			vars{length(vars)+1}=getfield(par,I.paramnames{2});
			vals{length(vals)+1}=[i];
		end;
	end;
end;

if length(vars)==0, vars={[]}; end;
  % compute spontaneous activity rate on first pass through

  for z=1:length(vars), % looping over second parameter
    s=1;
    interval{z}=zeros(length(vals{z}),2);
    cinterval{z}=zeros(length(vals{z}),2);
    for j=1:length(vals{z}), % looping over first parameter
       ps = getparameters(stims{vals{z}(j)});
       curve_x{z}(s) = getfield(ps,I.paramnames{1});
       condnames{z}{s}=[I.paramnames{1} '=' num2str(curve_x{z}(s))];
       stimlist = find(disporder==vals{z}(j));
       dp = struct(getdisplayprefs(stims{vals{z}(j)}));
       df = mean(diff(mti{stimlist(1)}.frameTimes));
       %cinterval{z}(j,:)=[0 mti{stimlist(1)}.frameTimes(end)-mti{stimlist(1)}.frameTimes(1)+df];
       cinterval{z}(j,:)=[0 diff(mti{stimlist(1)}.startStopTimes(2:3))];
       for k=1:length(stimlist),
         trigs{z}{s}(k)=mti{stimlist(k)}.startStopTimes(2);
         spon{1}(stimlist(k))=trigs{z}{s}(k);
       end;
       if length(mti)>=2,
         if dp.BGposttime>0,pst = pst+1;
           interval{z}(j,:) = [cinterval{z}(j,1) cinterval{z}(j,2)+dp.BGposttime];
         elseif dp.BGpretime>0, pre=pre+1;
           interval{z}(j,:) = [cinterval{z}(j,1)-dp.BGpretime cinterval{z}(j,2)];
         else, interval{z}(j,:) = cinterval{z}(j,:);
         end;
       else, spontlabel='raw activity'; interval{z}(j,:) = interval{z}(j,:);
       end;
    end;
  end;
  sint = [ min(interval{1}(:,1)) max(interval{1}(:,2)) ];
  if pre==0&pst>0,  %BGposttime used
     spontlabel='stimulus / spontaneous';
     scint = [ max(cinterval{1}(:,2)) max(interval{1}(:,2))];
  elseif pst==0&pre>0,  % BGpretime used
     spontlabel='spontaneous / stimulus';
     scint = [ min(interval{1}(:,1)) min(cinterval{1}(:,1)) ];
  else,
     spontlabel='trials';
     scint = sint;
  end;

  spontval = [];  spontrast = []; avg_rate=0;
  inp.condnames = condnames; inp.spikes = I.spikes; inp.triggers=trigs;
  RAparams.res = p.res; RAparams.interval=interval; RAparams.cinterval=cinterval;
  RAparams.showcbars=1; RAparams.fracpsth=0.5; RAparams.normpsth=1; RAparams.showvar=0;
  RAparams.psthmode = 0; RAparams.showfrac = 1; RAparams.axessameheight =1;
  if ~isempty(scint),RAparams.cinterval=scint;RAparams.interval=sint;inp.triggers=spon;
    inp.condnames = {spontlabel};
    pc.internals.spont=raster(inp,RAparams,[]);
    spontrast = pc.internals.spont;
    sc = getoutput(pc.internals.spont);
    spontval = [mean(sc.ncounts') mean(sc.ctdev')]; avg_rate=spontval(1);
  end;

  clear trigs condnames RAparams curve_x cinterval interval

  %who,

 % general parameters for rasters
  RAparams.res = p.res; % RAparams.interval=interval; RAparams.cinterval=cinterval; % need specifics below
  RAparams.showcbars=1; RAparams.fracpsth=0.5; RAparams.normpsth=1; RAparams.showvar=0; RAparams.axessameheight = 1;
  RAparams.psthmode = 0; RAparams.showfrac = 1; RAinp.spikes = I.spikes;

  % now make computations on second pass
  for z=1:length(vars),  % looping over second parameter
    % make plots/analysis for each condition
    s=1; interval{z}=zeros(length(vals{z}),2); cinterval{z}=zeros(length(vals{z}),2);
    for j=1:length(vals{z}), % looping over first parameter
       ps = getparameters(stims{vals{z}(j)});
       curve_x{z}(s) = getfield(ps,I.paramnames{1});
       condnames{z}{s}=[I.paramnames{1} '=' num2str(curve_x{z}(s))];
       stimlist = find(disporder==vals{z}(j));
       dp = struct(getdisplayprefs(stims{vals{z}(j)}));
       df = mean(diff(mti{stimlist(1)}.frameTimes));
       cinterval{z}(j,:)=[0 mti{stimlist(1)}.frameTimes(end)-mti{stimlist(1)}.frameTimes(1)+df];
       nCyc = ps.nCycles;
        % there was a change in periodicstim; in the old version, the number of frames
        %  was equal to the number of frames that could be displayed in 1 cycle and those 
        %  frames were repeated for the number of cycles.
        %  in the new version, all frames are drawn out explicitly
       if (all(dp.frames==1))|(ps.loops+1)*length(unique(dp.frames))==length(dp.frames), % new version
           %disp(['new version']);
               ft=(mti{stimlist(1)}.frameTimes);
               fpc = length(mti{stimlist(1)}.frameTimes)/((ps.loops+1)*ps.nCycles);
               estper = (ft(end)-ft(1)+df)/((ps.loops+1)*ps.nCycles);
               %fpc = length(dp.frames)/((ps.loops+1)*ps.nCycles);
               %estper = fpc*df; % estimate actual period shown
       else,  % old version
           %disp(['old version']);
	       fpc = length(unique(dp.frames));
	       estper = fpc*df; % estimate actual period shown
       end;
       %fpc = 1; estper = 1;
       estpers(s) = estper;
       %estper = 1; fpc = 1;
       cyci_curve_x{z}{s} = 1:nCyc;
       cyci_cinterval{z}{s} = p.lag+[0 estper];
       cyci_interval{z}{s}  = p.lag+[0 estper];
       for nn=1:nCyc, cyci_condnames{z}{s}{nn}=num2str(nn); end;
       for k=1:length(stimlist),
         trigs{z}{s}(k)=mti{stimlist(k)}.frameTimes(1);
         spon{1}(stimlist(k))=trigs{z}{s}(k);
                       % our monitor can't produce tF exactly, so we have to get frame time stamps
        %% keyboard
         for nn=1:nCyc,
             mti{stimlist(k)}.frameTimes(round(1+(nn-1)*(fpc)));
             cyci_trigs{z}{s}{nn}(k)=mti{stimlist(k)}.frameTimes(round(1+(nn-1)*(fpc)));
		     cycg_trigs{z}{s}((k-1)*nCyc+nn)=cyci_trigs{z}{s}{nn}(k);
         end;
       end;
       if length(mti)>=2, % set 'interval'
         if dp.BGposttime>0,pst = pst+1;
           interval{z}(j,:) = [cinterval{z}(j,1) cinterval{z}(j,2)+dp.BGposttime] + p.lag;
         elseif dp.BGpretime>0, pre=pre+1;
           interval{z}(j,:) = [cinterval{z}(j,1)-dp.BGpretime cinterval{z}(j,2)] + p.lag;
         else, interval{z}(j,:) = cinterval{z}(j,:) + p.lag;
         end;
       else, spontlabel='raw activity'; interval{z}(j,:) = interval{z}(j,:) + p.lag;
       end;
       cinterval{z}(j,:) = cinterval{z}(j,:)+p.lag;
       % at this point, ready to compute individual cycle average
       RAip=RAparams; RAip.interval=cyci_interval{z}{s}; RAip.cinterval=cyci_cinterval{z}{s};
       RAI=RAinp; RAI.condnames = cyci_condnames{z}{s}; RAI.triggers=cyci_trigs{z}{s};
       %global c estper spontval cyci_curve
       cyci_rast{z}{s}=raster(RAI,RAip,[]); c=getoutput(cyci_rast{z}{s});
       cyci_curve{z}{s}=[cyci_curve_x{z}{s}; c.ncounts'; c.ctdev'; c.stderr'];
       % compute f1's,f2's,etc...
       [loc1,thz1]=findclosest(c.fftfreq{1},1/estper); % since its multiple pres. of same stim, take first
       [loc2,thz2]=findclosest(c.fftfreq{1},2/estper); % since its multiple pres. of same stim, take first
       cf1mean=[]; cf1stddev=[]; cf1stderr=[];
       cf2mean=[]; cf2stddev=[]; cf2stderr=[];
       cf1f0mean=[]; cf1f0stddev=[]; cf1f0stderr=[];
       cf2f1mean=[]; cf2f1stddev=[]; cf2f1stderr=[];
       cf0mean=[]; cf0stddev=[]; cf0stderr=[];       
       for nn=1:nCyc,
          cf1mean(nn)=abs(mean((c.fftvals{nn}(loc1,:)))); cf1stddev(nn)=std((c.fftvals{nn}(loc1,:)));
          cf1stderr(nn)=cf1stddev(nn)/sqrt(length(stimlist));
          cf2mean(nn)=abs(mean((c.fftvals{nn}(loc2,:)))); cf2stddev(nn)=std((c.fftvals{nn}(loc2,:)));
          cf2stderr(nn)=cf2stddev(nn)/sqrt(length(stimlist));
          cf1f0mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderr(nn)=cf1f0stddev(nn)/sqrt(length(stimlist));
          cf2f1mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
          cf2f1stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
          cf2f1stderr(nn)=cf2f1stddev(nn)/sqrt(length(stimlist));
       end;
       cyci_f1curve{z}{s}=[cyci_curve_x{z}{s}; cf1mean; cf1stddev; cf1stderr;];
       cyci_f2curve{z}{s}=[cyci_curve_x{z}{s}; cf2mean; cf2stddev; cf2stderr;];
       cyci_f1f0curve{z}{s}=[cyci_curve_x{z}{s}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
       cyci_f2f1curve{z}{s}=[cyci_curve_x{z}{s}; cf2f1mean; cf2f1stddev; cf2f1stderr;];

       cycg_cinterval{z}(j,:) = cyci_cinterval{z}{s};
       cycg_interval{z}(j,:)  = cyci_interval{z}{s};
       s=s+1;
    end;
    RAcp=RAparams; RAcp.interval=cycg_interval{z}; RAcp.cinterval=cycg_cinterval{z};
    RAci=RAinp; RAci.condnames = condnames{z}; RAci.triggers=cycg_trigs{z};
    cycg_rast{z} = raster(RAci,RAcp,[]); c = getoutput(cycg_rast{z}); c1 = c;
    cycg_curve{z} = [curve_x{z}; c.ncounts'; c.ctdev'; c.stderr'];
    RAp=RAparams; RAp.interval=interval{z}; RAp.cinterval=cinterval{z}; RAp.interval, RAp.cinterval,
    RAi=RAinp; RAi.condnames = condnames{z}; RAi.triggers=trigs{z};
    rast{z} = raster(RAi,RAp,[]); c = getoutput(rast{z});
    curve{z} = [curve_x{z}; c.ncounts'; c.ctdev'; c.stderr'];
    cf1meanc=[]; cf1stddevc=[]; cf1stderrc=[]; cf2meanc=[]; cf2stddevc=[]; cf2stderrc=[];
    cf1f0meanc=[]; cf1f0stddevc=[]; cf1f0stderrc=[]; cf2f1meanc=[]; cf2f1stddevc=[]; cf2f0stderrc=[];
    cf1mean=[]; cf1stddev=[]; cf1stderr=[]; cf2mean=[]; cf2stddev=[]; cf2stderr=[];
    cf1f0mean=[]; cf1f0stddev=[]; cf1f0stderr=[]; cf2f1mean=[]; cf2f1stddev=[]; cf2f1stderr=[];
    cf0vals = zeros(size(c.fftvals{z},2),length(stims));
    cf1vals = zeros(size(c.fftvals{z},2),length(stims));
    cf2vals = zeros(size(c.fftvals{z},2),length(stims));
    cf1f0vals = zeros(size(c.fftvals{z},2),length(stims));
    cf2f1vals = zeros(size(c.fftvals{z},2),length(stims));
    for nn=1:length(vals{z}),
          stimlist = find(disporder==vals{z}(nn));
          [loc1c,thz1]=findclosest(c1.fftfreq{nn},1/estpers(nn));
          [loc2c,thz2]=findclosest(c1.fftfreq{nn},2/estpers(nn));
          cf1meanc(nn)=(abs(mean((c1.fftvals{nn}(loc1c,:)))));cf1stddevc(nn)=std((c1.fftvals{nn}(loc1c,:)));
          cf1stderrc(nn)=cf1stddevc(nn)/sqrt(length(stimlist));
          cf2meanc(nn)=(abs(mean((c1.fftvals{nn}(loc2c,:))))); cf2stddevc(nn)=std((c1.fftvals{nn}(loc2c,:)));
          cf2stderrc(nn)=cf2stddevc(nn)/sqrt(length(stimlist));
          cf1f0meanc(nn)=abs(real(mean(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddevc(nn)=std(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderrc(nn)=cf1f0stddevc(nn)/sqrt(length(stimlist));
          cf2f1meanc(nn)=abs(abs(mean(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))))));
          cf2f1stddevc(nn)=std(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))));
          cf2f1stderrc(nn)=cf2f1stddevc(nn)/sqrt(length(stimlist));
          [loc1,thz1]= findclosest(c.fftfreq{nn},1/estpers(nn));
          [loc2,thz2]= findclosest(c.fftfreq{nn},2/estpers(nn));
          cf0vals(:,nn) = (c.fftvals{nn}(1,:))';
          cf1vals(:,nn) = (c.fftvals{nn}(loc1,:))';
          cf2vals(:,nn) = (c.fftvals{nn}(loc2,:))';
          cf1f0vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc1,:),c.fftvals{nn}(1,:)-avg_rate))';
          cf2f1vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc2,:),c.fftvals{nn}(loc1,:)-avg_rate))';
          cf1mean(nn)=(abs(mean((c.fftvals{nn}(loc1,:)))));cf1stddev(nn)=std((c.fftvals{nn}(loc1,:)));
          cf1stderr(nn)=cf1stddev(nn)/sqrt(length(stimlist));
          cf0mean(nn)=(abs(mean((c.fftvals{nn}(1,:)))));cf0stddev(nn)=std((c.fftvals{nn}(1,:)));
          cf0stderr(nn)=cf0stddev(nn)/sqrt(length(stimlist));
          cf2mean(nn)=(abs(mean((c.fftvals{nn}(loc2,:))))); cf2stddev(nn)=std((c.fftvals{nn}(loc2,:)));
          cf2stderr(nn)=cf2stddev(nn)/sqrt(size(c.fftvals,2));
          cf1f0mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderr(nn)=cf1f0stddev(nn)/sqrt(length(stimlist));
          cf2f1mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
          cf2f1stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
          cf2f1stderr(nn)=cf2f1stddev(nn)/sqrt(length(stimlist));
    end;
    cycg_f1curve{z}=[curve_x{z}; cf1meanc; cf1stddevc; cf1stderrc;];
    cycg_f2curve{z}=[curve_x{z}; cf2meanc; cf2stddevc; cf2stderrc;];
    cycg_f1f0curve{z}=[curve_x{z}; cf1f0meanc; cf1f0stddevc; cf1f0stderrc;];
    cycg_f2f1curve{z}=[curve_x{z}; cf2f1meanc; cf2f1stddevc; cf2f1stderrc;];
    f0curve{z}=[curve_x{z}; cf0mean; cf0stddev; cf0stderr;];
    f1curve{z}=[curve_x{z}; cf1mean; cf1stddev; cf1stderr;];
    f2curve{z}=[curve_x{z}; cf2mean; cf2stddev; cf2stderr;];
    f1f0curve{z}=[curve_x{z}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
    f2f1curve{z}=[curve_x{z}; cf2f1mean; cf2f1stddev; cf2f1stderr;];
    f0vals{z}=cf0vals;f1vals{z}=cf1vals;f2vals{z}=cf2vals;f1f0vals{z}=cf1f0vals;f2f1vals{z}=cf2f1vals;
  end;

%[curve_x,inds]=sort(curve_x); trigs={trigs{inds}}; condname={condnames{inds}};


% find maxes and mins later

pc.internals.oldparams = p;
pc.internals.stims=stims;

pc.computations=struct('spont',spontval);
pc.computations.f0vals = f0vals; pc.computations.f1vals = f1vals;
pc.computations.f2vals = f2vals; pc.computations.f1f0vals = f1f0vals;
pc.computations.f2f1vals = f2f1vals;
pc.computations.vals2=vars; pc.computations.vals1=vals;
pc.computations.curve=curve; pc.computations.rast=rast;
pc.computations.cycg_curve=cycg_curve; pc.computations.cycg_rast=cycg_rast;
pc.computations.cyci_curve=cyci_curve; pc.computations.cyci_rast=cyci_rast;
pc.computations.spontrast = spontrast;
pc.computations.cycg_f1curve = cycg_f1curve; pc.computations.cycg_f2curve = cycg_f2curve;
pc.computations.cycg_f1f0curve = cycg_f1f0curve; pc.computations.cycg_f2f1curve = cycg_f2f1curve;
pc.computations.cyci_f1curve = cyci_f1curve; pc.computations.cyci_f2curve = cyci_f2curve;
pc.computations.cyci_f1f0curve = cyci_f1f0curve; pc.computations.cyci_f2f1curve = cyci_f2f1curve;
pc.computations.f1curve = f1curve; pc.computations.f2curve = f2curve;
pc.computations.f0curve = f0curve;
pc.computations.f1f0curve = f1f0curve; pc.computations.f2f1curve = f2f1curve;

if ~isempty(I.blankid),
 % now do the calculations for the blank

 for i=1:length(I.blankid),  
  RAparams.res = p.res; % RAparams.interval=interval; RAparams.cinterval=cinterval; % need specifics below
  RAparams.showcbars=1; RAparams.fracpsth=0.5; RAparams.normpsth=1; RAparams.showvar=0; RAparams.axessameheight = 1;
  RAparams.psthmode = 0; RAparams.showfrac = 1; RAinp.spikes = I.spikes;

  clear curve_x condnames interval cinterval f0vals f1vals f2vals f2f1vals f1f0vals curve rast spontrast trigs;
  clear cycg_rast cycg_curve cycg_trigs cycg_interval cycg_cinterval cycg_condnames cycg_f0curve cycg_f1curve cycg_f2curve cycg_f1f0curve cycg_f2f1curve f1curve f0curve f1f0curve f2f1curve f2curve;
  clear cyci_rast cyci_curve cyci_trigs cyci_interval cyci_cinterval cyci_condnames cyci_f0curve cyci_f1curve cyci_f2curve cyci_f1f0curve cyci_f2f1curve;

  psblank = getparameters(stims{I.blankid(i)});
  myestpersinds = find(~isnan(estpers)&estpers>0);  
  if isfield(psblank,'tFrequency'),
	TFlist = psblank.tFrequency;
  elseif ~isempty(myestpersinds),
     TFlist = 1/median(estpers(myestpersinds)); % use estimate of tF derived from actual frametimes, more acurate than using requested tF
  else, 
	TFlist = [];
	for z=1:length(vars),  % looping over second parameter
		for j=1:length(vals{z}), % looping over first parameter
			ps = getparameters(stims{vals{z}(j)});
			if isfield(ps,'tFrequency'), TFlist(end+1) = ps.tFrequency; end;
		end;
	end;
	TFlist = median(TFlist);
  end;
  nCyc = [];
  if isfield(psblank,'nCycles'), nCyc = psblank.nCycles;
  else,
    for z=1:length(vars),
      for j=1:length(vals{z}),
	ps = getparameters(stims{vals{z}(j)});
	if isfield(ps,'nCycles'), nCyc(end+1) = ps.nCycles; end;
      end;
    end;
    nCyc = median(nCyc);
  end;
  %nCyc = nCyc; TFlist = TFlist;


  % now make computations on second pass
  z = 1; j=1; % only one parameter to loop over
    % make plots/analysis for each condition
    s=1; interval{z}=zeros(1,2); cinterval{z}=zeros(1,2);
       ps = psblank;
       curve_x{z}(s) = 0;
       condnames{z}{s}=['blank'];
       stimlist = find(disporder==I.blankid(i));
       dp = struct(getdisplayprefs(stims{I.blankid(i)}));
       %df = mean(diff(mti{stimlist(1)}.frameTimes));
       cinterval{z}(j,:)=[0 diff(mti{stimlist(1)}.startStopTimes([2 4])) ];  % this is a kludge
       estpers(s) = 1/TFlist;
       fpc = round(estpers(s)/df);
       cyci_curve_x{z}{s} = 1:nCyc;
       cyci_cinterval{z}{s} = p.lag+[0 estper];
       cyci_interval{z}{s}  = p.lag+[0 estper];
       for nn=1:nCyc, cyci_condnames{z}{s}{nn}=num2str(nn); end;
       for k=1:length(stimlist),
         trigs{z}{s}(k)=mti{stimlist(k)}.startStopTimes(2);
         spon{1}(stimlist(k))=trigs{z}{s}(k);
                       % our monitor can't produce tF exactly, so we have
                       % to estimate time stamps from previous data
         for nn=1:floor(nCyc),
      		cyci_trigs{z}{s}{nn}(k)=mti{stimlist(k)}.startStopTimes(2)+(nn-1)*fpc*df;
	     	cycg_trigs{z}{s}((k-1)*floor(nCyc)+nn)=cyci_trigs{z}{s}{nn}(k);
         end;
       end;
       if length(mti)>=2, % set 'interval'
         if dp.BGposttime>0,pst = pst+1;
           interval{z}(j,:) = [cinterval{z}(j,1) cinterval{z}(j,2)+dp.BGposttime] + p.lag;
         elseif dp.BGpretime>0, pre=pre+1;
           interval{z}(j,:) = [cinterval{z}(j,1)-dp.BGpretime cinterval{z}(j,2)] + p.lag;
         else, interval{z}(j,:) = cinterval{z}(j,:) + p.lag;
         end;
       else, spontlabel='raw activity'; interval{z}(j,:) = interval{z}(j,:) + p.lag;
       end;
       cinterval{z}(j,:) = cinterval{z}(j,:)+p.lag;
       % at this point, ready to compute individual cycle average
       RAip=RAparams; RAip.interval=cyci_interval{z}{s}; RAip.cinterval=cyci_cinterval{z}{s};
       RAI=RAinp; RAI.condnames = cyci_condnames{z}{s}; RAI.triggers=cyci_trigs{z}{s};
       %global c estper spontval cyci_curve
       cyci_rast{z}{s}=raster(RAI,RAip,[]); c=getoutput(cyci_rast{z}{s});
       cyci_curve{z}{s}=[cyci_curve_x{z}{s}; c.ncounts'; c.ctdev'; c.stderr'];
       % compute f1's,f2's,etc...
       [loc1,thz1]=findclosest(c.fftfreq{1},1/estper); % since its multiple pres. of same stim, take first
       [loc2,thz2]=findclosest(c.fftfreq{1},2/estper); % since its multiple pres. of same stim, take first
       cf1mean=[]; cf1stddev=[]; cf1stderr=[];
       cf2mean=[]; cf2stddev=[]; cf2stderr=[];
       cf1f0mean=[]; cf1f0stddev=[]; cf1f0stderr=[];
       cf2f1mean=[]; cf2f1stddev=[]; cf2f1stderr=[];
       for nn=1:nCyc,
          cf1mean(nn)=abs(mean((c.fftvals{nn}(loc1,:)))); cf1stddev(nn)=std((c.fftvals{nn}(loc1,:)));
          cf1stderr(nn)=cf1stddev(nn)/sqrt(length(stimlist));
          cf2mean(nn)=abs(mean((c.fftvals{nn}(loc2,:)))); cf2stddev(nn)=std((c.fftvals{nn}(loc2,:)));
          cf2stderr(nn)=cf2stddev(nn)/sqrt(length(stimlist));
          cf1f0mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderr(nn)=cf1f0stddev(nn)/sqrt(length(stimlist));
          cf2f1mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
          cf2f1stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
          cf2f1stderr(nn)=cf2f1stddev(nn)/sqrt(length(stimlist));
       end;
       cyci_f1curve{z}{s}=[cyci_curve_x{z}{s}; cf1mean; cf1stddev; cf1stderr;];
       cyci_f2curve{z}{s}=[cyci_curve_x{z}{s}; cf2mean; cf2stddev; cf2stderr;];
       cyci_f1f0curve{z}{s}=[cyci_curve_x{z}{s}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
       cyci_f2f1curve{z}{s}=[cyci_curve_x{z}{s}; cf2f1mean; cf2f1stddev; cf2f1stderr;];

       cycg_cinterval{z}(j,:) = cyci_cinterval{z}{s};
       cycg_interval{z}(j,:)  = cyci_interval{z}{s};
       s=s+1;
    RAcp=RAparams; RAcp.interval=cycg_interval{z}; RAcp.cinterval=cycg_cinterval{z};
    RAci=RAinp; RAci.condnames = condnames{z}; RAci.triggers=cycg_trigs{z};
    cycg_rast{z} = raster(RAci,RAcp,[]); c = getoutput(cycg_rast{z}); c1 = c;
    cycg_curve{z} = [curve_x{z}; c.ncounts'; c.ctdev'; c.stderr'];

    RAp=RAparams; RAp.interval=interval{z}; RAp.cinterval=cinterval{z};
    RAi=RAinp; RAi.condnames = condnames{z}; RAi.triggers=trigs{z};
    rast{z} = raster(RAi,RAp,[]); c = getoutput(rast{z});
curve{z} = [curve_x{z}; c.ncounts'; c.ctdev'; c.stderr'];
    cf0meanc=[]; cf0stddevc=[]; cf0stderrc=[]; cf2meanc=[]; cf2stddevc=[]; cf2stderrc=[];cf1meanc=[]; cf1stddevc=[]; cf1stderrc=[];
    cf1f0meanc=[]; cf1f0stddevc=[]; cf1f0stderrc=[]; cf2f1meanc=[]; cf2f1stddevc=[]; cf2f1stderrc=[];
    cf1mean=[]; cf1stddev=[]; cf1stderr=[]; cf0mean=[]; cf0stddev=[]; cf0stderr=[]; cf2mean=[]; cf2stddev=[]; cf2stderr=[];
    cf1f0mean=[]; cf1f0stddev=[]; cf1f0stderr=[]; cf2f1mean=[]; cf2f1stddev=[]; cf2f1stderr=[];
    cf0vals = zeros(size(c.fftvals{z},2),1);
    cf1vals = zeros(size(c.fftvals{z},2),1);
    cf2vals = zeros(size(c.fftvals{z},2),1);
    cf1f0vals = zeros(size(c.fftvals{z},2),1);
    cf2f1vals = zeros(size(c.fftvals{z},2),1);
    nn=1;
          [loc1c,thz1]=findclosest(c1.fftfreq{nn},1/estpers(nn));
          [loc2c,thz2]=findclosest(c1.fftfreq{nn},2/estpers(nn));
          cf1meanc(nn)=(abs(mean((c1.fftvals{nn}(loc1c,:)))));cf1stddevc(nn)=std((c1.fftvals{nn}(loc1c,:)));
          cf1stderrc(nn)=cf1stddevc(nn)/sqrt(length(stimlist));
          cf2meanc(nn)=(abs(mean((c1.fftvals{nn}(loc2c,:))))); cf2stddevc(nn)=std((c1.fftvals{nn}(loc2c,:)));
          cf2stderrc(nn)=cf2stddevc(nn)/sqrt(length(stimlist));
          cf1f0meanc(nn)=abs(real(mean(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddevc(nn)=std(divide_nozero((c1.fftvals{nn}(loc1c,:)),(c1.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderrc(nn)=cf1f0stddevc(nn)/sqrt(length(stimlist));
          cf2f1meanc(nn)=abs(abs(mean(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))))));
          cf2f1stddevc(nn)=std(divide_nozero((c1.fftvals{nn}(loc2c,:)),(c1.fftvals{nn}(loc1c,:))));
          cf2f1stderrc(nn)=cf2f1stddevc(nn)/sqrt(length(stimlist));
          [loc1,thz1]= findclosest(c.fftfreq{nn},1/estpers(nn));
          [loc2,thz2]= findclosest(c.fftfreq{nn},2/estpers(nn));
          cf0vals(:,nn) = (c.fftvals{nn}(1,:))';
          cf1vals(:,nn) = (c.fftvals{nn}(loc1,:))';
          cf2vals(:,nn) = (c.fftvals{nn}(loc2,:))';
          cf1f0vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc1,:),c.fftvals{nn}(1,:)-avg_rate))';
          cf2f1vals(:,nn) = (divide_nozero(c.fftvals{nn}(loc2,:),c.fftvals{nn}(loc1,:)-avg_rate))';
          cf1mean(nn)=(abs(mean((c.fftvals{nn}(loc1,:)))));cf1stddev(nn)=std((c.fftvals{nn}(loc1,:)));
          cf1stderr(nn)=cf1stddev(nn)/sqrt(length(stimlist));
          cf0mean(nn)=(abs(mean((c.fftvals{nn}(1,:)))));cf0stddev(nn)=std((c.fftvals{nn}(1,:)));
          cf0stderr(nn)=cf0stddev(nn)/sqrt(length(stimlist));
          cf2mean(nn)=(abs(mean((c.fftvals{nn}(loc2,:))))); cf2stddev(nn)=std((c.fftvals{nn}(loc2,:)));
          cf2stderr(nn)=cf2stddev(nn)/sqrt(size(c.fftvals,2));
          cf1f0mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate))));
          cf1f0stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc1,:)),(c.fftvals{nn}(1,:))-avg_rate));
          cf1f0stderr(nn)=cf1f0stddev(nn)/sqrt(length(stimlist));
          cf2f1mean(nn)=abs(abs(mean(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))))));
          cf2f1stddev(nn)=std(divide_nozero((c.fftvals{nn}(loc2,:)),(c.fftvals{nn}(loc1,:))));
          cf2f1stderr(nn)=cf2f1stddev(nn)/sqrt(length(stimlist));
    cycg_f1curve{z}=[curve_x{z}; cf1meanc; cf1stddevc; cf1stderrc;];
    cycg_f2curve{z}=[curve_x{z}; cf2meanc; cf2stddevc; cf2stderrc;];
    cycg_f1f0curve{z}=[curve_x{z}; cf1f0meanc; cf1f0stddevc; cf1f0stderrc;];
    cycg_f2f1curve{z}=[curve_x{z}; cf2f1meanc; cf2f1stddevc; cf2f1stderrc;];
    f0curve{z}=[curve_x{z}; cf0mean; cf0stddev; cf0stderr;];
    f1curve{z}=[curve_x{z}; cf1mean; cf1stddev; cf1stderr;];
    f2curve{z}=[curve_x{z}; cf2mean; cf2stddev; cf2stderr;];
    f1f0curve{z}=[curve_x{z}; cf1f0mean; cf1f0stddev; cf1f0stderr;];
    f2f1curve{z}=[curve_x{z}; cf2f1mean; cf2f1stddev; cf2f1stderr;];
    f0vals{z}=cf0vals;f1vals{z}=cf1vals;f2vals{z}=cf2vals;f1f0vals{z}=cf1f0vals;f2f1vals{z}=cf2f1vals;

clear blankstruct;    
    
blankstruct.f0vals = f0vals; blankstruct.f1vals = f1vals;
blankstruct.f2vals = f2vals; blankstruct.f1f0vals = f1f0vals;
blankstruct.f2f1vals = f2f1vals;
blankstruct.vals2=vars; blankstruct.vals1=vals;
blankstruct.curve=curve; blankstruct.rast=rast;
blankstruct.cycg_curve=cycg_curve; blankstruct.cycg_rast=cycg_rast;
blankstruct.cyci_curve=cyci_curve; blankstruct.cyci_rast=cyci_rast;
blankstruct.cycg_f1curve = cycg_f1curve; blankstruct.cycg_f2curve = cycg_f2curve;
blankstruct.cycg_f1f0curve = cycg_f1f0curve; blankstruct.cycg_f2f1curve = cycg_f2f1curve;
blankstruct.cyci_f1curve = cyci_f1curve; blankstruct.cyci_f2curve = cyci_f2curve;
blankstruct.cyci_f1f0curve = cyci_f1f0curve; blankstruct.cyci_f2f1curve = cyci_f2f1curve;
blankstruct.f1curve = f1curve; blankstruct.f2curve = f2curve;
blankstruct.f0curve = f0curve;
blankstruct.f1f0curve = f1f0curve; blankstruct.f2f1curve = f2f1curve;

pc.computations.blank(i) = blankstruct;

 end;
end; % ~isempty(I.blankid)
pcn = pc;
