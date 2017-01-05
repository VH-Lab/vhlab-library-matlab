function plot_ot_map_compare(map1,map2,mask, plotimage, plotgraph)

[mapangdiff,angs1,angs2] = compare_ot_maps(map1,map2);

if plotimage,
	figure;
	badpixels = find(mask~=0);
	mapangdiff(badpixels)=90;
	image(mapangdiff+90);
	colormap(gray(180));
end;

if plotgraph,
	figure;
	goodpixels = find(mask==0);
	binsx = [ 0:5:180];
	binsy = [ -90:5:90];
	mat = [mapangdiff(goodpixels) angs1(goodpixels)];
	vXCoord = 0.5*(binsx(1:end-1)+binsx(2:end));
	vYCoord = 0.5*(binsy(1:end-1)+binsy(2:end));
	mHist = hist2d(mat,binsy,binsx);
	pcolor(vXCoord,vYCoord,100*mHist./repmat(sum(mHist),size(mHist,1),1));
	colorbar;
end;
