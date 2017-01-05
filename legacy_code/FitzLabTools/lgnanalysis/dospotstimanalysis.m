function [params,ra] = dospotstimanalysis(spiketimes,stimtimes,conditionname,display)

% DOSPOTSTIMANALYSIS - Analyze data from spot stim
%
%  [PARAMS,RASTEROBJ] =DOSPOTSTIMANALYSIS(SPIKETIMES,STIMTIMES,...
%     CONDITIONNAME,DISPLAY)
%
%  Extracts parameters for spot stimulus.
%
%  Expects spiketimes and stimtimes in seconds.
%
%  CONDITIONNAME should describe the type of stimulus (e.g., 'S+')
%
%  DISPLAY is 0/1; results will be displayed in a figure.
%  
%  PARAMS is a structure of results with fields
%
%    LATENCY - the latency in seconds
%    INITRESP - the initial response (mean, std_dev, std_err)
%    MAINTRESP - the response 300ms later (mean, std_dev, std_err)
%  

stimtimes = sort(stimtimes);

inp.spikes= cksmultipleunit([stimtimes(1)-0.5 stimtimes(end)+0.5],'','',spiketimes,'');

inp.triggers = { stimtimes};
inp.condnames = {conditionname};

P.res = 0.001;
P.interval = [ 0 1];
P.normpsth = 1;
P.showvar = 0;
P.fracpsth = 0.5;
P.psthmode = 0;
P.showfrac = 1;
P.cinterval = [ 0 0.5];
P.showcbars = 1;
P.axessameheight = 1;

if display,
	where.figure=figure;where.rect=[0 0 1 1]; where.units='normalized';
	orient(where.figure,'landscape');
else,
	where = [];
end;

ra = raster(inp,P,where);
P = getparameters(ra),

cr = getoutput(ra);

bt = diff(cr.bins{1}(1:2)); % time of 1 bin
l = size(cr.values{1},2);  % number of trials


[mm,ii] = max(cr.counts{1});
tlat = cr.bins{1}(ii);  % now we have latency

 % early window is latency to latency plus 0.050
 % late window is 300ms later unless that is beyond the end of stim
ear = tlat + [0 0.050];
lat = tlat + 0.3 + [0 0.050];
if max(lat)>0.5, lat = 0.45 + [0 0.050]; end;

e1 = findclosest(cr.bins{1},ear(1));
e2 = findclosest(cr.bins{1},ear(2));
l1 = findclosest(cr.bins{1},lat(1));
l2 = findclosest(cr.bins{1},lat(2));

x=sum(cr.counts{1}(e1:e2))/(bt*l*(e2-e1+1));
y=sum(cr.counts{1}(l1:l2))/(bt*l*(e2-e1+1));
trans = (x-y)/x;

replyear = []; replylat = [];  % get individual trial values for stats
for I=1:l,
        replyear(end+1) = sum(cr.values{1}(e1:e2,I))/(bt*(e2-e1+1));
        replylat(end+1) = sum(cr.values{1}(l1:l2,I))/(bt*(l2-l1+1));
end;


params.latency = tlat;
params.initresp = [ mean(replyear) std(replyear) std(replyear)/sqrt(l)];
params.maintresp = [ mean(replylat) std(replylat) std(replylat)/sqrt(l)];
params.trans = trans;
