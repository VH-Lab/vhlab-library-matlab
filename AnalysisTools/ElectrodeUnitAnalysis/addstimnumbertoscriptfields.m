function addstimnumbertoscriptfields(fullpathdirname)

copyfile([fullpathdirname filesep 'stims.mat'],[fullpathdirname filesep 'stimscopy.mat']);

g = load([fullpathdirname filesep 'stimscopy.mat']);

for i=1:numStims(g.saveScript),
    mystimclass = class(get(g.saveScript,i));
    mystimp = getparameters(get(g.saveScript,i));
    mystimp.stimnumber = i;
    if isfield(mystimp,'rect'),
        mystimp.length = diff(mystimp.rect([1 3]));
        mystimp.width = diff(mystimp.rect([2 4]));
    end;
    g.saveScript = set(g.saveScript,eval([mystimclass '(mystimp);']),i);
end;

saveScript = g.saveScript; start = g.start;  MTI2 = g.MTI2;

save([fullpathdirname filesep 'stims.mat'],'saveScript','MTI2','start','-mat');

