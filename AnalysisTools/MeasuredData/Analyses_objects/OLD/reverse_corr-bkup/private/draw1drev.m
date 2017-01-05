function draw1drev(rc)

p = getparameters(rc);
pars = p.show1drevprs;
if p.show1drev,
  w = location(rc); in = rc.internal; I = getinputs(rc);
  [r1,r2,r3,r4]=getdrawrects(rc);

  l = findobj(w.figure,'tag','analysis_generic','uicontextmenu',...
      contextmenu(rc),'userdata','1drev');
  if ishandle(l), delete(l); end;
  a = axes('units',w.units,'position',r2,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(rc),'userdata','1drev');
  ps = getparameters(getstim(rc));  vals = ps.values;  % get colors
  if p.chanview==0, % use intensity, varies between 0 and 1 % add transform here
     vals = sqrt(sum(vals.*vals/(255*255),2))/norm([1 1 1]);
  else, vals = vals(:,p.chanview);
  end;
  [b,t] = getbins(rc); v = []; vt = [];% class(t{1}),
  cont = {};thet = {}; ts = {};
  for i=1:length(b),
    vl=vals(b{i}(:,in.selectedbin))';
    for j=1:length(t{i}),
       dt = mean(diff(t{i}.frameTimes));
       vtl=[t{i}.frameTimes t{i}.frameTimes(end)+dt];
       t0 = t{i}.frameTimes(1);
       [contin,theta]=interval2continuous(vtl,vl,pars(2));
       if pars(1)==1, contin = [0 abs(diff(contin)/pars(2))]; end;
       cont=cat(1,cont,{contin}); thet=cat(1,thet,{theta});
       thets = get_data(I.spikes{p.datatoview(1)},[vtl(1) vtl(end)]);
       ts = cat(1,ts,{thets});
    end;
  end; %size(thet),size(cont),size(ts),
  [avg,sd,tnew]=tsaveragemany(thet,cont,ts,pars(3),pars(4));
  plot(tnew,avg); if pars(5), hold on; plot(tnew,avg-sd,'r');plot(tnew,avg+sd,'r'); end;
  if pars(1)==0, if p.chanview==0,set(a,'ylim',[0 1]);else set(a,'ylim',[0 255]);end; end;
  set(a,'tag','analysis_generic','userdata','1drev');
end;
