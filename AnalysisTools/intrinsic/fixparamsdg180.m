function Pn = fixparamsdg180(P,wrap)

Pn = P;


if P(5)>P(2),  % swap P(2), P(5), advance angle 180 degrees
	Pn(2) = P(5); Pn(5) = P(2); Pn(3) = mod(P(3)+180,wrap);
else, 
	Pn(3) = mod(Pn(3),wrap);
end;
