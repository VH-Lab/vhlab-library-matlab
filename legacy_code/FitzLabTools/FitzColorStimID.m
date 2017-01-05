function [id,str,plotcolor,longname] = FitzColorStimID(stim,tol)

% FitzColorStimID - Gives known color code for stim
%
%  [ID,STR,PLOTCOLOR,LONGNAME] = FitzColorStimID(STIM,TOL)
%
%  Same as FitzColorID, but takes a NewStim object as input.

p = getparameters(stim);

if isa(stim,'periodicstim'),
	col1 = p.chromhigh; col2 = p.chromlow;
else, % assuming achromatic
	warning(['Assign color ''Ach'' to non-periodicstim by default.']);
	id = 1;
	str = 'Ach';
	plotcolor = [255 255 255; 0 0 0];
	longname = 'Achromatic';
	return;
end;

[id,str,plotcolor,longname] = FitzColorID(col1,col2,tol);
