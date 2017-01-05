function [newcell,assoc]=tpsfanalysis(ds,cell,cellname,display)

%  TPSFANALYSIS - Analyze two-photon spatial frequency responses
%
%  [NEWSCELL,ASSOC]=TPSFANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes spatial frequency tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.
%  
%
%  A list of associate types that TPSFANALYSIS computes is returned if
%  the function is called with no arguments.

[allstimids,begStrs,plotcolors,longnames] = FitzColorID;

if nargin==0,
	newcell = sfanalysis_compute;
	for i=1:length(newcell),
		for k=1:length(begStrs),
			newcell{i} = ['TP ' begStrs{k} ' ' newcell{i}];
		end;
	end;
	return;
end;

newcell = cell;

% remove any previous values we returned
assoclist = tpsfanalysis;
for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
end;

sftest = findassociate(newcell,'SF test','','');
sfresp = findassociate(newcell,'SF resp','','');
assoc = struct('type','','owner','','data','','desc',''); assoc = assoc([]);

if ~isempty(sftest)&~isempty(sfresp),

	stimid = [];
	if strcmp(class(sftest),'char'),
		if ~strcmp(bottestname, sftest.data), % make sure we didn't already get it
			g=load([getpathname(ds) stest.data filesep 'stims.mat'],'saveScript','MTI2','-mat');
			s=stimscripttimestruct(g.saveScript,g.MTI2);
			stims = cat(2,stims,s.stimscript); resps = cat(2,resps,sfresp.data);
			dirnames = cat(2,dirnames,sfresp.data);
			p = getparameters(get(s.stimscript,1));
			stimid(end+1) = FitzColorID(p.chromhigh,p.chromlow,10);
		end;
	else,
		for j=1:length(sftest.data),
			if ~strcmp(bottestname, sftest.data{j}), % make sure we didn't already get it
				g=load([getpathname(ds) sftest.data{j} filesep 'stims.mat'],'saveScript','MTI2','-mat');
				s=stimscripttimestruct(g.saveScript,g.MTI2);
				stims = cat(2,stims,s.stimscript); resps = cat(2,resps,sfresp.data{j});
				dirnames = cat(2,dirnames,sftest.data{j});
				p = getparameters(get(s.stimscript,1));
				stimid(end+1) = FitzColorID(p.chromhigh,p.chromlow,10);
			end;
		end;
	end;
	% replace curve(1,:) w/ SFs if it is not already like it

	for k = 1 : max(stimid),
		bestR = -Inf; bestRi = 0;
		poten = find(stimid==k);
		for i=1:length(poten),
			mx=max(resps{poten(i)}.curve(2,:));
			if bestR<mx, bestR = mx; bestRi = poten(i); end;
		end;
		if bestRi~=0,
			resp = resps{bestRi};
			myinds = [];
			if eqlen(resp.curve(1,:),1:numStims(s.stimscript)),
				for i=1:numStims(stims{bestRi}.stimscript),
					if ~isfield(getparameters(get(stims{bestRi}.stimscript,i)),'isblank'),
						myinds(end+1) = i;
						resp.curve(1,i) = getfield(getparameters(get(stims{bestRi}.stimscript,i)),'sFrequency');
					end;
				end;
			else, myinds = 1:length(resp.curve(1,:));
			end;
			resp.curve = resp.curve(:,myinds);
			resp.ind = resp.ind(myinds);
			resp.indf = resp.indf(myinds);
			if isfield(resp,'blankresp'),
				resp.spont = resp.blankresp; resp.spontind = resp.blankind;
			else,
				resp.spont = [ 0 0 0]; resp.spontind = [0]; % no spontaneous values for two-photon
			end;
			
			newassocs = sfanalysis_compute(resp);
			
			for j=1:length(newassocs),
				assocs(end+1) = newassocs(j);
				assocs(end).name = ['TP ' begStrs{k} ' ' assocs(end).name];
			end;
		end;
	end;
	
	for j=1:length(assocs), newcell = associate(newcell,assocs(j)); end;	

	if display,
		figure;
		recoverytpposfit = findassociate(newcell,'Recovery POS Fit','','');
		recoverytpposresp = findassociate(newcell,'Recovery POS Response curve','','');
		recoveryresp = recoverytpposresp.data;
		errorbar(recoveryresp(1,:),recoveryresp(2,:),recoveryresp(4,:),'ro'); 
		hold on
		if Ymode,
			oldfit = findassociate(newcell,'POS Y Fit','','');
			oldresp = findassociate(newcell,'POS Y Response curve','','');
		else,
			oldfit = findassociate(newcell,'POS X Fit','','');
			oldresp = findassociate(newcell,'POS X Response curve','','');
		end;
		oldresp = oldresp.data;
		errorbar(oldresp(1,:),oldresp(2,:),oldresp(4,:),'bs'); 
		plot(oldfit.data(1,:),oldfit.data(2,:),'b');
		plot(recoverytpposfit.data(1,:),recoverytpposfit.data(2,:),'r');
		xlabel('Position (pixels)')
		ylabel('\Delta F/F');
		title(cellname,'interp','none');
	end % display
end;

end; % for i=1:2
