function d = landmark_alignpoint_new(lmsname,type,name,show,datain)

eval(['global ' lmsname '; lms = ' lmsname ';']);

askcf1 = 1; askpt1 = 1;
askcf2 = 1; askpt2 = 1;

if isstruct(datain),
	if isfield(datain,'coordframe1name'),
		if ~isempty(intersect({lms.coordframeslist(:).name},...
			datain.coordframe1name)),
			askcf1 = 0;
		end;
	end;
	if isfield('point1'),
		if ~isempty(datain.point1),
			askpt1 = 0;
		end;
	end;
	if isfield(datain,'coordframe2name'),
		if ~isempty(intersect({lms.coordframeslist(:).name},...
			datain.coordframe2name)),
			askcf2 = 0;
		end;
	end;
	if isfield('point2'),
		if ~isempty(datain.point2),
			askpt2 = 0;
		end;
	end;
end;

if askcf1, 
	str = {lms.coordframeslist(:).name};
	[s,v]=listdlg('PromptString','Select the initial coordinate frame',...
		'SelectionMode','single','ListString',str);
	if v==0, d = []; return; end;
	datain.coordframe1name = str{s};
end;
if askcf2, 
	str = {lms.coordframeslist(:).name};
	[s,v]=listdlg('PromptString','Select the alternate coordinate frame',...
		'SelectionMode','single','ListString',str);
	if v==0, d = []; return; end;
	datain.coordframe2name = str{s};
end;

if askpt1,
	[g,ind]=intersect({lms.coordframeslist(:).name},datain.coordframe1name);
	p1=coordframe_command(lms.coordframeslist(ind),'getpoint');
else, p1 = datain.point1;
end;
if askpt2,
	[g,ind]=intersect({lms.coordframeslist(:).name},datain.coordframe2name);
	p2=coordframe_command(lms.coordframeslist(ind),'getpoint');
else, p2 = datain.point2;
end;

data = datain;
data.point1 = p1; data.point2 = p2; data.handle = [];

d = struct('lmsname',lmsname,'type',type,'name',name,'show',show,...
		'data',data);

