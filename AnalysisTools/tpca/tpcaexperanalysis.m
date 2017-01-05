
global tpca_database
tpca_database = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/tpca_db';

NewStimGlobals

clear newcell;

db = load(tpca_database,'-mat');
dbfn = fieldnames(db);
%minipath = '/Users/vanhoosr/fitzpatrick/analysis/twophoton/';
for i=1:length(dbfn),
        newcell{i} = getfield(db,dbfn{i});
end;

