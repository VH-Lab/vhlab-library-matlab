function [sd,cellname] = vhplexLV_loadcell(ds, name, ref, index)
% VHPLEXVH_LOADCELL - Load in a cell with a given name, reference, and index value after Plexon spike-sorting
%
%  [SD, CELLNAME] = VHPLEXLV_LOADCELL(DS, NAME, REF, INDEX)
%
%  Loads the spike time data from LabView records sorted with Plexon into a CKSMULTIUNIT object
%  named SD, and also names the cell CELLNAME.
%
%  Inputs: DS - the DIRSTRUCT object that manages the experiment; NAME - the
%  name of the name/reference pair to import; REF - the reference number, and
%  INDEX the cluster index to import


cellname = nameref2cellname(ds,name,ref,index+400);

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
	filenum = 0;
	try,
		f = loadStructArray([pfix filesep T{t} filesep 'vhlv_channelgrouping.txt']);
	catch,
		f = [];
	end;
	if isempty(f),
		filenum_offset = 0;
		num_singleECs = 0;
		z = loadStructArray([getpathname(ds) filesep T{t} filesep 'reference.txt']);
		for j=1:length(z),
			if strcmp(z(j).type,'singleEC'),
				num_singleECs = num_singleECs + 1;
			end;
			if (strcmp(z(j).name,name) & z(j).ref == ref),
				filenum_offset = num_singleECs;
			end;
		end;
		filenum = filenum + filenum_offset;
	else,
		for j=1:length(f),
			if strcmp(f(j).name,name)&(f(j).ref==ref),
				filenum = f(j).channel_list;
			end;
		end;
	end;

	% spikes are always read anew in case they have changed
	[newspikes,aretherespikes] = getspikesfromdir([pfix filesep T{t}],filenum,index);

	C1 = isempty(ind);
	if ~C1,
		ind = ind(1);
		C1 = isempty(lfcd(ind).interval);
	end;
	if 1|C1,  % if isempty(ind)|isempty(lcfd(ind).interval)
                disp(['Attempting to import (VHplexLV): ' name ' | ' int2str(ref) ' ' int2str(index) ' ' T{t}]);
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

%fname = [dirname filesep 'spiketimes_' int2str(filenum) '_' sprintf('%.3d',index) '.txt'];
fname = [dirname filesep 'plexonspikes-lv.txt'];

if exist(fname),
	istherespikerecord = 1;
	spikedata = load(fname,'-ascii');
	goodindexes = find(spikedata(:,1)==filenum&spikedata(:,2)==index);
	spikes = spikedata(goodindexes,3);
	spikes = spikes(:)'; % should be a row
	vhlv_sync2spike2(dirname);
	shiftscale = load([dirname filesep 'vhlv_lv2spike2time.txt'],'-ascii');
	spikes = shiftscale(1) + shiftscale(2) * spikes;
else,
	spikes = [];
	istherespikerecord = 0;
end;

function [interval,starttime] = getintervalfromdir(dirname,dirnumber,therearespikes)
starttime = 0;
if exist([dirname filesep 'stims.mat'])&exist([dirname filesep 'stimtimes.txt']),
	g = load([dirname filesep 'stims.mat']);
	[mti2,starttime]=tpcorrectmti(g.MTI2,[dirname filesep 'stimtimes.txt'],1);
	if isempty(mti2{end}.frameTimes),
		interval = [starttime mti2{end}.startStopTimes(4) + 10 ]; % assume 10 sec of post recording
	else,
		interval = [starttime mti2{end}.frameTimes(end)+10]; % assume 10 sec of post recording
	end;
	interval = interval; % + g.start;
	starttime = g.start;
elseif therearespikes,
	starttime = 10000*(dirnumber-1);
	interval = [ 0 max(spikes)+10] + starttime;
else,
	interval = [];
end;
