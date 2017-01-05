function [P, Rfit, err, R2] = fitintrinsicsinglegaussian(theimage, angles, filename)

P = []; err = []; R2 = []; Rfit = [];

for i=1:size(theimage,1),
	for j=1:size(theimage,2),
		[P(i,j,:),Rfit(i,j,:),err(i,j)] = fitsinglegaussian2(squeeze(theimage(i,j,:)),angles,180,[30]);
		R2(i,j) = 1-(sum(Rfit(i,j,:).^2))/sum((-mean(theimage(i,j,:)+theimage(i,j,:)).^2));
	end;
	disp(['Finished row ' int2str(i) ' of ' int2str(size(theimage,1)) '.']);
    if nargin>2,
        disp(['Saving progress to ' filename '.']);
        save(filename,'P','Rfit','err','R2','i','theimage','angles','filename','-mat');
    end;
end;
