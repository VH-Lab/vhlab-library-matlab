function [mti2, saveScript] = fitzcreatemti(filename,isi,paramname,varargin)

% FITZCREATEMTI - Create NewStim MTI based on recorded times, info
%
% [MTI2,SAVESCRIPTED] = FITZCREATEMTI(STIMTIMEFILE, ISI, PARAMNAME,...
%		STIMNUM1, PARAMVALUE1, STIMNUM2, PARAMVALUE2, ...);
%
%   Returns a time-corrected MTI timing file given actual timings
% recorded by the Spike2 machine and saved in a file named 
% STIMTIMEFILE.  Normally, this information is read directly from
% a 'stims.mat' file in the directory but here this information can
% be specified directly.
%
% ISI is the interstimulus interval.  If it is negative, the ISI is
% taken to have occurred before the stimulus.  If it is positive,
% it is taken to have occurred after the stimulus.
%
% PARAMNAME is the parameter name that is varied across the script.
% This must be a valid MATLAB variable.
%
% The last arguments are stimulus number and paramvalue pairs.
%
% If the interstimulus ISI, PARAMNAME, and PARAMVALUES are not specified
% then the user is interviewed for these values.

fid = fopen(filename);

if nargin==1,
	[dirname] = fileparts(filename);
	fitzlabstiminterview(dirname);
	return;
end;

if fid<0, error(['Could not open file ' filename ', with error ' lasterr '.']); end;

mtis = struct('preBGframes',0,'postBGframes',0,'pauseRefresh',[],'frameTimes',[],'startStopTimes',[],'ds',[],'df',[],...
	'stimid','0','GammaCorrectionTable',repmat([0:255]',1,3));

mti2 = {};
dispOrder = [];
StimWindowGlobals;

while ~feof(fid),
		mtin = mtis;
		stimline = fgets(fid);
		if length(stimline)>2,
			stimdata = sscanf(stimline,'%f');
			mtin.frameTimes = stimdata(3:end);
			if isi<0,
				mtin.preBGframes = fix(-isi*StimWindowRefresh);
				mtin.startStopTimes = [stimdata(2)+isi stimdata(2) stimdata(end) stimdata(end) ];
			else,
				mtin.postBGframes = fix(isi*StimWindowRefresh);
				mtin.startStopTimes = [stimdata(2) stimdata(2) stimdata(end) stimdata(end)+isi];
			end;
			mtin.stimid = stimdata(1);
			dispOrder(end+1) = mtin.stimid;
			mti2 = cat(2,mti2,{mtin});
		end;
end;

fclose(fid);

dp = {};
if isi<0, dp = {'BGpretime',-isi}; elseif isi>0, dp = {'BGposttime',isi}; end;


 % now create the stims
saveScript = stimscript(0);
for i=1:max(dispOrder), saveScript =  append(saveScript,stimulus(5)); end;
for i=1:2:length(varargin),
	p = struct(paramname,varargin{i+1},'dispprefs',{dp}),
	newbl = blank(p);
	saveScript = set(saveScript,newbl,varargin{i});
end;

saveScript = setDisplayMethod(saveScript,2,dispOrder);

[thedir,thename] = fileparts(filename);
MTI2 = mti2; start = 0;
save ([fixpath(thedir) 'stims.mat'],'saveScript','MTI2','start','-mat');
