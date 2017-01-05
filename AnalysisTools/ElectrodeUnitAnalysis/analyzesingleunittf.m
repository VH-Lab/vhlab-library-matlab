function [newcell,outstr,assoc,pc]=analyzesingleunittf(cksds,cell,cellname,display)

%  ANALYZESINGLEUNITTF
%
%  [NEWSCELL,OUTSTR,ASSOC,pc]=ANALYZESINGLEUNITTF(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the temporal frequency test.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a SPIKEDATA object, CELLNAME is a string
%  containing the name of the cell, and DISPLAY is 0/1 depending upon
%  whether or not output should be displayed graphically.
%
%  Measures gathered from the TF test (associate name in quotes):
%  'TF Response Curve F0'           |   F0 response
%  'TF Response Curve F1'           |   F1 response
%  'TF Pref'                        |   TF w/ max firing
%  'TF Low'                         |   low TF with half of max response 
%  'TF High'                        |   high TF with half of max response 
%  'TF Max drifting grating firing' |   Max firing during drifting gratings
%                                   |      (at optimal TF, SF, angle)
%

  %  written by SDV, JAFH

if nargin==0,
	newcell = {'TF Response Curve F0','TF Response Curve F1',...
		'TF Max drifting grating firing',...
		'TF Pref','TF Low','TF High','TF F1/F0'};
	return;
end;

newcell = cell;

assoclist = analyzesingleunittf;

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

f0curve = []; maxgrating = []; tfpref = []; pc = [];

tftest = findassociate(newcell,'TF test','',[]);
if ~isempty(tftest),
  s=getstimscripttimestruct(cksds,tftest(end).data);
  if ~isempty(s),
    inp.paramnames = {'tFrequency'};
    inp.title=['Temporal frequency ' cellname];
    inp.spikes = newcell;
    inp.st = s;
    pc = periodic_curve(inp,'default',where);
    p = getparameters(pc);
    p.graphParams(4).whattoplot = 6;
    pc = setparameters(pc,p);
    co = getoutput(pc);
    
    f0curve = co.f0curve{1}(1:4,:);
    f1curve = co.f1curve{1}(1:4,:);
    [mf0,if0]=max(f0curve(2,:)); 
    [mf1,if1]=max(f1curve(2,:)); 
    maxfiring = [mf0 mf1];
    f1f0=mf1/mf0;
    
    
    [lowf0, maxf0, highf0] = compute_halfwidth(f0curve(1,:),f0curve(2,:));
    [lowf1, maxf1, highf1] = compute_halfwidth(f1curve(1,:),f1curve(2,:));
    
    assoc(end+1)=struct('type','TF Response Curve F0','owner','',...
			'data',f0curve,'desc','TF Response Curve F1');
    assoc(end+1)=struct('type','TF Response Curve F1','owner','',...
			'data',f1curve,'desc','TF Response Curve F1');
    assoc(end+1)=struct('type','TF Max drifting grating firing','owner','',...
			'data',maxfiring,'desc',...
			'Max firing to a drifting grating [F0 F1]');
    assoc(end+1)=struct('type','TF Pref','owner','',...
			'data',[maxf0 maxf1],'desc',...
			'Temporal frequency preference [F0 F1]');
    assoc(end+1)=struct('type','TF Low','owner','',...
			'data',[lowf0 lowf1],'desc',...
			'Temporal frequency low half response point [F0 F1]');
    assoc(end+1)=struct('type','TF High','owner','','data',[highf0 highf1],...
			'desc',...
			'Temporal frequency high half response point [F0 F1]');
    assoc(end+1)=struct('type','TF F1/F0','owner','','data',f1f0,...
			'desc','TF F1/F0');
    

  end;
end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used
