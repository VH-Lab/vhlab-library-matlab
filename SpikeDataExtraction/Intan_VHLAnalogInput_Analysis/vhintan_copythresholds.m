function [status_str] = vhintan_copythresholds(ds, dirname)
% VHINTAN_COPYTHRESHOLDS - Copy thresholds from earlier records into later records
%
%   STATUS_STR = VHINTAN_COPYTHRESHOLDS(DS)
%
%   Copy threshold records from earlier records into later records.
%
%   If a second argument is given, then it copies the data from DIRNAME into 
%   all subsequent records.
%   STATUS_STR = VHINTAN_COPYTHRESHOLDS(DS)
%
%   Warning: this function is at present blind. It does not examine whether or not
%   the recorded channels correspond to the same name/ref channels and so one needs
%   to check the results to make sure the thresholds look good.
%
%   A string describing the status is returned in STATUS_STR.
%   Example STATUS_STR responses:
%      'Nothing done. All records were complete'  % function found nothing to do
%      'Nothing done. No complete thresholds found' % function found no complete thresholds'
%      'Thresholds of DIR1 applied to DIR2, DIR3, ...'
%   

[dirlist,status] = vhintan_getdirectorystatus(ds);

thresh_done = [status.vhintan_thresholds];

if all(thresh_done)&nargin<2,
	status_str = 'Nothing done. All records were complete.';
	return;
elseif ~any(thresh_done),
	status_str = 'Nothing done. No complete thresholds found.';
	return;
end;

% make sure directories are in alphabetical order

[dirlist,dirorder] = sort(dirlist);
status = status(dirorder); % make sure status matches dirlist

lastdone = find(thresh_done,1,'last');

if nargin>1,   % instead of the last one, use the requested one in dirname; but we'll keep the variable name
	lastdone = find(strcmp(dirname,dirlist));
	if ~thresh_done(lastdone),
		status_str = ['Nothing done. Directory ' dirname ' had incomplete threshold records.'];
	end;
end;

pathname = getpathname(ds);
vhintan_thresholds_filename = 'vhintan_thresholds.txt';

status_str = ['Thresholds of ' dirlist{lastdone} ' were applied to '];

for i=lastdone+1:length(dirlist),
	copyfile(fullfile(pathname,dirlist{lastdone},vhintan_thresholds_filename),...
		fullfile(pathname,dirlist{i},vhintan_thresholds_filename));
	status_str = cat(2,status_str,dirlist{i});
	if i~=length(dirlist),
		status_str = cat(2,status_str,', ');
	else,
		status_str(end+1) = '.';
	end;
end;

