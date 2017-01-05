function nlm = landmark_editcolorscheme(lm)

nlm = lm;

newscheme = landmarkcolorscheme(lm.colorscheme,1);

if ~isempty(newscheme),
	nlm.colorscheme = newscheme;
end;
