function [assoc] = read_trainingtype(ds, varargin)
% READ_TRAININGTYPE Read the trainingtype.txt file and prepare data to associate with cells
%
%  ASSOC = READ_TRAININGTYPE(DS, ...)
%
%  Reads the 'trainingtype.txt', 'trainingangle.txt', 'trainingtemporalfrequency.txt',
%  and 'trainingstim.txt' files in the directory described by the DIRSTRUCT DS.
%  The function returns a list of associates of the following types:
%
%  Type:            |  Description:
%  ---------------------------------------------------------------
%  'Training Type'  |  The type of training that was employed
%                   |     The 'data' field will be one of the following:
%                   |     {'none','bidirectional','unidirectional',...
%                   |      'multidirectional','flash','scrambled',...
%                   |      'counterphase'}
%  'Training Angle' |  The angles used in training (may be more than one)
%  'Training TF'    |  The temporal frequencies used in training
%  'Training Stim'  |  The stimulus id of a scrambled training stim (a text string)
%
%  By default, these associates are created if the corresponding file exist.
%  One can trigger an error if these files are not present by passing
%  additional name/value pairs:
%  Name (default):              | Description
%  ---------------------------------------------------------------
%  'ErrorIfNoTrainingType' (0)  | 0/1 Generate an error if there's no
%                               |    'trainingtype.txt' file
%  'ErrorIfNoTrainingAngle' (0) | 0/1 Generate an error if there's no
%                               |    'trainingangle.txt' file
%  'ErrorIfNoTF' (0)            | 0/1 Generate an error if there's no
%                               |    'trainingtemporalfrequency.txt' file
%  'ErrorIfNoTrainingStim (0)   | 0/1 Generate an error if there's no
%                               |    'trainingstim.txt' file
%  
%
%  See also: TRAININGTYPE, TRAININGANGLE, TRAININGSTIM, TRAININGTEMPORALFREQUENCY

ErrorIfNoTrainingType = 0;
ErrorIfNoTrainingAngle = 0;
ErrorIfNoTrainingTF = 0;
ErrorIfNoTrainingStim = 0;

assign(varargin{:});

assoc = struct('type','','owner','','data','','desc','');
assoc = assoc([]);

 % Step 1: read trainingtype.txt

filename = [getpathname(ds) filesep 'trainingtype.txt'];

if exist(filename)==2,
	fid = fopen(filename,'rt');
	if fid<0,
		error(['Error opening the file trainingtype.txt in directory ' getpathname(ds)]);
	else,
		str = fgetl(fid);
		fclose(fid);
		type = '';
		switch (lower(str)),
			case {'none'},
				type = 'none';
			case {'flash'},
				type = 'flash';
			case {'bi','bidirectional','bi-directional'},
				type = 'bidirectional';
			case {'uni','unidirectional','uni-directional'},
				type = 'unidirectional';
			case {'counterphase','cp','counter-phase'},
				type = 'counterphase';
			case {'scrambled'},
				type = 'scrambled';
			case {'multi-dimensional','multidimensional'},
				type = 'multidimensional';
			case {'constant','const'},
				type = 'constant';
			otherwise,
				error(['Unknown type in trainingtype.txt: ' str '.']);
		end;
		assoc(end+1) = struct('type','Training Type','owner','read_trainingtype','data',type,'desc',...
			'type of visual training that was used');
	end;
else,
	if ErrorIfNoTrainingType,
		error(['No trainingtype.txt file in ' getpathname(ds) '; error was requested if no file exists.']);
	end;
end;

 % Step 2

filename = [getpathname(ds) filesep 'trainingangle.txt'];

if exist(filename)==2,
	angles = load(filename,'-ascii');
	assoc(end+1) = struct('type','Training Angle','owner','read_trainingtype','data',angles,'desc',...
			'angles used for visual training');
else,
	if ErrorIfNoTrainingAngle,
		error(['No trainingangle.txt file in ' getpathname(ds) '; error was requested if no file exists.']);
	end;
end;

filename = [getpathname(ds) filesep 'trainingtemporalfrequency.txt'];

if exist(filename)==2,
	tfs= load(filename,'-ascii');
	assoc(end+1) = struct('type','Training TF','owner','read_trainingtype','data',tfs,'desc',...
			'temporal frequencies used for visual training');
else,
	if ErrorIfNoTrainingTF,
		error(['No trainingtemporalfrequency.txt file in ' getpathname(ds) '; error was requested if no file exists.']);
	end;
end;

filename = [getpathname(ds) filesep 'trainingstim.txt'];

if exist(filename)==2,
	fid = fopen(filename,'rt');
	if fid<0, error(['Could not open the file trainingstim.txt for reading.']); end;
	str = upper(fgetl(fid));
	fclose(fid);
	assoc(end+1) = struct('type','Training Stim','owner','read_trainingtype','data',str,'desc',...
			'ID of scrambled stimulus');
else,
	if ErrorIfNoTrainingStim,
		error(['No trainingstim.txt file in ' getpathname(ds) '; error was requested if no file exists.']);
	end;
end;

