function condstr = get_slice_condition(filename)

condstr = '';

[pathstr,name] = fileparts(filename);

fid = fopen([fixpath(pathstr) 'conditions.txt'],'rt');
while 1,
        theline = fgetl(fid);
        if ~ischar(theline), break;
        else,
                ind = findstr(',',theline);
                eval(['mylist = ' theline(ind+1:end) ';']);
                if ~isempty(find(str2num(name)==mylist)),
                        condstr = theline(1:ind-1);
                        fclose(fid);
                        return;
                end;
        end;
end;
fclose(fid);

