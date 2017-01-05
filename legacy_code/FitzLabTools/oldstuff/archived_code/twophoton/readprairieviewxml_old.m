function params = readprairieviewxml(filename)

%  READPRAIRIEVIEWXML - Read all values from Prairie config file
%
%   VALUES = READPRAIRIEVIEWXML(FILENAME)
%
%  Reads values from a Prairie Technologies config file.
%  Returns a struct with fieldnames equal to each parameter.
%  Differnet categories (e.g., 'Main') are included as
%  substructures.
%
%  With version 2.2 of the PrairieView software, parameter
%  files became large XML documents that contain a lot of
%  information.  Therefore, this function only retrieves
%  a subset of parameters from XML files.  They are
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%  This function does not read the old format (.pcf files).
%  Use READPRAIRIECONFIG to open either format.
% 
%  If you want to read values that are not returned by this function,
%  use getXMLNodeText.
%
%  See also:  READPRAIRIECONFIG, GETXMLNODETEXT

xDoc = xmlread(filename);

 % we want to extract

mySub = struct('type','{}','subs',{{1}});

params.Main.Dwell_time__us_ = subsref(getXMLNodeText(xDoc,'Datasets','Dwell_Time',1),mySub);
params.Main.Total_cycles = length(getXMLNodeText(xDoc,'Datasets','Dwell_Time',1));
params.Main.Scanline_period__us_ = 1e3*subsref(getXMLNodeText(xDoc,'Datasets','Scanline_Period',1),mySub);
params.Main.Lines_per_frame=subsref(getXMLNodeText(xDoc,'Datasets','Lines_Per_Frame',1),mySub);
params.Main.Pixels_per_line= subsref(getXMLNodeText(xDoc,'Datasets','Pixels_Per_Line',1),mySub);
framerate = subsref(getXMLNodeText(xDoc,'Datasets','Framerate',1),mySub);
params.Main.Frame_period__us_ = (1/framerate) * 1e6;

params.Image_TimeStamp__us_ = [];

numImages = getXMLNodeText(xDoc,'Datasets','Frames',1);
for i=1:params.Main.Total_cycles,
	eval(['params.Cycle_' int2str(i) '.Number_of_images=numImages{i};']);

	ts = getXMLNodeText(xDoc,['Dataset_x0020_' int2str(i)],'Time',1);
	params.Image_TimeStamp__us_ = cat(2,params.Image_TimeStamp__us_,...
		1e3*[ts{:}]);
end;
