function ncf = coordframe_image_undraw(cf)

try,
	delete(cf.data.handle);
end;

cf.data.handle = [];

ncf = cf;


