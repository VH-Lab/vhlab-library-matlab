function [sd,cellname] = vhspike2_loadcell(ds, name, ref, index)

cellname = nameref2cellname(ds,name,ref,index+250);

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

	% edit here -- probably always replace the vhspike2_loadcell info

[A,I] = findassociate(oldcell,'vhspike2_loadcelldata','vhspike2_loadcell','');

if isempty(A)|1,
	lfcd = struct('interval',[],'dirname','','starttime',[],'clusterinfo',[]);
	lfcd = lfcd([]);
else,
	lfcd = A.data;
	oldcell = disassociate(oldcell,I);
end;

T = gettests(ds,name,ref);  % get all test directories associated w/ name ref pair

pfix=getpathname(ds);

spikes = [];
ints = [];

for t=1:length(T),
	T{t},
	ind = find(strcmp(T{t},{lfcd.dirname}));
	% spikes are always read anew in case they have changed
	[newspikes,aretherespikes,clusterinfo] = getspikesfromdir([pfix filesep T{t}],name, ref, index);

	length(newspikes),

	C1 = isempty(ind);
	if ~C1,
		ind = ind(1);
		C1 = isempty(lfcd(ind).interval);
	end;
	if 1|C1,  % if isempty(ind)|isempty(lcfd(ind).interval)
		[interval,starttime]=getintervalfromdir([pfix filesep T{t}],length(T),aretherespikes);
		lfcd(end+1) = struct('interval',interval,'dirname',T{t},'starttime',starttime,'clusterinfo',clusterinfo);
		newspikes = newspikes + starttime;
	else,
		interval = lfcd(ind).interval;
		newspikes = newspikes + lfcd(ind).starttime;
	end;
	ints = [ints;interval];
	spikes = [spikes(:)' newspikes(:)'];
end;

isgood = 0;
good_example = 0;
for i=1:length(lfcd),
	if ~strcmp(lfcd(i).clusterinfo.qualitylabel,'Not usable'),
		isgood = 1;
		good_example = i;
	end;
end;

if isgood&~isempty(ints),
	[y,inds] = sort({lfcd.dirname});
	lcdf = lfcd(inds);  % just in case there are any duplicates
	sd = cksmultipleunit(ints,cellname,'',spikes,[]);
	sd = associate(sd,struct('type','vhspike2_loadcelldata','owner','vhspike2_loadcell','data',lfcd,'desc',''));
	sd = associate(sd,struct('type','vhspike2_clusterinfo','owner','vhspike2_loadcell','data',lfcd(good_example).clusterinfo,'desc','cluster info for a good directory'));
else, sd = [];
end;

function [spikes,istherespikerecord,clusterinfo]=getspikesfromdir(dirname,name,ref,index)

fname = [dirname filesep 'vhspike2_st_' name '_' int2str(ref) '_' sprintf('%.3d',index) '.txt'];
try,
	clusterinfo = load([dirname filesep 'vhspike2_ci_' name '_' int2str(ref) '_' sprintf('%.3d',index) '.mat'],'-mat');
	clusterinfo = clusterinfo.clusterinfo;
catch,
	clusterinfo.qualitylabel = 'Not usable';
end;
if exist(fname)&~strcmp(clusterinfo.qualitylabel,'Not usable'),
	istherespikerecord = 1;
	spikes = load(fname,'-ascii');
	shiftscale = load([dirname filesep 'vhspike2_spike22spike2time.txt'],'-ascii');
	spikes = shiftscale(1)+shiftscale(2)*spikes;
else,
	spikes = [];
	istherespikerecord = 0;
end;

function [interval,starttime] = getintervalfromdir(dirname,dirnumber,therearespikes)
%dirname,
starttime = 0;
if exist([dirname filesep 'stims.mat'])&exist([dirname filesep 'stimtimes.txt']),
	g = load([dirname filesep 'stims.mat']);
	[mti2,starttime]=tpcorrectmti(g.MTI2,[dirname filesep 'stimtimes.txt'],1);
	interval = [starttime mti2{end}.frameTimes(end)+10]; % assume 10 sec of post recording
	interval = interval; % + g.start;
	starttime = g.start;
	clear g;
elseif therearespikes,
	starttime = 10000*(dirnumber-1);
	interval = [ 0 max(spikes)+10] + starttime;
else,
	interval = [];
end;

