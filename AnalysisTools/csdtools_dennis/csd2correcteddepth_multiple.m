function correcteddepth_array = csd2correcteddepth_multiple(cellname_cell,csd_data_table,path,tfile)
% CSD2CORRECTEDDEPTH_MULTIPLE - Given a cell of cellnames, produce a
% structure containing cellnames in relation to correcteddepth
%
%Example:
%correcteddepth_array = csd2correcteddepth_multiple({'cell_extra_0003_001_2003_05_27','cell_extra_0005_001_2003_05_27'},'csd_data_table.txt','/Users/dennisou/Desktop/','t00001')

for i = 1:length(cellname_cell)
    correcteddepth_array{i}{1} = cellname_cell{i};
    correcteddepth_array{i}{2} = csd2correcteddepth_single(cellname_cell{i},csd_data_table,path,tfile);
end

end