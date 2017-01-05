function draw(rc)

%  Part of the NeuralAnalysis package
%
%  DRAW(REVERSE_CORROBJ)
%
%  Draws the output to the location in the REVERSE_CORR object REVERSE_CORROBJ.
%
%  See also:  ANALYSIS_GENERIC/DRAW


 % What is plotted:
 % Draws 3 panels:  
 %  DRAWCUBE 
 %      Calls the private function DRAWCUBE
 %         This function plots
 %              c.reverse_corr.rc_avg(:,:,:,:,:)  
 %              this matrix seems to be (cell_number x stim_number) x time bin x Y x X x colors
 %         and also plots
 %              c.lags and c.crc in rectangle 4     
 %           

w = location(rc);
if ~isempty(w),
% for now, delete everything and start over
  z = getgraphicshandles(rc);
for i=1:length(z), delete(z(i)); end;
figure(w.figure);

p=getparameters(rc); in = rc.internal; I = getinputs(rc);

[r1,r2,r3,r4]=getdrawrects(rc);

% draw the cube in rect 1, r1

%disp(['drawtoview: ' mat2str(p.datatoview) '.']);
[rc_avg,xsteps,ysteps,cubeaxes,cubesurf1,cubesurf2,cubesurf3,...
	line1,line2]=drawcube(rc,r1);

% build the X/Y axes in position r3 and plot the selected X/Y plane 

a = axes('units',w.units,'position',r3,'tag','analysis_generic',...
	'uicontextmenu',contextmenu(rc),'userdata','revaxes');
xx = repmat(xsteps,length(ysteps),1); yy=repmat(ysteps,length(xsteps),1);
zz = zeros(length(xsteps),length(ysteps));
%size(xx),size(yy),size(zz),size(rc_avg),
% create and plot the surface
IM = surf(repmat(xsteps,length(ysteps),1)',repmat(ysteps,length(xsteps),1),...
             zeros(length(xsteps),length(ysteps)),rc_avg'); 
set(gca,'ydir','reverse','uicontextmenu',contextmenu(rc),...
	'tag','analysis_generic','userdata','revaxes');
axis equal;
axis([p.pseudoscreen(1) p.pseudoscreen(3) ...
	p.pseudoscreen(2) p.pseudoscreen(4)]);
offsets = p.interval(1):p.timeres:p.interval(2);
if length(offsets)==1, offsets= [p.interval(1) p.interval(2)]; end;
title([I.cellnames{p.datatoview(1)} ...
	' x stim over [' num2str(offsets(p.datatoview(2))) 's, ' ...
	num2str(offsets(p.datatoview(2)+1)) 's]'],'Interpreter','none');

drawselectedbin(rc,a);  % draw yellow line around selected bin in rectangle 3
drawcrc(rc,r4);         % draw the continuous reverse correlation for the currently selected bin
  
 % set the click behavior for the mouse
switch p.clickbehav,
	case 0,
		%disp('setting button down');
		zoom off;
		set(IM,'ButtonDownFcn',bds);
		set(cubesurf1,'ButtonDownFcn',bds); set(cubesurf2,'ButtonDownFcn',bds);
		set(cubesurf3,'ButtonDownFcn',bds);
		set(line1,'ButtonDownFcn',bds); set(line2,'ButtonDownFcn',bds);
	case 1,
		zoom on;
		set(IM,'ButtonDownFcn',bds);
		set(cubesurf1,'ButtonDownFcn',bds); set(cubesurf2,'ButtonDownFcn',bds);
		set(cubesurf3,'ButtonDownFcn',bds);
		set(line1,'ButtonDownFcn',bds); set(line2,'ButtonDownFcn',bds);
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
