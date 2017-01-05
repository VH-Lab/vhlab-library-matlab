function [newcell,assocs] = singleunitspotstim(ds, cell, cellname, display)

% DOSPOTSTIMANALYSIS - Analyze data from spot stim
%
%  [PARAMS,RASTEROBJ] =DOSPOTSTIMANALYSIS(SPIKETIMES,STIMTIMES,...
%     CONDITIONNAME,DISPLAY)
%
%  Extracts parameters for spot stimulus.
%
%  Expects spiketimes and stimtimes in seconds.
%
%  CONDITIONNAME should describe the type of stimulus (e.g., 'S+')
%
%  DISPLAY is 0/1; results will be displayed in a figure.
%  
%  PARAMS is a structure of results with fields
%
%    LATENCY - the latency in seconds
%    INITRESP - the initial response (mean, std_dev, std_err)
%    MAINTRESP - the response 300ms later (mean, std_dev, std_err)
%  

types = {'B ','W ','M+ ','M- ','S+ ','S- '};
NB = {'NB ',''};

if nargin==0,
	newcell = {};
	for i=1:length(types), for j=1:length(NB),
		newcell{end+1}=['Spot' types{i} NB{j} 'Peak latency'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Initial latency'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Peak firing rate']
		newcell{end+1}=['Spot' types{i} NB{j} 'Peak firing rate CV'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Phasic-Tonic index'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Center Initial Response'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Center Maintained Response'];
		newcell{end+1}=['Spot' types{i} NB{j} 'Center PSTH'];
	end; end;
	return;
end;

newcell = cell;
assoc = [];
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);


for i=1:length(types), for j=1:length(NB),
  name = ['Spot ' types{i} NB{j}],
  spottest = findassociate(cell,[name 'test'],'',''),
  if ~isempty(spottest),
	dirname = spottest.data;
	s = getstimscripttimestruct(ds,dirname);
	[s.mti,starttime] = fitzcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
	spotstim = get(s.stimscript,1);
	ps = getparameters(spotstim);
	df = struct(getdisplayprefs(spotstim));
	firstStimFrame = find(df.frames==4); firstStimFrame = firstStimFrame(1);
	offset = ps.center(2)/(600*1/0.006);

	stimtimes = [];
	for I=1:length(s.mti),
	    stimtimes(end+1) = s.mti{I}.frameTimes(firstStimFrame)+offset;
	end;

	inp.spikes= newcell;
	inp.triggers = {stimtimes};
	inp.condnames = {name};

	P.res = 0.001;
	P.interval = [ 0 1];
	P.normpsth = 1;
	P.showvar = 0;
	P.fracpsth = 0.5;
	P.psthmode = 0;
	P.showfrac = 1;
	P.cinterval = [0 s.mti{1}.startStopTimes(end)-s.mti{1}.frameTimes(firstStimFrame)];
	P.showcbars = 1;
	P.axessameheight = 1;

	if display,
		where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
		orient(where.figure,'landscape');
	else,
		where = [];
	end;

	ra = raster(inp,P,where);
	P = getparameters(ra);

	cr = getoutput(ra);

	bt = diff(cr.bins{1}(1:2)); % time of 1 bin
	l = size(cr.values{1},2);  % number of trials
	[mm,ii] = max(cr.counts{1});
	peak_latency = cr.bins{1}(ii);  % now we have peak latency
        lwbnd = max([1 ii-1]); hibnd = min([ii+1 length(cr.bins{1})]);
        peak_firingrate = sum(cr.counts{1}(lwbnd:hibnd))/(bt*l*(hibnd-lwbnd+1));
        pfrs = sum(cr.values{1}(lwbnd:hibnd,:));
        peak_firingrate_cv = std(pfrs)/mean(pfrs);
	% initial latency
	initinds = find(cr.counts{1}>=0.5*mm);
        if isempty(initinds)|peak_firingrate<65, init_latency = peak_latency;
        else,
		if initinds(1)>ii|initinds(1)==1,init_latency=peak_latency;
		else, init_latency=cr.bins{1}(initinds(1));
		end;
        end;
	 % early window is latency to latency plus 0.050
	 % late window is 300ms later unless that is beyond the end of stim
	ear = peak_latency + [0 0.050]; lat = peak_latency + 0.3 + [0 0.050];
	if max(lat)>0.5, lat = 0.45 + [0 0.050]; end;

        inpcs_spont = inp;
        inpcs_spont.triggers = { inpcs_spont.triggers{1} + 0.6 };
        ra_spont = raster(inpcs_spont,P,[]);
        crs = getoutput(ra_spont);
        spontrate = crs.ncounts(1);

	e1 = findclosest(cr.bins{1},ear(1));
	e2 = findclosest(cr.bins{1},ear(2));
	l1 = findclosest(cr.bins{1},lat(1));
	l2 = findclosest(cr.bins{1},lat(2));

	x=sum(cr.counts{1}(e1:e2))/(bt*l*(e2-e1+1));
	y=sum(cr.counts{1}(l1:l2))/(bt*l*(e2-e1+1));
	trans = (x-y)/x;

	replyear = []; replylat = [];  % get individual trial values for stats
	for I=1:l,
	        replyear(end+1) = sum(cr.values{1}(e1:e2,I))/(bt*(e2-e1+1));
	        replylat(end+1) = sum(cr.values{1}(l1:l2,I))/(bt*(l2-l1+1));
	end;

	params.initial_latency = init_latency;
	params.peak_latency = peak_latency;
	params.initresp = [ mean(replyear) std(replyear) std(replyear)/sqrt(l)];
	params.maintresp = [ mean(replylat) std(replylat) std(replylat)/sqrt(l)];
	params.trans = trans;
	params.peak_firingrate_cv = peak_firingrate_cv;
	params.psth = cr.counts{1};

	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Peak latency'],'owner','',...
		'data',peak_latency,'desc','Peak latency to centersurroundstim');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Initial latency'],'owner','',...
		'data',init_latency,'desc','Initial latency to centersurroundstim');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Peak firing rate'],'owner','',...
		'data',peak_firingrate,'desc','Peak firing rate to centersurroundstim');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Peak firing rate CV'],'owner','',...
		'data',peak_firingrate_cv,'desc','Peak firing rate coefficient of variation');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Phasic-Tonic index'],'owner','',...
		'data',trans,'desc','Phasic-Tonic index');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Center Initial Response'],'owner','',...
		'data',params.initresp,'desc','Center initial response');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Center Maintained Response'],'owner','',...
		'data',params.maintresp,'desc','Center Maintained Response');
	assoc(end+1) = struct('type',['Spot' types{i} NB{j} 'Center PSTH'],'owner','',...
		'data',cr.counts{1},'desc','Center PSTH');
end; % if not is empty test name

end; end; % loops over i, j

for i=1:length(assoc), newcell = associate(newcell,assoc(i)); end;
