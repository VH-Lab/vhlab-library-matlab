function artificialintrinsicdata(dirname)

img0 = 2000+(zeros(100,50));  % no need to have a large image here

[X,Y] = meshgrid(1:50,1:100);

noise = 10;

N = 8; % 8 stims, not including 1 blank

T = 20; % number of trials

F = 2 * 8; % number of data frames

signal = 2;  % generous signal, 1/1000 dF/F

stimorder = [];

for i=1:T, stimorder = [stimorder randperm(N+1)]; end;

stimvalues = [0:180/N:180-180/N NaN];

paramname = 'angle';

save([fixpath(dirname) 'stimorder.mat'],'stimorder','-mat');
save([fixpath(dirname) 'stimvalues.mat'],'stimvalues','-mat');
save([fixpath(dirname) 'paramname.mat'],'paramname','-mat');

for i=1:length(stimorder),
	for f=1:F,
		img = img0+noise*rand(size(img0))+double((f~=1)&stimorder(i)~=9)*...
			-rectify(signal*sin(2*pi.*X./50+stimorder(i)*2*pi/N));
		imwrite(uint16(img),['stim' sprintf('%0.4d',i) 'frame' sprintf('%0.3d',f) '.tiff'],'tif');
	end;
end;

