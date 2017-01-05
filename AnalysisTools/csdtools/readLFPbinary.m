function D = readLFPbinary(filename)

%  READLFPBINARY - Reads extracted LFP file into MATLAB
%
%      D = READLFPBINARY(FILENAME)
%
%  Attempts to read in the binary file FILENAME.  The first
%  row contains the sample times and additional rows contain
%  samples for each trial.


fid = fopen(filename);

head = fread(fid,2,'int32','ieee-le');

 % head = [ number of trials    number of samples  ]
 % must add 1 to head(1) because of time samples 
D = reshape(fread(fid,(head(1)+1)*(head(2)),'float32','ieee-le'),(head(2)),head(1)+1);

fclose(fid);
