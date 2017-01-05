function convert_periodiccurve_2d(pc, p1, p2)

 % pc can be figure handle or periodic_curve

if ishandle(pc),
	ud = get(pc,'userdata');
	pc = ud{1};
end;

figure;

ax1 = subplot(2,2,1); 

ax2 = subplot(2,2,2);

co = getoutput(pc);
inp = getinputs(pc);

xy = [];

for i=1:numStims(inp.st.stimscript),
        p = getparameters(get(inp.st.stimscript,i));
	if isfield(p,p1) & isfield(p,p2),
	        xy(i,[1 2]) = [getfield(p,p1) getfield(p,p2)];
	else,
		xy(i,[1 2]) = [NaN NaN];
	end;
end;

unq = unique(xy(:,2));

unq = unq(find(~isnan(unq)));

cols = repmat(linspace(0.8,0,length(unq))',1,3);

for i=1:length(unq),
	inds = find(xy(:,2)==unq(i));

	axes(ax1);
	hold on;
	h = myerrorbar(xy(inds,1),co.f0curve{1}(2,inds),co.f0curve{1}(4,inds),co.f0curve{1}(4,inds));
	set(h,'color',cols(i,:));
	title(['F0 at different ' p2]);
	xlabel(p1);

	axes(ax2);
	hold on;
	h = myerrorbar(xy(inds,1),co.f1curve{1}(2,inds),co.f1curve{1}(4,inds),co.f1curve{1}(4,inds));
	set(h,'color',cols(i,:));
	title(['F1 at different ' p2]);
	xlabel(p1);

end;


