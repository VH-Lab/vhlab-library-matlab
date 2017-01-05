function [newcell,assoc]=tpposanalysis(ds,cell,cellname,display)

%  TPPOSANALYSIS
%
%  [NEWSCELL,ASSOC]=TPPOSANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the position tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.  Fits are always
%  recalculated regardless of whether responses are recomputed.
%  
%  Measures gathered from the OT Test (associate name in quotes):
%
%  'POS X Pref'                     |   position w/ max firing
%  'POS X Fit Pref'                 |   position w/ max firing according to fit
%  'POS X Max response'             |   Max response during drifting gratings
%  'POS X Tuning width'             |   Tuning width (half width at half height)
%  'POS X varies'                   |   0/1 does POS vary w/ p<0.05
%  'POS X varies p'                 |   Does POS vary P value (anova)
%  'POS X visual response'          |   0/1 does POS vary across blank w/ p<0.05
%  'POS X visual response p'        |   Does POS vary across blank P value (anova)
%  'POS X Fit'                      |   Fit parameters (Rsp Rp Op sigm)
%  'POS Y Pref'                     |   position w/ max firing
%  'POS Y Fit Pref'                 |   position w/ max firing according to fit
%  'POS Y Max response'             |   Max response during drifting gratings
%  'POS Y Tuning width'             |   Tuning width (half width at half height)
%  'POS Y varies'                   |   0/1 does POS vary w/ p<0.05
%  'POS Y varies p'                 |   Does POS vary P value (anova)
%  'POS Y visual response'          |   0/1 does POS vary across blank w/ p<0.05
%  'POS Y visual response p'        |   Does POS vary across blank P value (anova)
%  'POS Y Fit'                      |   Fit parameters (Rsp Rp Op sigm)
%  The following variables will be equal to the X or Y values, whichever is
%  present.  If both are present, then these values will be equal to Y values.
%  'POS Max response'             |   Max response during drifting gratings
%  'POS Response curve'           |   Max response during drifting gratings
%  'POS Pref'                     |   position w/ max firing
%  'POS Fit Pref'                 |   position w/ max firing according to fit
%  'POS Tuning width'             |   Tuning width (half width at half height)
%  'POS varies'                   |   0/1 does POS vary w/ p<0.05
%  'POS varies p'                 |   Does POS vary P value (anova)
%  'POS visual response'          |   0/1 does POS vary across blank w/ p<0.05
%  'POS visual response p'        |   Does POS vary across blank P value (anova)
%  'POS Fit'                      |   Fit parameters (Rsp Rp Op sigm)
%
%  A list of associate types that TPPOSANALYSIS computes is returned if
%  the function is called with no arguments.

  % could add:
  %  'POS Spontaneous rate'         |   Spontaneous rate and std dev.
if nargin==0,
	stringlist= {'Response curve','Max Response','Pref','Fit Pref','Tuning width',...
			'Fit Params','Fit','varies','varies p','visual response',...
			'visual response p'};
	strs = {'X ','Y ',''};
	newcell = {};
	for i=1:length(strs),
		for j=1:length(stringlist),
			newcell{end+1} = ['POS ' strs{i} stringlist{j} ];
		end;
	end;
	return;
end;

newcell = cell;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

assoclist = tpposanalysis;

for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

posrespx = findassociate(newcell,'Best X pos resp','',[]);
posrespy = findassociate(newcell,'Best Y pos resp','',[]);
posxtest = findassociate(newcell,'Best X pos test','',[]);
posytest = findassociate(newcell,'Best Y pos test','',[]);

postest = {}; posresp = {}; assocst = {};
if ~isempty(posxtest)&~isempty(posrespx), postest{end+1} = posxtest; posresp{end+1}=posrespx; assocst{end+1}='X '; end;
if ~isempty(posytest)&~isempty(posrespy), postest{end+1} = posytest; posresp{end+1}=posrespy; assocst{end+1}='Y '; end;

for j=1:length(postest),
  
  g=load([getpathname(ds) postest{j}(end).data filesep 'stims.mat'],'saveScript','MTI2','-mat');
  s=stimscripttimestruct(g.saveScript,g.MTI2);
  
  % now loop through list and do fits
  resp = posresp{j}.data.curve;

  maxresp = []; 
  fdtpref = []; 
  tuningwidth = [];

  if numStims(s.stimscript)>size(resp,2)+1, o=3; else, o=1; end; % might have passed adapting stim
  ini = 1;
  for I=o:numStims(s.stimscript),
     if ~isfield(getparameters(get(s.stimscript,I)),'isblank'),
       myrect = getfield(getparameters(get(s.stimscript,I)),'rect');
       if strcmp(assocst{j},'X '),
           resp(1,ini) = mean(myrect([1 3]));
       else, resp(1,ini) = mean(myrect([2 4]));
       end;
       ini = ini + 1;
    end;
  end;
  angles = resp(1,:);

  [maxresp,if0]=max(resp(2,:)); 
  pospref = [resp(1,if0)];

  groupmem = [];
  vals = [];
  for i=1:length(posresp{j}.data.ind),
	vals = cat(1,vals,posresp{j}.data.ind{i});
	groupmem = cat(1,groupmem,i*ones(size(posresp{j}.data.ind{i})));
  end;
  pos_varies_p = anova1(vals,groupmem,'off');
  if isfield(posresp{j}.data,'blankresp'),
 	vals = cat(1,vals,posresp{j}.data.blankind);
	groupmem = cat(1,groupmem,(length(posresp{j}.data.ind)+1)*ones(size(posresp{j}.data.blankind)));
  	pos_vis_p = anova1(vals,groupmem,'off');
  else, pos_vis_p = pos_varies_p;
  end;

  tuneangles = angles; tuneresps = resp(2,:); tuneerr = resp(4,:);
  da = diff(sort(angles)); da = da(1);  % assume even steps

  if(1)  % fit with gaussfit function
	[Rsp,Rp,Ot,sigm,fitcurve,er] = gaussfit(angles,0,maxresp,pospref,90,'widthint',[da/2 180],...
		'data',tuneresps);
						 
	if display&(pos_vis_p<2)
	  figure;
	  errorbar(tuneangles,tuneresps,tuneerr,'o'); 
	  hold on
	  plot(min(tuneangles):max(tuneangles),fitcurve,'r');
	  xlabel('Position (pixels)')
	  ylabel('\Delta F/F');
          title(cellname,'interp','none');
	end % display
  end  % function fitting

  for zz=1:2,
  if zz==1, str = assocst{j}; else, str = ''; end;
  assoc(end+1)=myassoc(['POS ' str 'Response curve'],resp);
  assoc(end+1)=myassoc(['POS ' str 'Max Response'],maxresp);
  assoc(end+1)=myassoc(['POS ' str 'Fit Pref'],Ot);
  assoc(end+1)=myassoc(['POS ' str 'Pref'],pospref);
  assoc(end+1)=myassoc(['POS ' str 'Tuning width'],sigm*sqrt(log(4)));
  assoc(end+1)=myassoc(['POS ' str 'Fit Params'],[Rsp Rp Ot sigm]);
  assoc(end+1)=myassoc(['POS ' str 'Fit'],[min(tuneangles):max(tuneangles);fitcurve]);
  assoc(end+1)=myassoc(['POS ' str 'varies'],pos_varies_p<0.05);
  assoc(end+1)=myassoc(['POS ' str 'varies p'],pos_varies_p);
  if exist('pos_vis_p')==1,
	  assoc(end+1)=myassoc(['POS ' str 'visual response'],pos_vis_p<0.05);
	  assoc(end+1)=myassoc(['POS ' str 'visual response p'],pos_vis_p);
  end;
  end; % for zz

end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

