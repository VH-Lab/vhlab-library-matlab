function [assoc, areabl,areawh,overlap, normpotoverlap, normareaoverlap, blackwhitefraction] = lineweight_compute(respstruct)

if nargin==0,
    assoc = {'black area','white area','raw overlap','normalized area overlap',...
        'normalized potential overlap','black white fraction',...
        'lineweight varies','lineweight varies p','lineweight visual response','lineweight visual response p',...
        'lineweight white response curve','lineweight black response curve','black white peak fraction'};
    return;
end;

[lw_varies_p,lw_vis_p] = neural_response_significance(respstruct);

l = size(respstruct.curve,2);

if isfield(respstruct,'blankresp'), bl = respstruct.blankresp(1); else, bl = 0; end;

locs = respstruct.curve(1,1:l/2);
locs = locs - mean(locs);
bar=mean(respstruct.curve(4, :));
whiteresps = rectify(respstruct.curve(2,1:l/2)-bl-bar);
blackresps = rectify(respstruct.curve(2,l/2+1:end)-bl-bar);
whiterespsnorm = rescale(whiteresps,[0 max(whiteresps)], [0 1]);
blackrespsnorm = rescale(blackresps,[0 max(blackresps)], [0 1]);
whitecurve(1,:) = locs; blackcurve(1,:) = locs;
whitecurve(2,:) = respstruct.curve(2,1:l/2)-bl;
blackcurve(2,:) = respstruct.curve(2,l/2+1:end)-bl;
whitecurve(3:4,:) = respstruct.curve(3:4,1:l/2);
blackcurve(3:4,:) = respstruct.curve(3:4,l/2+1:end);


deltaSp=abs(locs(2)-locs(1));

areabl=0;
areawh=0;
overlap = 0;
normoverlap=0;
nareabl=0;
nareawh=0;

for i=1:length(whiteresps),
   areabl=areabl+deltaSp*abs(blackresps(i));
   areawh=areawh+deltaSp*abs(whiteresps(i));
   nareabl=nareabl+deltaSp*abs(blackrespsnorm(i));
   nareawh=nareawh+deltaSp*abs(whiterespsnorm(i));
   if sign(whiteresps(i))==sign(blackresps(i))
    overlap=overlap+min(abs(whiteresps(i)), abs(blackresps(i)))*deltaSp; 
   end 
   normoverlap=normoverlap+min(abs(whiterespsnorm(i)), abs(blackrespsnorm(i)))*deltaSp;
end

normpotoverlap=overlap/min(areabl, areawh);
normareaoverlap=2*overlap/(areabl+areawh);
blackwhitefraction=areabl/(areabl+areawh);
normoverlap=2*normoverlap/(nareabl+nareawh);
blackwhitepeakfraction=max(blackresps)/(max(blackresps)+max(whiteresps));

assoc(1)=struct('type', 'black area', 'owner', 'Julie', 'data', areabl, 'desc', 'black area');
assoc(end+1)=struct('type', 'white area', 'owner', 'Julie', 'data', areawh, 'desc', 'white area');
assoc(end+1)=struct('type', 'raw overlap', 'owner', 'Julie', 'data', overlap, 'desc', 'raw overlap');
assoc(end+1)=struct('type', 'normalized area overlap', 'owner', 'Julie', 'data', normareaoverlap, 'desc', 'normalized area overlap');
assoc(end+1)=struct('type', 'normalized potential overlap', 'owner', 'Julie', 'data', normpotoverlap, 'desc', 'normalized potential overlap');
assoc(end+1)=struct('type', 'black white fraction', 'owner', 'Julie', 'data', blackwhitefraction, 'desc', 'black white fraction');
assoc(end+1)=struct('type','lineweight varies','owner','Julie','data',lw_varies_p<0.05,'desc','');
assoc(end+1)=struct('type','lineweight varies p','owner','Julie','data',lw_varies_p,'desc','');
assoc(end+1)=struct('type','lineweight visual response','owner','Julie','data',lw_vis_p<0.05,'desc','');
assoc(end+1)=struct('type','lineweight visual response p','owner','Julie','data',lw_vis_p,'desc','');
assoc(end+1)=struct('type','lineweight white response curve','owner','Julie','data',whitecurve,'desc','[deg;mean;stddev;stderr]');
assoc(end+1)=struct('type','lineweight black response curve','owner','Julie','data',blackcurve,'desc','[deg;mean;stddev;stderr]');
assoc(end+1)=struct('type','lineweight threshold', 'owner', 'Julie','data', bar, 'desc','');
assoc(end+1)=struct('type','normalized overlap', 'owner', 'Julie','data', normoverlap, 'desc','normalized overlap');
assoc(end+1)=struct('type', 'black white peak fraction', 'owner', 'Julie', 'data', blackwhitepeakfraction, 'desc', 'black white peak fraction');


