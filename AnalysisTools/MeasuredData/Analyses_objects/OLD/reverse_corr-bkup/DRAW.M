function draw(rc)

%  Part of the NeuralAnalysis package
%
%  DRAW(REVERSE_CORROBJ)
%
%  Draws the output to the location in the REVERSE_CORR object REVERSE_CORROBJ.
%
%  See also:  ANALYSIS_GENERIC/DRAW

w = location(rc);
if ~isempty(w),
  % first delete raster
  ra = [];
  l = findobj(w.figure,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(rc)),
  for i=1:length(l),
     ud = get(l,'userdata'),
     if isa(ud,'cell')&strcmp(ud{1},'revaxes'),
         l=l(i);
         if length(ud)>1,ra=ud{2};end;
         break;
     end;
  end;
  ra,
  if ~isempty(ra),delete(ra); end;

  z = getgraphicshandles(rc);
  for i=1:length(z), delete(z(i)); end;
  figure(w.figure);

  p=getparameters(rc); in = rc.internal;

  [r1,r2,r3,r4]=getdrawrects(rc);

  a = axes('units',w.units,'position',r3,'tag','analysis_generic',...
	'uicontextmenu',contextmenu(rc),'userdata','revaxes');
  rc_im = getrc(rc);
  l = size(rc_im);
  im = uint8(reshape(rc_im,[l(3) l(4) 3]));
  I = getinputs(rc); ps = getparameters(getstim(rc)); r = ps.rect;
  IM=image([r(1) r(3)],[r(2) r(4)],im,'uicontextmenu',contextmenu(rc));
  set(gca,'tag','analysis_generic','userdata',{'revaxes'}); % fix for matlab bug
  drawselectedbin(rc);
  p = getparameters(rc);
  colormap(gray(256));
  axis([p.pseudoscreen(1) p.pseudoscreen(3) ...
		p.pseudoscreen(2) p.pseudoscreen(4)]);
  axis equal;

  drawrast(rc);  % these all check to see if they should draw themselves
  drawshowdata(rc);
  draw1drev(rc);
  

  switch p.clickbehav,
      case 0,
	disp('setting button down');
	zoom off;
	set(IM,'ButtonDownFcn',bds);
      case 1,
	zoom on;
        set(IM,'ButtonDownFcn',bds);
      case 2,
	zoom on;
  end;
end;

function str = bds

str = ['uuuuuud.pos=get(gca,''position'');uuuuuud.units=get(gca,''units'');'...
       'uuuuuud.ud=get(gcf,''userdata'');uuuuuud.f=0;uuuuuud.i=0;' ...
       'for uuuuuudi=1:length(uuuuuud.ud),' ...
         'if isinwhere(uuuuuud.pos,uuuuuud.units,location(uuuuuud.ud{uuuuuudi})),' ...
           'uuuuuud.f=uuuuuudi;break;end;' ...
       'end;'...
       'if uuuuuud.f>0,'...
           'uuuuuud.ud{uuuuuud.f}=buttondwnfcn(uuuuuud.ud{uuuuuud.f});'...
           'set(gcf,''userdata'',uuuuuud.ud);'...
       'end; '...
       'clear uuuuuud;'];
