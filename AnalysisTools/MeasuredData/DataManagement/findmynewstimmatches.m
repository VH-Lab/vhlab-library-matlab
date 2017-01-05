function [dirs,totaldirlist,whatvaries,selfmaclist,selfsplist] = findmynewstimmatches(pathname, thedir)

dirs = {};

ds = dirstruct(pathname);

fname = [fixpath([getpathname(ds) filesep thedir]) 'stimtimes.txt'];
fid = fopen(fname,'rt');

if fid<0, return; end;

sp2_times = [];
sp2_stimnum = [];

while ~feof(fid),
    stimline = fgets(fid);
    if ~isempty(stimline)&~(eqlen(stimline,-1));
        stimdata = sscanf(stimline,'%f');
        if ~isempty(stimdata),
            sp2_times(end+1) = stimdata(2);
            sp2_stimnum(end+1) = stimdata(1);
        end;
    end;
end;

selfsplist = sp2_stimnum;

% now loop over mti files and check for matches

mydir = dir(getpathname(ds));

totaldirlist = {}; whatvaries = {};

for i=1:length(mydir),
    if mydir(i).isdir&~eqlen(mydir(i).name,'.')&~eqlen(mydir(i).name,'..'),
        mac_stimid = [];
        if exist([getpathname(ds) filesep mydir(i).name filesep 'stims.mat'])==2,
            g = load([getpathname(ds) filesep mydir(i).name filesep 'stims.mat'],'-mat');
            mti = g.MTI2;
            s = g.saveScript;
            totaldirlist{end+1} = mydir(i).name;
            whatvaries{end+1} = sswhatvaries(s);
            for j=1:length(mti),
                mac_stimid(end+1) = mti{j}.stimid;
            end;
            if eqlen(mac_stimid(:),sp2_stimnum(:)), dirs{end+1} = mydir(i).name; end;
            if strcmp(mydir(i).name,thedir), selfmaclist = mac_stimid; end;
        end;
    end;
    
end;