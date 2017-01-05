function FitzLabInit

pwd = which('FitzLabInit');
pi=find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];

addpath(pwd);
addpath([pwd filesep 'lgnanalysis']);

fitzlabtestid
FitzLabCalibrate;
