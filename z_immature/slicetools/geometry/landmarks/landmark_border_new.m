function d = landmark_border_new(lmsname,type,name,show,datain)

eval(['global ' lmsname '; lms = ' lmsname ';']);

askcf = 1; askpt = 1;

if isstruct(datain),
	if isfield(datain,'coordframename'),
		if ~isempty(intersect({lms.coordframeslist(:).name},...
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
	str = {lms.coordframeslist(:).name};
	[s,v]=listdlg('PromptString','Select a coordinate frame',...
		'SelectionMode','single','ListString',str);
	if v==0, d = []; return; end;
	datain.coordframename = str{s};
end;

if askpt,
	[g,ind]=intersect({lms.coordframeslist(:).name},datain.coordframename);
	p=coordframe_command(lms.coordframeslist(ind),'getpointlist');
else, p = datain.point;
end;

data = datain;
data.point = p;
data.handle = [];

d = struct('lmsname',lmsname,'type',type,'name',name,'show',show,...
                'data',data);


d = struct('lmsname',lmsname,'type',type,'name',name,'show',show,...
		'data',data);



