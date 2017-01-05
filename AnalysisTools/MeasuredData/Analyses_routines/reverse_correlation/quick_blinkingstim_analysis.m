function [avgstim,img_hz]=quick_blinkingstim_analysis(ds, mycell, mycellname, dirname, mn, mx, step)

	[avgstim,gridsize,numspikes]=singleunit_rc(ds, mycell, mycellname, dirname, mn, mx, step);
	[img,img_hz] = rc_image(avgstim,gridsize,step,numspikes);
	figure;
	imgh=imagesc(img_hz(:,:,1)); colorbar;
	ud = workspace2struct;
	set(imgh,'buttondownfcn',@mycallback,'userdata',ud);
end
	function mycallback(arg1,arg2)
		pt = get(gca,'currentpoint');
		pt = round(pt(1,1:2)), % get x/y
		ud = get(gcbo,'userdata');
		gridind = sub2ind(ud.gridsize,pt(2),pt(1));
		disp(['Grid point is ' int2str(gridind)]);
		blinkingstim_raster(ud.ds,ud.mycell,ud.mycellname,ud.dirname,gridind,ud.mn,ud.mx);
	end
