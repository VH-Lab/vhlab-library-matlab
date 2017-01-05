function [IMs,roipts] = analyzeintrinsicori(dirname, IMs, xi, conditions);

if 0,

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

if exist([dirname filesep 'correctImgs.mat'])~=2,
	disp(['Filtering images. Will take several minutes.']);
	for i=1:size(IMs,3),
		im0 = IMs(:,:,i);
		im0 = im0-conv2(im0,ones(100)/sum(sum(ones(100))),'same');
		im0 = medfilt2(im0,[5 5]);
		IMs(:,:,i) = im0;
	end;
	save([dirname filesep 'correctImgs.mat'],'IMs');
else, g = load([dirname filesep 'correctImgs.mat']); IMs = g.IMs; clear g;
end;

return;
R = []; HINT = []; LOWERB = []; UPPERB = [];
for i=1:size(IMs,3),
	im0 = IMs(:,:,i);
	R(i,:) = -im0(roipts);
end;

range = max(R)-min(R);
[MX,Opi]=max(R);
%HINT = [min(R)' range' xi(Opi)' repmat(45,1,size(R,2))' range'  repmat(180,1,size(R,2))']';
%LOWERB = [ min(R)'-3*range' -3*range' repmat(0,1,size(R,2))' repmat(xi(1)/2,1,size(R,2))' -3*range' repmat(130,1,size(R,2))']';
%UPPERB = [ max(R)'+3*range'  3*range' repmat(179.999,1,size(R,2))' repmat(180,1,size(R,2))' 3*range' repmat(230,1,size(R,2))']';
DXI = diff(xi);
HINT = [min(R)' range' xi(Opi)' repmat(45,1,size(R,2))' ]';
LOWERB = [ min(R)'-3*range' repmat(0,1,size(R,2))' repmat(0,1,size(R,2))' repmat(DXI(1)/2,1,size(R,2))' ]';
UPPERB = [ max(R)'+3*range'  3*range' repmat(179.9999,1,size(R,2))' repmat(180,1,size(R,2))']';

disp(['Beginning fit.']);

 % P = levmar_fit(3,xi,R,HINT,LOWERB,UPPERB,180);
P = [];
return;
for i=1:100:size(R,2),
	start = i; stop = i+99;
	Pn = levmar_fit(1,xi,R(:,start:stop),HINT(:,start:stop),LOWERB(:,start:stop),UPPERB(:,start:stop),180);
	P = [P Pn];
	disp(['Done with ' int2str(stop) ' of ' int2str(size(R,2)) '.']);
end;

