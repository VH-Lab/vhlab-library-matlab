function cellinfo = read_unitquality(ds)
% READ_UNITQUALITY Read the unitquality.txt file and prepare a list of cells to include
%
%  CELLINFO = READ_UNITQUALITY(DS)
%
%  Reads the 'unitquality.txt' file and prepares a list of cell information to include
%  in further analysis.  The file is assumed to be in the root directory of the directory
%  described by the DIRSTRUCT DS.
%
%  It is assumed that all of the channels are 
%
%  See also: UNITQUALITY
%

unit_shift = 400; 

pathn = getpathname(ds);

uq = loadStructArray([pathn filesep 'unitquality.txt']);

channelshift = 0;

if exist([pathn filesep 'unitquality_channelshift.txt'],'file'),
    channelshift = load([pathn filesep 'unitquality_channelshift.txt'],'-ascii');
    channelshift = channelshift(1); % make sure we take only the first number
end;


 % first expand to 1 cell per record

uq2 = uq([]);

for i=1:length(uq),
	base_uq = uq(1); % need to reassign all channels
	base_uq.channel = uq(i).channel;
	base_uq.goodtestdirs = string2cell(uq(i).goodtestdirs,',');
	base_uq.comment = uq(i).comment;
	switch lower(uq(i).qualitycode),
		case {'multiunit','mu'},
			base_uq.qualitycode = 'Multi-unit';
		case {'excellent','e'},
			base_uq.qualitycode = 'Excellent';
		case {'good','g'},
			base_uq.qualitycode = 'Good';
		case {'nu','notuseable'},
			base_uq.qualitycode = 'Not useable';
	end;
	if ischar(uq(i).unit),
		unitlist = string2cell(uq(i).unit,',');
		for j=1:length(unitlist),
			if unitlist{j}(1)>=double('a')&unitlist{j}(1)<=double('z'),
				unit = unit_shift + 1 + unitlist{j}(1) - double('a');
			elseif unitlist{j}(1)>=double('A')&unitlist{j}(1)<=double('Z'),
				unit = unit_shift + 1 + unitlist{j}(1) - double('A');
			else,
				unit = str2num(unitlist{j});
			end;
			base_uq.unit = unit;
			uq2(end+1) = base_uq;
		end;
	else,
		unitlist = uq(i).unit;
		for j=1:length(unitlist),
			base_uq.unit = unitlist(j);
			uq2(end+1) = base_uq;
		end;
	end;
end;

% now convert from these records to name/ref/index

cellinfo = struct('name',[],'ref',[],'index',[],'goodtestdirs',[],'quality',[],'comment',[]);

for i=1:length(uq2),
	celli = cellinfo(1);
%	celli.name = ['extra' int2str(uq2(i).channel)];
%	celli.ref = 1;

	celli.name = ['extra'];
	celli.ref = uq2(i).channel + channelshift;
	celli.index = uq2(i).unit;
	celli.goodtestdirs = uq2(i).goodtestdirs;
	celli.quality = uq2(i).qualitycode;
	celli.comment = uq2(i).comment;
	if i==1,
		cellinfo = celli;
	else,
		cellinfo(end+1) = celli;
	end;
end;


