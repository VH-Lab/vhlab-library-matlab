function d = landmark_stimgrid_new(lmsname,type,name,show,datain)

eval(['global ' lmsname '; lms = ' lmsname ';']);

d = [];

askcf = 1;
askinputmode = 1;
askpt = 1;
asklabelmode = 1;

if isstruct(datain),
	if isfield(datain,'coordframename'),
		if ~isempty(intersect({lms.coordframeslist(:).name},...
			datain.coordframename)),
			askcf = 0;
		end;
	end;
	if isfield(datain,'point'),
		if ~isempty(datain.point),
			askpt = 0;
		end;
	end;
	if isfield(datain,'inputmode'),
		askinputmode = 0;
		if ~isfield(datain,'dimensions'),
			askinputmode = 1;
		end;
	end;
	if isfield(datain,'labelstart')&isfield(datain,'labelinc'),
		asklabelmode = 0;
	end;
end;

if askcf, 
	str = {lms.coordframeslist(:).name};
	[s,v]=listdlg('PromptString','Select a coordinate frame',...
		'SelectionMode','single','ListString',str);
	if v==0, return; end;
	datain.coordframename = str{s};
end;

if askinputmode,
	str = { 'Enter dX, dY, then describe 3 points on grid clockwise',
		'Enter dX, dY, M, N then describe top and bottom points',
		'Enter list of points',
		'Enter MxN (steps high x steps wide), then describe 3 points on grid clockwise'};
	[s,v]=listdlg('PromptString','Select a coordinate frame',...
		'SelectionMode','single','ListString',str);
	if v==0, return; end;
	datain.inputmode = s;
end;

switch datain.inputmode,
	case 1,
		prompt = {'dX','dY'}; tname = 'Enter step sizes:'; defaultanswer = {'1','1'};
		answer=inputdlg(prompt,tname,1,defaultanswer);
		if ~isempty(answer),
			datain.dX = str2num(answer{1}); datain.dY = str2num(answer{2});
		end;
	case 2,
		prompt = {'dX','dY','M','N'}; tname = 'Enter step sizes and M, N:';
		defaultanswer = {'1','1','1','1'};
		answer=inputdlg(prompt,tname,1,defaultanswer);
		if ~isempty(answer),
			datain.dX = str2num(answer{1}); datain.dY = str2num(answer{2});
			datain.M = str2num(answer{3}); datain.N = str2num(answer{4});
		end;
	case 3, % nothing to be done
	case 4, 
		prompt = {'M','N'}; tname = 'Enter step sizes and M, N:';
		defaultanswer = {'1','1'};
		answer=inputdlg(prompt,tname,1,defaultanswer);
		if ~isempty(answer),
			datain.M = str2num(answer{1}); datain.N = str2num(answer{2});
		end;
end;

if (datain.inputmode==1|datain.inputmode==4)&(~askpt),
	if size(datain.point,1)~=3, askpt = 1; end;
end;

if (datain.inputmode==2)&(~askpt),
	if size(datain.point,1)~=2, askpt = 1; end;
end;

if askpt,
	while askpt,
		[g,ind]=intersect({lms.coordframeslist(:).name},datain.coordframename);
		p=coordframe_command(lms.coordframeslist(ind),'getpointlist');
		if (datain.inputmode==1|datain.inputmode==4),
			if size(p,1)<3,
				errordlg('This selection mode requires 3 points on the grid clockwise');
				return;
			else, askpt = 0;
			end;
		elseif datain.inputmode==2,
			if size(p,1)<2,
				errordlg('This selection mode requires 2 points, corresponding to the top and bottom of the grid');
				return;
			else, askpt = 0;
			end;
		elseif datain.inputmode==3,
			askpt = 0;
		end;
	end;
else, p = datain.point;
end;

if asklabelmode,
        prompt={'Stimsite label start number:','Label increment:)'};
        defaultanswer = {'1','1'};
        answer = inputdlg(prompt,'Stimsite label parameters',1,defaultanswer);
        if isempty(answer), return; end;
        datain.labelstart= str2num(answer{1});
	datain.labelinc = str2num(answer{2});
end;

data = datain;
data.point = p;
data.handle = [];

 % now have to build the grid

switch data.inputmode,
	case 1, %  dX, dY, 3 points clockwise
		p = data.point;
		width = sqrt(sum((p(1,:) - p(2,:)).^2));
		height = sqrt(sum((p(2,:) - p(3,:)).^2));
		wg = -width/2:data.dX:width/2; hg = -height/2:data.dY:height/2;
		[locsX,locsY] = meshgrid(wg,hg);
		data.M = length(wg); data.N = length(hg);
		[glocsX,glocsY] = meshgrid(-width/2-data.dX/2:data.dX:width/2+data.dX/2,-height/2-data.dY/2:data.dY:height/2+data.dY/2);
		gridlocsX = [glocsX([1 end],:) glocsX(:,[1 end])']; gridlocsY = [glocsY([1 end],:) glocsY(:,[1 end])'];
		gridlocs = [gridlocsX(:) gridlocsY(:)];
		if isempty(locsX), return; end;
		ctr = mean(p(1:2,:)) + 0.5*(p(3,:)-p(2,:));
		heightaxis = (p(3,:)-p(2,:));
		ang = pi/2-atan2(heightaxis(2),heightaxis(1));
		data.pts = [locsX(:) locsY(:)]*rot2d(ang)+repmat(ctr,prod(size(locsX)),1);
		data.gridlocs = gridlocs*rot2d(ang)+repmat(ctr,size(gridlocs,1),1);
	case 2, % dX, dY, M, N, and two points determine center
		p = data.point;
		ctr = mean(p(1:2,:));
		width = data.M*data.dX; if data.M==0, width = 0; end;
		height = data.N*data.dY;
		[locsX,locsY] = meshgrid(-width/2:data.dX:width/2,-height/2:data.dY:height/2);
		[glocsX,glocsY] = meshgrid(-width/2-data.dX/2:data.dX:width/2+data.dX/2,-height/2-data.dY/2:data.dY:height/2+data.dY/2);
		gridlocsX = [glocsX([1 end],:) glocsX(:,[1 end])']; gridlocsY = [glocsY([1 end],:) glocsY(:,[1 end])'];
		gridlocs = [gridlocsX(:) gridlocsY(:)];
		heightaxis = -p(1,:) + p(2,:);
		ang = pi/2-atan2(heightaxis(2),heightaxis(1));
		data.pts = [locsX(:) locsY(:)]*rot2d(ang)+repmat(ctr,prod(size(locsX)),1);
		data.gridlocs = gridlocs*rot2d(ang)+repmat(ctr,size(gridlocs,1),1);
	case 3, data.pts = data.point; % list of points
		data.gridlocs = data.pts;
		data.M = []; data.N = []; data.dX = []; data.dY = [];
	case 4, %  3 points clockwise
		width = sqrt(sum((p(1,:) - p(2,:)).^2));
		height = sqrt(sum((p(2,:) - p(3,:)).^2));
		[locsX,locsY] = meshgrid(linspace(-width/2, width/2, data.M),linspace(-height/2, height/2, data.N));
		if size(locsX,2)>2,
			data.dX = abs(diff(locsX(1,1:2)));
			wg = [locsX(1,:)-data.dX/2 locsX(1,end)+data.dX/2];
		else,
			data.dX = [];
			wg = 0;
		end;
		if size(locsY,1)>2,
			data.dY = abs(diff(locsY(1:2,1)));
			hg = [locsY(:,1)'-data.dY/2 locsY(end,1)'+data.dY/2];
		else,
			data.dY = [];
			hg = 0;
		end;
		[glocsX,glocsY] = meshgrid(wg,hg);
		gridlocsX = [glocsX([1 end],:) glocsX(:,[1 end])']; gridlocsY = [glocsY([1 end],:) glocsY(:,[1 end])'];
		gridlocs = [gridlocsX(:) gridlocsY(:)];
		if isempty(locsX), return; end;
		ctr = mean(p(1:2,:)) + 0.5*(p(3,:)-p(2,:));
		heightaxis = (p(3,:)-p(2,:));
		ang = pi/2-atan2(heightaxis(2),heightaxis(1));
		data.pts = [locsX(:) locsY(:)]*rot2d(ang)+repmat(ctr,prod(size(locsX)),1);
		data.gridlocs = gridlocs*rot2d(ang)+repmat(ctr,size(gridlocs,1),1);
end;

data.labels = data.labelstart:data.labelinc:data.labelstart+(size(data.pts,1))*data.labelinc;


d = struct('lmsname',lmsname,'type',type,'name',name,'show',show,...
		'data',data);



