function nlm = landmark_undraw(lm)

for i=1:length(lm.data.handle), try, delete(lm.data.handle(i)); end; end;

disp(['undrawing mark ' lm.name '.']);

lm.data.handle = [];

nlm = lm;
