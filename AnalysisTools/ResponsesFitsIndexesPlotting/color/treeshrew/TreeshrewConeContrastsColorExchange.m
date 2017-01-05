function [Lc,Sc,Rc,RGB_plus,RGB_minus] = TreeshrewConeContrastsColorExchange(thestimscript)

CONEMON = treeshrewcones;

RGB_plus = [];
RGB_minus = [];

if isa(thestimscript,'stimscript'),
	for g=1:numStims(thestimscript),
		p = getparameters(get(thestimscript,g));
		if ~isfield(p,'isblank')&p.contrast>0&~eqlen(p.chromhigh,p.chromlow),
			RGB_plus(:,end+1) = p.chromhigh';
			RGB_minus(:,end+1) = p.chromlow';
		end;
	end;
else,
	switch thestimscript,
		case 1, % color exchange classic
			steps=[0 0 0.8;0 0.08 0.8;0 0.13 0.8;0 0.16 0.8;0 0.19 0.8;0 0.22 0.8;0 0.3 0.8;0 0.4 0.8;0 0.6 0.8;0 0.8 0.8];
		case 2, % color exchange barrage
			steps= [0 0.1009 0.9091;0 0.1455 0.8545;0 0.1900 0.8000;0 0.2345 0.7455;0 0.2791 0.6909;0 0.3236 0.6364;0 0.3682 0.5818;0 0.4127 0.5273;0 0.4573 0.4727;0 0.5018 0.4182;0 0.5464 0.3636;0 0.5909 0.3091;0 0.6355 0.2545;0 0.6800 0.2000;0 0.7245 0.1455;0 0.7691  0.0909];
		case 3, % dacey-like color exchange
			steps=[        0   -0.4859    0.3833
				 0   -0.2741    0.5638
			         0   -0.0435    0.7060
			         0    0.1900    0.8000
			         0    0.4106    0.8395
			         0    0.6031    0.8218
			         0    0.7546    0.7481
			         0    0.8547    0.6234
			         0    0.8965    0.4563
			         0    0.8772    0.2580
			         0    0.7981    0.0422
			         0    0.6647   -0.1766
			         0    0.4859   -0.3833];
		case 4, % dacey expanded
			steps = [0 -0.4859 0.3833;0 -0.2741 0.5638;0 -0.0435 0.7060;0 0.1900 0.8000;0 0.4106 0.8395;0 0.6031 0.8218;0 0.7546 0.7481;0 0.8547 0.6234; 0 0.8965 0.4563; 0 0.8772 0.2580;0 0.7981 0.0422;0 0.6647 -0.1766;0 0.9605 0.9522;0 0.6872 -0.5420;0 0.0633 0.2667;0 0.1267 0.5333];
	end;
	for g=1:size(steps,1),
		RGB_plus(:,end+1) = 0.5+0.5*[steps(g,1) -steps(g,2) steps(g,3)]';
		RGB_minus(:,end+1) = 0.5+0.5*[steps(g,1) steps(g,2) -steps(g,3)]';
	end;
end;

ACT_PLUS = CONEMON * RGB_plus; ACT_MINUS = CONEMON * RGB_minus;
ConeCont = (ACT_PLUS-ACT_MINUS)./(ACT_PLUS+ACT_MINUS);

Sc = ConeCont(1,:); Lc = ConeCont(2,:); Rc = ConeCont(3,:);

