function d = landmark_point_new(lmsname,type,name,show,datain)

eval(['global ' lmsname '; lms = ' lmsname ';']);


askcf = 1; askpt = 1;

if isstruct(datain),
	if isfield(datain,'coordframename'),
		if isempty(lms.coordframeslist), askcf = 1;
		else, ~isempty(intersect({lms.coordframeslist(:).name},...
			datain.coordframename)),
			askcf = 0;
		end;
	end;
	if isfield('point'),
		if ~isempty(datain.point),
			askpt = 0;
		end;
	end;
end;

if askcf, 
	if ~isempty(lms.coordframeslist),
		str = {lms.coordframeslist(:).name};
		[s,v]=listdlg('PromptString','Select a coordinate frame',...
			'SelectionMode','single','ListString',str);
		if v==0, d = []; return; end;
		datain.coordframename = str{s};
	else, error(['No coordinate frames!']);
	end;
end;

if askpt,
	[g,ind]=intersect({lms.coordframeslist(:).name},datain.coordframename);
	p=coordframe_command(lms.coordframeslist(ind),'getpoint');
else, p = datain.point;
end;

data = datain;
data.point = p;
data.handle = [];

d = struct('lmsname',lmsname,'type',type,'name',name,'show',show,...
		'data',data);



