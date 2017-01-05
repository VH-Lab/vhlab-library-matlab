function nrc = buttondwnfcn(rc)
pt = get(gca,'CurrentPoint'); pt = pt([1 3]);

% get current stim
I = getinputs(rc);
st = I.stimtime(1).stim;   % currently assume only 1 stimulus
p2 = getparameters(st); rect = p2.rect; pixSize = p2.pixSize;
if (pt(1)>=rect(1)&pt(1)<=rect(3))&(pt(2)>=rect(2)&pt(2)<=rect(4)),
 % compute grid

  width  = rect(3) - rect(1); height = rect(4) - rect(2);
  if (pixSize(1)>=1), X = pixSize(1); else, X = (width*pixSize(1)); end;
  if (pixSize(2)>=1), Y = pixSize(2); else, Y = (height*pixSize(2)); end;
  %i = 1:width; x = fix((i-1)/X)+1; i = 1:height; y = fix((i-1)/Y)+1;
  x = fix((pt(1)-rect(1))/X); y = fix((pt(2)-rect(2))/Y);
  bin=1+x*fix((height/Y))+y;
  in=rc.internal;
  in.selectedbin=bin;
  rc.internal=in;
  drawselectedbin(rc);
  drawshowdata(rc);
  drawrast(rc);
  draw1drev(rc);

end; % do nothing if point not in grid  
nrc = rc;
