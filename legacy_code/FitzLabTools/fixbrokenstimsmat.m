function fixbrokenstimsmat(dirname)

filename = [dirname filesep 'stimtimes.txt'];
g = load([dirname filesep 'stims.mat'],'-mat');
mti = g.MTI2;
ss = g.saveScript;
ISI = 3;

fid = fopen(filename);

if fid<0, error(['Could not open file ' filename ', with error ' lasterr '.']); end;

 % first get multiplier between two timebases and then convert

sp2_times = [];
sp2_stimnum = [];

while ~feof(fid),
    stimline = fgets(fid),
    if ~isempty(stimline)&~eqlen(-1,stimline),
        stimdata = sscanf(stimline,'%f'),
        if ~isempty(stimdata),
            try,
                sp2_times(end+1) = stimdata(2);
                sp2_stimnum(end+1) = stimdata(1);
            catch, error(['error in  ' filename '.']);
            end;
            %disp(['Mac stim ' int2str(mac_stimid(end)) ', spike2 stim: ' int2str(stimdata(1)) '.']);
            %if mac_stimid(end)~=stimdata(1), error(['Stim order from stim computer does not match that recorded in Spike2 in filename ' filename]); end;
        end;
    end;
end;

MTI2 = {mti{:}};

for i=1:size(sp2_times,2),
    MTI2{i} = mti{1};
    MTI2{i}.stimid = sp2_stimnum(i);
    MTI2{i}.startStopTimes = [sp2_times(i) sp2_times(i) sp2_times(i)+duration(get(ss,sp2_stimnum(i))) sp2_times(i)+duration(get(ss,sp2_stimnum(i)))+ISI];
    MTI2{i}.frameTimes = [sp2_times(i):0.01:(sp2_times(i)+duration(get(ss,sp2_stimnum(i))))];
end;

saveScript = setDisplayMethod(ss,2,sp2_stimnum);

try, copyfile([dirname filesep 'stims.mat'],[dirname filesep 'stimsmatbackup.mat']); end; 

start=0;

save([dirname filesep 'stims.mat'],'saveScript','MTI2','start','-mat');