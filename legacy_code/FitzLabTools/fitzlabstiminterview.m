function b = fitzlabstiminterview(dirname)

%  FITZLABSTIMINTERVIEW - Create a stimulus timing structure from user responses
%
%  B = FITZLABSTIMINTERVIEW(DIRNAME)
%
%  Interviews the user for a description of a stimulus lacking a
%  log in a 'stims.mat' file.  The resulting stims.mat file is
%  stored in the directory DIRNAME.
%

disp(['Beginning user interview to describe stimuli in ' dirname '.']);

stimlist = [];
fid = fopen([fixpath(dirname) 'stimtimes.txt']);
if fid<0,
	error(['Sorry, could not find the stimtimes.txt file, so no analysis is possible.']);
end;
while ~feof(fid),
	stimline = fgets(fid);
	stimdata = sscanf(stimline,'%f');
	if length(stimdata)>2,
		stimlist(end+1) = stimdata(1);
	end;
end;

stimlist = unique(stimlist);

isi = input('What was the interstimulus interval?');
isis = input('Did the interstimulus interval occur before the stimulus (0/1)?');
if isis==1, isi = -1 * isi; end;

paramname = input('Enter the name of the varied parameter (must be valid variable name): ','s');
paramval = [];

argstr = '';
for i=1:length(stimlist),
	r = input(['Please enter parameter value for stimulus ' int2str(stimlist(i)) ': ']);
	paramval(end+1) = r;
	argstr = [argstr ',stimlist(' int2str(i) '),paramval(' int2str(i) ')'];
end;

thestr=['fitzcreatemti([fixpath(dirname ) ''stimtimes.txt''],isi,paramname' argstr ');'];

eval(thestr);

b = 1;
