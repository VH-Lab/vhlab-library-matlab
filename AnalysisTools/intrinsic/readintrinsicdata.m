function [IMs,roipts,bgpoints] = readintrinsicdata(dirname, conditions);


d = dir([dirname filesep '*.ivf']);  % figure out file scheme
for i=1:length(d),
	A = findstr(d(i).name,'c0');
	if ~isempty(A),
		A = A(end);
		filebegin = d(i).name(1:A-1);
		fileend = d(i).name(A+2:end);
	end;
end;

IMs = [];
for i=1:length(conditions),
	im = readivf([dirname filesep filebegin 'c' int2str(conditions(i)) fileend]);
	IMs = cat(3,IMs,im);
end;

if exist([dirname filesep 'roipts.mat']),
	g = load([dirname filesep 'roipts.mat']);
	roipts = g.roipts;
else,
	r = input('Do you want to select an ROI? (y/n)','s');
	if r=='Y'|r=='y',
		imagedisplay(mean(IMs,3));
		done = 0;
		while ~done,
			disp(['Click points and hit return when finished.']);
			[roipts,xi,yi]=roipoly();
			hold on; h=plot(xi,yi);
			r = input('Are you happy w/ the roi? (y/n)','s');
			if r=='Y'|r=='y', done = 1; else, delete(h); end;
		end;
		close;
		save([dirname filesep 'roipts.mat'],'roipts');
	end;
end;

if exist([dirname filesep 'bgpoints.mat']),
	g = load([dirname filesep 'bgpoints.mat']);
	bgpoints= g.bgpoints;
else,
	r = input('Do you want to select a background ROI? (y/n)','s');
	if r=='Y'|r=='y',
		imagedisplay(mean(IMs,3));
		done = 0;
		while ~done,
			disp(['Click points and hit return when finished.']);
			[bgpoints,xi,yi]=roipoly();
			hold on; h=plot(xi,yi);
			r = input('Are you happy w/ the roi? (y/n)','s');
			if r=='Y'|r=='y', done = 1; else, delete(h); end;
		end;
		close;
		save([dirname filesep 'bgpoints.mat'],'bgpoints');
	end;
end;

