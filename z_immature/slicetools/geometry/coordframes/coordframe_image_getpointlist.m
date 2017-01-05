function p = coordframe_image_getpointlist(cf, numpts)

myax = gca;

if nargin>1, mynumpts = numpts; else, mynumpts = Inf; end;


method = cf.data.parameters.GetPointMethod;

if strcmp(upper(method),'ASK'),
	meths = {'Manually','Graphically'};
	[s,v]=listdlg('PromptString','Select GetPointMethod:','SelectionMode','single','ListString',...
		{'Manually','Graphically'});
	if v==0, p = []; return; else, method = meths{s}; end;
end;

switch(upper(method)),
	case 'GRAPHICALLY',
		try,
			axes(get(cf.data.handle,'parent'));
		catch,
			error(['Could not find image handle associated with coordframe ' cf.name '.']);
		end;
		p = [];
		h = [];
		[xn,yn] = ginput(1);
		while ~isempty(xn)&size(p,1)<mynumpts,
			p = [p; xn yn ];
			if ishandle(h), delete(h); end;
			hold on;
			h = plot(p(:,1),p(:,2),'bo-');
			[xn,yn]=ginput(1);
		end;
		if ishandle(h); delete(h); end;
	case 'MANUALLY',
		prompt = {'Points list:'};
		defaultanswer = {'[0 0; 1 1;]'};
		answer = inputdlg(prompt,'Enter point:',1,defaultanswer);
		if isempty(answer), p = []; else, p = str2num(answer{1}); end;
	end;

axes(myax);
