function [impolar,immag,or_angs,or_mag] = intrinsicplotorientationpolar(dirname);

[pathstr,name] = fileparts(dirname);

or = load([fixpath(dirname) 'orientation_map_data.mat']);
or = or.or;

polartag = ['Orientation ' fixpath(pathstr) name ' polar'];
magtag = ['Orientation ' fixpath(pathstr) name ' mag'];

g1 = findobj(0,'tag',polartag);
g2 = findobj(0,'tag',magtag);


 % make some calculations

ctab = fitzlabclut(256);

or_angs = rescale(mod(angle(or),2*pi),[0 2*pi],[1 256]);

or_mag = abs(or);

 % first plot polar

if isempty(g1),
	g1 = figure('tag',polartag);
else,
	figure(g1); clf;
end;

colormap(ctab);
impolar = image(or_angs);
set(g1,'name','Orientation angles','NumberTitle','off'); axis equal;

 % now plot mag map

if isempty(g2),
	g2 = figure('tag',magtag);
else,
	figure(g2); clf;
end;

immag = imagedisplay(or_mag,'fig',g2);
set(g2,'name','Orientation magnitude dR/R','NumberTitle','off'); axis equal;
