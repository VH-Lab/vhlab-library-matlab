function newrc = compute(rc)

%  Part of the NeuralAnalysis package
%
%  NEWRC = COMPUTE(RC)
%
%  Compute the reverse correlation, receptive field maximum, and receptive
%  field rectangle.  These are returned via a call to GETOUTPUT.
%
%  See also:  REVERSE_CORR, GETOUTPUT

 % fix for multiple cells

I = getinputs(rc); p = getparameters(rc); in = rc.internal; c = rc.computations;
if isempty(in.oldint)|(prod(in.oldint~=p.interval)),
   ind = 1;
   sts = 1:length(I.stimtime);
   while ~isempty(sts),
      i = sts(1);
      % find stims which are same
      subl = []; ft = []; 
      for j=sts,
         if I.stimtime(i).stim==I.stimtime(j).stim,
             sts = find(sts~=j);
             for k=1:length(I.stimtime(j).mti)
                ft = cat(1,ft,I.stimtime(j).mti{k}.frameTimes); % make cell list
	     end;
         end;
      end;
      [rc_raw{ind},bins{ind},norms{ind},thespikes{ind}]=...
              reverse_corr(I.stimtime(i).stim,ft,I.spikes,p.interval,1,1);
      % now compute average
      l=size(rc_raw{ind});
      rc_stavg{ind}=...
         sum(repmat(norms{ind},[1 1 l(3) l(4) 3]).*rc_raw{ind},2).*...
             repmat(sum(1./norms{ind},2),[1 1 l(3) l(4) 3]);
      ind = ind + 1;
    end;
    l=size(rc_raw{1});  ns = repmat(sum(norms{1},2),[1 1 l(3) l(4) 3]);
    rc_avg = rc_stavg{1}.*ns;
    for i=2:length(rc_stavg),
       nsn = repmat(sum(norms{i},2),[1 1 l(3) l(4) 3]);
       ns = ns + nsn;
       rc_avg = rc_avg + rc_stavg{i}.*nsn;
    end;
    rc_avg = rc_avg.*(1./ns);

   in.oldint = p.interval;
   
   r_c=struct('rc_avg',rc_avg,'rc_stavg',{rc_stavg},'rc_raw',{rc_raw},...
          'bins',{bins},'norms',{norms},'spikects',{thespikes});
else, r_c = rc.computations.reverse_corr;
end;

if in.selectedbin==0,
   st=getstim(rc);p2=getparameters(st);rect=p2.rect;pixSize=p2.pixSize;
   %size(r_c.rc_avg),size((max(max(max(max(max(r_c.rc_avg))))))),
   %size(max(r_c.rc_avg(1,1,:,:,1)),3),
   %[i,j]=find(r_c.rc_avg(1,1,:,:,1)==max(max(r_c.rc_avg(1,1,:,:,1))));
   %i,j,
   i=1;j=1; i=i(1);j=j(1); px=rect(1)-1+i; py=rect(2)-1+j;

   width  = rect(3) - rect(1); height = rect(4) - rect(2);
   if (pixSize(1)>=1), X = pixSize(1); else, X = (width*pixSize(1)); end;
   if (pixSize(2)>=1), Y = pixSize(2); else, Y = (height*pixSize(2)); end;
   x=fix((px-rect(1))/X); y = fix((py-rect(2))/Y); b=1+x*fix(Y/height)+y;
   %bx = rect(1):X:rect(3); by = rect(2):Y:rect(4);
   in.selectedbin = b;
   thecenter = [px py]; thecenterrect = [px-100 py-100 px+100 py+100];
else,thecenter=rc.computations.center;thecenterrect=rc.computations.center_rect;
end;
   
rc.internal = in;
rc.computations=struct('reverse_corr',r_c,...
     'center',thecenter,'center_rect',thecenterrect);
newrc = rc;
