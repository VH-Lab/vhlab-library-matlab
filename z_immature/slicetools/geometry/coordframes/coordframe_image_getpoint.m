function p = coordframe_image_getpoint(cf)

myax = gca;


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
		[x,y]=ginput(1); 
		p = [ x y ];
	case 'MANUALLY',
		prompt = {'X position:','Y position'};
		defaultanswer = {'0','0'};
		answer = inputdlg(prompt,'Enter point:',1,defaultanswer);
		if isempty(answer), p = []; else, p = [eval(answer{1}) eval(answer{2})]; end;
	end;

axes(myax);
