function [IM,header] = readivf(filename)

fid = fopen(filename,'r');

if fid<0, error(['Could not open file ' filename '.']); end;

header.size = fread(fid,1,'char',0,'l');
header.unknown = fread(fid,3,'char',0,'l');
header.xsize = fread(fid,1,'int',0,'l');
header.ysize = fread(fid,1,'int',0,'l');

IM = reshape(fread(fid,Inf,'float',0,'l'),header.xsize,header.ysize)';

fclose(fid);
