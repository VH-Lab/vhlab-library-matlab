function intrinsic_average_directories(prefix, dirlist, outputdir)
% INTRINSIC_AVERAGE_DIRECTORIES - average data that was acquired in more than 1 intrinsic signal run
%
%    INTRINSIC_AVERAGE_DIRECTORIES(PREFIX, DIRLIST, OUTPUTDIR)
%
%  Performs an average of intrinsic signal data over multiple directories.
%
%  PREFIX should be the parent directory where the data directories are located.
%  DIRLIST should be a cell list of directories.  The results are saved to 
%  the directory OUTPUTDIR.
%
%  It is assumed that all directories have the same number of stimuli and that
%  the stimuli with the same STIMID can be averaged together.
%  

d = dir([prefix filesep dirlist{1} filesep 'singlecondition0*.mat']); % gets the number of images

if exist(outputdir)~=7, 
	try,
		mkdir(outputdir);
	catch,
		error(['Could not open or create directory ' outputdir '.']);
	end;
end;

parameters = load([prefix filesep dirlist{1} filesep 'singleconditionprogress.mat']);

copyfile([prefix filesep dirlist{1} filesep 'stimvalues.mat'],...
	[prefix filesep outputdir filesep 'stimvalues.mat']);


for i=1:length(d),
	im = load([prefix filesep dirlist{1} filesep d(i).name]);
	imgsc = im.imgsc;
	for j=2:length(dirlist)
		im = load([prefix filesep dirlist{j} filesep d(i).name]);
		imgsc = imgsc + im.imgsc;
	end;
	imgsc = imgsc / length(dirlist);
	save([prefix filesep outputdir filesep d(i).name],'imgsc');

	f = strfind(lower(d(i).name),'.mat');
	newname = d(i).name;
	newname(f:end) = '';

	imwrite(uint16( round(2^15+parameters.multiplier*imgsc)),...
		[fixpath([prefix filesep outputdir]) filesep newname '.tiff'],...
			'tif');,
end;


