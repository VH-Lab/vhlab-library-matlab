function intrinsic_shift_analysis(dirname, SHIFT)
% INTRINSIC_SHIFT_ANALYSIS
% 
%   INTRINSIC_SHIFT_ANALYSIS(DIRNAME, SHIFT)
%
% Shifts all analyzed intrinsic signal imaging data for a given directory. This shifts
% all of the 'singlecondition.mat' files and 'singlecondition_stddev.mat' files.
% It applies a positive shift in SHIFT.
%  

for i=1:9,
	disp(['Now working on single condition ' int2str(i) '...']);

	img=load(['singlecondition000' int2str(i) '.mat']);
	imgsc=img.imgsc([SHIFT(2):end 1:SHIFT(2)-1],[SHIFT(1):end 1:SHIFT(1)-1]);
	save(['singlecondition_000' int2str(i) '.mat'],'imgsc');
	copyfile(['singlecondition000' int2str(i) '.mat'],...
		['singlecondition000' int2str(i) '-orig.mat']);
	copyfile(['singlecondition_000' int2str(i) '.mat'],...
		['singlecondition000' int2str(i) '.mat']);

	img=load(['singlecondition_stddev000' int2str(i) '.mat']);
	imgsc=img.imgsc([SHIFT(2):end 1:SHIFT(2)-1],[SHIFT(1):end 1:SHIFT(1)-1]);
	save(['singlecondition_stddev_000' int2str(i) '.mat'],'imgsc');
	copyfile(['singlecondition_stddev000' int2str(i) '.mat'],...
		['singlecondition_stddev000' int2str(i) '-orig.mat']);
	copyfile(['singlecondition_stddev_000' int2str(i) '.mat'],...
		['singlecondition_stddev000' int2str(i) '.mat']);
end;

