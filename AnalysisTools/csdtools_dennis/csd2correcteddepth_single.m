function depth = csd2correcteddepth_single(cellname,csd_data_table,path,tfile)
% CSDCORRECTEDDEPTH_SINGLE - Given a cellname, produce the corrected depth
%
%  DEPTH = CSD2CORRECTEDDEPTH(CELLNAME, CSD_DATA_TABLE)
%
%  Inputs:  CELLNAME, the cell name in a string format, such as
%                  'cell_ctx_0003_001_2003_05_27'
%           CSD_DATA_TABLE, the table that has the conversion between
%                  channels and estimated depth in cortex
%
%  Output:  DEPTH, the estimated depth, in microns (as a number)

% how do you identify the channel number from the cell name?
% step 1: look at the name and reference ('ctx' and 3 above)
%            [NAMEREF,INDEX,DATESTR] = cellname2nameref(CELLNAME)
% step 2: if the cell has reference 'extraN' where N is a number, then that number is the channel
%        if it is just 'extra', then use the reference number as the channel


%[NAMEREF,INDEX,DATESTR] = cellname2nameref('cell_extra_0003_001_2003_05_27')


%NAMEREF = name: 'ctx'
%           ref: 3
%
%INDEX = 1
%
%DATESTR = 2003_05_27

%Test statement:
%depth = csd2correcteddepth_single('cell_extra_0003_001_2003_05_27','csd_data_table.txt','/Users/dennisou/Desktop/','t00001')

%mypath/2014-05-05/
%possibly store your depth info in mypath/2014-05-05/csd_depth_info.txt

[NAMEREF,INDEX,DATESTR] = cellname2nameref(cellname);

%Channel 20: 343.23432 um

current = pwd;
location = [path tfile];

cd(location)
fid = fopen(csd_data_table,'r');
C = textscan(fid, '%s %d: %f %s');
fclose(fid);

if strcmp(NAMEREF.name,'extra')
    channel = NAMEREF.ref;
else    %NAMEREF.name = extraN
    channel = str2num(NAMEREF.name(6:end));
end

for i = 1:length(C{2})
    if channel == C{2}(i)
        depth = C{3}(i);
        cd(current)
        return;
    end
end

end


