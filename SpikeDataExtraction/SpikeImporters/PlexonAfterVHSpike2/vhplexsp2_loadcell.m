function [sd,cellname] = vhplexsp2_loadcell(ds, name, ref, index)

cellname = nameref2cellname(ds,name,ref,index+200);

S = warning('off');
if exist(getexperimentfile(ds))==2,
    oldcell=load(getexperimentfile(ds),cellname,'-mat');
else, oldcell = [];
end;
warning(S);
if isfield(oldcell,cellname),
	oldcell=getfield(oldcell,cellname);
else,
	oldcell = cksmultipleunit([],cellname,'',[],[]);
end;

  % check number of intervals to make sure corresponds
  % if so, check most recent directory

[A,I] = findassociate(oldcell,'loadvhplexcelldata','loadvhplexcell','');

if isempty(A),
	lfcd = struct('interval',[],'dirname','','starttime',[]);
	lfcd = lfcd([]);
else, lfcd = A.data;
	oldcell = disassociate(oldcell,I);
end;

T = gettests(ds,name,ref);  % get all test directories associated w/ name ref pair

pfix=getpathname(ds);

spikes = [];
ints = [];

for t=1:length(T),
	ind = find(strcmp(T{t},{lfcd.dirname}));
	filenum = 1;
	try, f = loadStructArray([pfix filesep T{t} filesep 'singleEC.txt']);
	catch, f = [];
	end;
	for j=1:length(f),
		if strcmp(f(j).name,name)&(f(j).ref==ref), filenum = f(j).filenum; end;
	end;

	% spikes are always read anew in case they have changed
	[newspikes,aretherespikes] = getspikesfromdir([pfix filesep T{t}],filenum,index);

	C1 = isempty(ind);
	if ~C1,
		ind = ind(1);
		C1 = isempty(lfcd(ind).interval);
	end;
	if C1,  % if isempty(ind)|isempty(lcfd(ind).interval)
		[interval,starttime]=getintervalfromdir([pfix filesep T{t}],length(T),aretherespikes);
		lfcd(end+1) = struct('interval',interval,'dirname',T{t},'starttime',starttime);
		newspikes = newspikes + starttime;
	else,
		interval = lfcd(ind).interval;
		newspikes = newspikes + lfcd(ind).starttime;
	end;
	ints = [ints;interval];
	spikes = [spikes newspikes];
end;

if ~isempty(ints),
	[y,inds] = sort({lfcd.dirname});
	lcdf = lfcd(inds);  % just in case there are any duplicates
	sd = cksmultipleunit(ints,cellname,'',spikes,[]);
	sd = associate(sd,struct('type','loadvhplexcelldata','owner','loadvhplexcell','data',lfcd,'desc',''));
else, sd = [];
end;

function [spikes,istherespikerecord]=getspikesfromdir(dirname,filenum,index)

fname = [dirname filesep 'spiketimes_' int2str(filenum) '_' sprintf('%.3d',index) '.txt'];
fname = [dirname filesep 'plexonspikes-sp2.txt'];
if exist(fname),
	istherespikerecord = 1;
	spikedata = load(fname,'-ascii');
	goodindexes = find(spikedata(:,1)==filenum&spikedata(:,2)==index);
	spikes = spikedata(goodindexes,3);
	spikes = spikes(:)'; % should be a row
else, spikes = [];  istherespikerecord = 0;
end;

function [interval,starttime] = getintervalfromdir(dirname,dirnumber,therearespikes)
dirname,
starttime = 0;
if exist([dirname filesep 'stims.mat'])&exist([dirname filesep 'stimtimes.txt']),
	g = load([dirname filesep 'stims.mat']);
	[mti2,starttime]=tpcorrectmti(g.MTI2,[dirname filesep 'stimtimes.txt'],1);
	interval = [starttime mti2{end}.frameTimes(end)+10], % assume 10 sec of post recording
	interval = interval; % + g.start;
	starttime = g.start;
elseif therearespikes,
	starttime = 10000*(dirnumber-1);
	interval = [ 0 max(spikes)+10] + starttime;
else,
	interval = [];
end;
