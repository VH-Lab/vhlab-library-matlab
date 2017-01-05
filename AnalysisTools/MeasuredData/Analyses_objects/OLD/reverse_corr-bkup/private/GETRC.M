function rc_im = getrc(rc)

p = getparameters(rc);

if eqlen(p.datatoview,[1 0 0]),
	rc_im = rc.computations.reverse_corr.rc_avg(1,:,:,:,:);
else, rc_im = rc.computations.reverse_corr.rc_avg(1,:,:,:,:);
end;
