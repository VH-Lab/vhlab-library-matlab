function [newcell,outstr,assoc,pc]=analyzesingleunitcolorexchange(cksds,cell,cellname,display)

%  ANALYZESINGLEUNITCOLOREXCHANGE
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=ANALYZESINGLEUNITCOLOREXCHANGE(DS,...
%         CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the Color Exchange test (associate name in quotes):
%  'CE Response Curve F0'           |   F0 response
%  'CE Response Curve F1'           |   F1 response
%  'CE Max'                         |   GGain w/ max firing [F0 F1]
%  'CE Max value'                   |   Max firing value [F0 F1]
%  'CE Min'                         |   GGain w/ min firing [F0 F1]
%  'CE Min value'                   |   Min firing value [F0 F1]
%  'CE Sig S'                       |   Is S input significant? [F0 F1]
%  'CE Sig S p'                     |   Is S input significant p value [F0 F1]
%  'CE Blank Response F0'           |   Blank stim response F0
%  'CE Blank Response F1'           |   Blank stim response F1
%

if nargin==0,
	newcell = {'CE Response Curve F0','CE Response Curve F1',...
		'CE Max','CE Min','CE Max value','CE Min value',...
		'CE Sig S','CE Sig S p','CE Blank Response F0','CE Blank Response F1'};
	return;
end;

newcell = cell;

assoclist = analyzesingleunitcolorexchange;

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

if display,
	where.figure=figure;
	where.rect=[0 0 1 1];
	where.units='normalized';
	orient(where.figure,'landscape');
else, where = []; end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

cetest = findassociate(newcell,'Color Exchange test','',[]);
if ~isempty(cetest),
  s=getstimscripttimestruct(cksds,cetest(end).data);
  if ~isempty(s),
    inp.paramnames = {'ggain'};
    inp.title=['Color exchange ' cellname];
    inp.spikes = newcell;
    inp.st = s;
    inp.blankid = numStims(s.stimscript); % assume blank is last stim
    
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    [mf0,if0]=max(f0curve(2,:)); [mf1,if1]=max(f1curve(2,:)); 
    maxfiring = [mf0 mf1];
    maxf0 = f0curve(1,if0); maxf1 = f1curve(1,if1);
    [mnf0,inf0]=min(f0curve(2,:)); [mnf1,inf1]=min(f1curve(2,:)); 
    minfiring = [mnf0 mnf1];
    minf0 = f0curve(1,inf0); minf1 = f1curve(1,inf1);
    
    [hsf0,psf0] = ttest2(co.f0vals{5},co.blank.f0vals{1},'right');
    [hsf1,psf1] = ttest2(co.f1vals{5},co.blank.f1vals{1},'right');

    assoc(end+1)=struct('type','CE Response Curve F0','owner','',...
			'data',f0curve,'desc','CE Response Curve F0');
    assoc(end+1)=struct('type','CE Response Curve F1','owner','',...
			'data',f1curve,'desc','CE Response Curve F1');
    assoc(end+1)=struct('type','CE Max value','owner','','data',maxfiring,'desc',...
			'Max firing [F0 F1]');
    assoc(end+1)=struct('type','CE Max','owner','','data',[maxf0 maxf1],'desc',...
			'CE ggain preference [F0 F1]');
    assoc(end+1)=struct('type','CE Min value','owner','','data',minfiring,'desc',...
			'Min firing [F0 F1]');
    assoc(end+1)=struct('type','CE Min','owner','','data',[minf0 minf1],'desc',...
			'CE ggain minimum [F0 F1]');
    assoc(end+1)=struct('type','CE Sig S p','owner','','data',[psf0 psf1],'desc',...
			'S input significant P value [F0 F1]');
    assoc(end+1)=struct('type','CE Sig S','owner','','data',[hsf0 hsf1],'desc',...
			'S input significant? (P<0.05) [F0 F1]');
    assoc(end+1)=struct('type','CE Blank Response F0','owner','','data',...
			co.blank.f0curve{1},...
			'desc', 'CE Blank Response F0 [F0 F1]');
    assoc(end+1)=struct('type','CE Blank Response F1','owner','','data',,...
			co.blank.f1curve{1},...
			'desc','CE Blank Response F1');
  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used
