function doplotcontrast(cells,cellnames)

  % prefix = 'e:\svanhooser\data\';
  % expernames={'2008-05-22','2008-05-30','2008-06-05','2008-06-18'};


if nargin==0,  % it is the buttondownfcn
	ud = get(gcf,'userdata');
	pt = get(gca,'CurrentPoint');
	pt = pt(1,[1 2]); % get 2D proj

	xaxlabel = get(get(gca,'xlabel'),'string'),
	switch xaxlabel,
		case 'RMG',
			K = 1;
		case 'C50',
			K = 2;
		case 'SI',
			K = 3;
	end;
	K,
	[i,v] = findclosest(sqrt(sum((repmat(pt,size(ud.pts{K},1),1)-ud.pts{K}).^2')'),0);
	if v<50,
	        i2 = i;
		i = ud.inds{K}(i);
		if ~isempty(ud.cellnames{i}),
			disp(['Closest cell is ' ud.cellnames{i} ' w/ value ' num2str(ud.pts{K}(i2,1)) '.']);
		else,
			disp(['Closest cell is # ' int2str(i) ' w/ value ' num2str(ud.pts{K}(i2,1)) '.']);
		end;
       		figure;
		ctcellplot(ud.cells{i},ud.cellnames{i},'SP F0 Ach',1);
	end;
	return;
end;

 % this is where the function really begins

figure;

[rmg,c50,si,depth,putativelayer,f1f0,cellnamelist, inds, sigcontrast] = readcontrasttuningfromcells(cells,cellnames);


good = find(sigcontrast<0.05),

pts{1} = [rmg(good); depth(good)/1000]';
pts{2} = [c50(good); depth(good)/1000]';
pts{3} = [si(good); depth(good)/1000]';


subplot(1,3,1);
hold off;
plot(rmg(good),depth(good)/1000,'ko');
hold on;
set(gca,'ydir','reverse');
xlabel('RMG');
ylabel('standardized depth depth');
hold on;
plot([0 6],[1.8 1.8],'b');
axis([0 6 -0.2 2.5]);
set(gca,'buttondownfcn','doplotcontrast');
box off;

subplot(1,3,2);
hold off;
plot(c50(good),depth(good)/1000,'ko');
hold on;
set(gca,'ydir','reverse');
xlabel('C50');
ylabel('standardized depth depth');
hold on;
plot([0 1],[1.8 1.8],'b');
axis([0 1 -0.2 2.5]);
set(gca,'buttondownfcn','doplotcontrast');
box off;
box off;


subplot(1,3,3);
hold off;
plot(si(good),depth(good)/1000,'ko');
hold on;
set(gca,'ydir','reverse');
xlabel('SI');
ylabel('standardized depth depth');
hold on;
plot([0 1],[1.8 1.8],'b');
axis([0 1 -0.2 2.5]);
set(gca,'buttondownfcn','doplotcontrast');
box off;
box off;


ud.pts=pts; ud.cells=cells;ud.cellnames=cellnames;ud.inds={inds(good), inds(good), inds(good)};
set(gcf,'userdata',ud,'buttondownfcn','doplotcontrast');


return;

subplot(1,3,1);
[x,y,s,inds{2}]=plotsimplecomplexori(cells,2);
pts{2} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.8, 0.2,'median',0);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
%ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1.5],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Orientation index'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;


subplot(1,3,3);
[x,y,s,inds{3}]=plotsimplecomplexori(cells,4);
global myvar
myvar.x = x; myvar.y = y; myvar.s = s;
pts{3} = [ x' y' ];
[Yn,Xn] = slidingwindowfunc(y, x, 0, 0.01, 1.8, 0.2,'median',0);
mn = mean(x);
hold on;
plot(Yn,Xn,'-','color',[0.8 0.8 0.8]*0,'linewidth',2);
plot([mn mn]*0+0.5,[-0.2 2],'k--','linewidth',1);
ch=get(gca,'children'); set(gca,'children',[ch(2:end);ch(1)]);
plot([0 1],[1.8 1.8],'b');
axis([0 1.5 -0.2 2.5]);
xlabel('Circular variance'); 
title([int2str(length(x)) ' cells in ' int2str(length(expernames)) ' tree shrews.']);
set(gca,'buttondownfcn','doplotsimplecomplexori3');
[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
ylocs = [2.0 2.133 2.2667 2.4]+0.01;
meads=[nanmedian(x(find(y==2.0+.01))) nanmedian(x(find(y==2.133+.01))) nanmedian(x(find(y==2.2667+.01))) nanmedian(x(find(y==2.4+.01)))]
for i=1:length(meads), plot([meads(i) meads(i)],ylocs(i)+[-0.133 0.133]/2,'k','linewidth',2); end;

ud.pts=pts; ud.cells=cells;ud.cellnames=cellnames;ud.inds=inds;
set(gcf,'userdata',ud,'buttondownfcn','doplotsimplecomplexori3');
