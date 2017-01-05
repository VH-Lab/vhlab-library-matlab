function assoc = daceyrevcorranalysis_compute(respstruct)

if nargin==0, assoc = colordaceyexpandedanalysis_compute; return; end;

newrespstruct = respstruct;

newrespstruct.curve = [];
newrespstruct.ind = {};

for i=1:16,
    inds = 12*(i-1)+(1:6);
    newrespstruct.ind{i} = cat(1,respstruct.ind{inds});
    newrespstruct.curve(1:4,i) = [i ; nanmean(newrespstruct.ind{i}) ; ...
        nanstd(newrespstruct.ind{i}); nanstderr(newrespstruct.ind{i})];
end;

assoc = colordaceyexpandedanalysis_compute(newrespstruct);

inds = [];
asclist = {'CEDE visual response','CEDE visual response p','CEDE varies','CEDE varies p'};
for i=1:length(assoc),
    for j=1:length(asclist),
        if strcmp(assoc(i).type,asclist{j}), inds(end+1) = i; end;
    end;
end;
inds = setdiff(1:length(assoc),inds);
assoc = assoc(inds);

[CED_varies_p,CED_visresp_p] = neural_response_significance(respstruct);

assoc(end+1)=myassoc('CEDE varies',CED_varies_p<0.05);
assoc(end+1)=myassoc('CEDE varies p',CED_varies_p);
if exist('CED_visresp_p')==1,
	assoc(end+1)=myassoc('CEDE visual response',CED_visresp_p<0.05);
	assoc(end+1)=myassoc('CEDE visual response p',CED_visresp_p);
end;

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');
