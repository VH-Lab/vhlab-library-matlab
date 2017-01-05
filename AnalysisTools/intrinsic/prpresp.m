function [prpr] = prpresp(IMs,prpI)

for i=1:size(IMs,3),
	im = IMs(:,:,i);
	for j=1:length(prpI),
		prpr{j}(i) = mean(mean(im(prpI{j})));
        end;
end;
