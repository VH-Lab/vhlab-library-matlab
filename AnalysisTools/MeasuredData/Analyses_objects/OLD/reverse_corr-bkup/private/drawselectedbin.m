function drawselectedbin(rc)

in = rc.internal;
w = location(rc);

if in.selectedbin>0&~isempty(w), 
   p=getparameters(getstim(rc)); r=p.rect;pixSize=p.pixSize;
   width  = r(3) - r(1); height = r(4) - r(2);
   if (pixSize(1)>=1), X = pixSize(1); else, X = (width*pixSize(1)); end;
   if (pixSize(2)>=1), Y = pixSize(2); else, Y = (height*pixSize(2)); end;
   bx = r(1):X:r(3); by=r(2):Y:r(4); YY=height/Y;
   x=fix((in.selectedbin-1)/YY)+1; y=mod(in.selectedbin-1,YY)+1;

   l = findobj(w.figure,'tag','analysis_generic',...
        'uicontextmenu',contextmenu(rc)), % should be one
   for i=1:length(l),
     ud = get(l,'userdata');
     if isa(ud,'cell')&strcmp(ud{1},'revaxes'), l = l(i); break; end;
   end;
   if ishandle(l),
      h = findobj(l,'tag','selectedbin');
      if ishandle(h), delete(h); end;
      hold on;
      plot([bx(x) bx(x+1)-1 bx(x+1)-1 bx(x) bx(x)], ...
           [by(y) by(y) by(y+1)-1 by(y+1)-1 by(y)], 'y','tag','selectedbin');
   else, disp(['not handle']);
   end;
end;

