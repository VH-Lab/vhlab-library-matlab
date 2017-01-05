function ncf = coordframe_image_draw(cf)

A = isempty(cf.data.handle);
B = ~ishandle(cf.data.handle);
if isempty(B), B = 0; end;
A,B,
if A|B,
	cf.data.handle = image(cf.data.data);
	colormap(cf.data.cmap);
	% move the image to the back of the stack
	ch = get(gca,'children');
	ind = find(ch==cf.data.handle);
	ch = ch([setdiff(1:length(ch),ind) ind]);
	set(gca,'children',ch);
	set(gca,'ydir','reverse');
end;

ncf = cf;
