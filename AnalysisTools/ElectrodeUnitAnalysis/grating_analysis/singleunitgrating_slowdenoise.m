function [mycell,groups, pref, params,pc,s,co] = singleunitgrating_slowdenoise(ds, mycell, mycellname, dirname, paramname, display, stimnumfield, mlesmoothness)
% SINGLEUNITGRATING_SIMPLE - Analyze spike responses to a grating stimulus
%
%  [MYCELL, GROUPS, PREF, PARAMS, DUMMY, S, CO] = SINGLEUNITGRATING_SLOWDENOISE(...
%     DS, MYCELL, MYCELLNAME, DIRNAME, PARAMNAME, DISPLAY, STIMNUMFIELD, MLESMOOTHNESS)
%
%  Inputs:
%     DS - Directory structure (dirstruct object) for the experiment
%     MYCELL - A cell (spikedata object)
%     MYCELLNAME - The string name of the cell in CELL_NAME_REF_CLS_YEAR_MN_DY,
%          where NAME is the name of the corresponding name/ref record that corresponds
%          to the electrode, REF is a 4 digit number that specifies the reference number
%          of the electrode, CLS is a 3 digit number that specifies the cluster number of 
%          the unit on the electrode, YEAR is the 4 digit year, MN is 2 digit month, and
%          DY is the 2 digit day of the experiment.
%    DIRNAME - the directory name to be analyzed
%    PARAMNAME - the parameter of the grating stimulus to be analyzed, such as 
%          'angle', or 'sFrequency'. See help periodicstim for a list.
%    DISPLAY - 0/1 should we display the result in a window?
%    STIMNUMFIELD - (Optional argument, default 0 if not present) 0/1 Should we analyze
%          the stimuli by stimulus number (1, 2, ...) instead of the parameter specified in
%          PARAMNAME?  This is useful if more than 1 parameter has been varied and one wants
%          to plot the data on a single axis.
%    MLESMOOTHNESS - How much can the MLE change from point to point? (Can be Inf to ignore)
%
%  Outputs:  (These outputs are generally single quantities, except in the event that the
%             script has multiple iontophoretic current pulses, in which case they are 
%             cell lists, one entry for each iontophoretic current pulse value.)
%     MYCELL - The cell (spikedata object), with any new associates generated here attached
%     GROUPS - The values of the iontophoretic pulses (default [] if there are no pulses)
%     PREF - The parameter value with the maximum response. If the greatest F1 response is
%            greater than the greatest F0 response, then the parameter with the maximum
%            F1 value is reported.
%     PARAMS - a cell list of parameter structures for all stimuli in the stimscript
%     DUMMY - An empty variable; here so the output argument form is the same as SINGLEUNITGRATING2
%     S - The stimscripttimestruct that contains the stimscript and the mti record for the
%            directory DIRNAME.
%     CO - The computed outputs 
%     
%
%  See also:  DIRSTRUCT, SPIKEDATA, PERIODIC_CURVE, STIMSCRIPT, CELLNAME2NAMEREF,
%             STIMSCRIPTTIMESTRUCT, STIMULUS/GETPARAMETERS


params = {};
currValues = [];
groups = [];

if nargin>=7,
	if stimnumfield==0,
		stimnumfield = [];
	end;
end;

if ischar(dirname),
    [dirname paramname ],
    s = getstimscripttimestruct(ds,dirname);
    [s.stimscript,tempmti,inds_nottotrim] = stimscriptmtitrim(s.stimscript,s.mti,1);
    s.mti = tpcorrectmti(s.mti,[getpathname(ds) filesep dirname filesep 'stimtimes.txt'],1);
    s.mti = s.mti(inds_nottotrim);
else,
    s = dirname{1};
    dirname = dirname{2};
    %keyboard;
end;

list = sswhatvaries(s.stimscript),
if ~isempty(intersect(list,'iontophor_curr')),
    % divide into groups
    pc = {}; params = {}; s_ = {}; co = {}; pref = {};
        % first get list of values
    for i=1:numStims(s.stimscript),
        currValues(i) = getfield(getparameters(get(s.stimscript,i)),'iontophor_curr');
    end;
    groups = unique(currValues);
    do = getDisplayOrder(s.stimscript);
    for g=1:length(groups),
        % make a new script only using stims from the group
        newscript = stimscript(0);
        doInds = [];
        doVals = [];
        for i=1:numStims(s.stimscript),
            if currValues(i)==groups(g),
                para = getparameters(get(s.stimscript,i));
                para.length = para.rect(3)-para.rect(1);
                stimclass = class(get(s.stimscript,i));
                eval(['newstim = ' stimclass '(para);']);
                newscript = append(newscript,newstim);
                doInds = [doInds find(do==i)];
                doVals = [doVals numStims(newscript)*ones(size(find(do==i)))];
            end;
        end;
        [doInds,scramble] = sort(doInds);
        sn.stimscript = setDisplayMethod(newscript,2,doVals(scramble));
        sn.mti = s.mti(doInds);
        if nargin>7,
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating_simple(ds, mycell, mycellname, {sn dirname}, paramname, display, stimnumfield);
        else,
            [mycell,assocs, prefout, paramsout,pcout,s_out,coout] = singleunitgrating_simple(ds, mycell, mycellname, {sn dirname}, paramname, display);
        end;
        pref{g} = prefout;
        params{g} = paramsout;
        pc{g} = pcout;
        s_{g} = s_out;
        co{g} = coout;
    end;
    s = s_;
    i = findclosest(groups,0);
    pref = pref{i};
    return;
end;
 % identify the blank stim, or add parameters
blankid = -1;
myTf = 4;

for i=1:numStims(s.stimscript),
	p=getparameters(get(s.stimscript,i));
	params{i} = p;
	if isfield(p,'chromhigh'), if eqlen(p.chromhigh,p.chromlow), blankid = i; break; end; end;
	if isfield(p,'isblank'), blankid = i; break; end;
	if isfield(p,'tFrequency'),
		myTf = p.tFrequency;
	end;
	if nargin>=7,
		if ~isempty(stimnumfield),
			p = setfield(p,stimnumfield,i);
			s.stimscript = set(s.stimscript,eval([class(get(s.stimscript,i)) '(p)']),i);
		end;
	end;
end;

if blankid>1,
	inp.blankid = i;
end;

if 0, % optionally, remove blank
	do = getDisplayOrder(s.stimscript);
	dogood = find(do~=blankid);
	donew = do(dogood);
	s.stimscript = remove(s.stimscript,blankid);
	s.stimscript = setDisplayMethod(s.stimscript,2,donew);
	s.mti = s.mti(dogood);
    clear inp;
end;


[stimtimes_on,stimtimes_off] = mti2stimonoff(s.mti,1);
[stim_values,stimids] = stimscript2stimvalues(s.stimscript,paramname);
spiketimes = get_data(mycell,[stimtimes_on(1)-100 stimtimes_off(end)+100],2);  % 2 means suppress errors if we didn't record 100 seconds before or after recording

 % now do slowMLEdenoise
rc = spikeresponse(stimtimes_on,stimtimes_off,stim_values,spiketimes); % for initial guesses

[s_i_params, g_params, sinparams, mle, responseobserved, stimlist, responses_s_i, smooth_time, smooth_spikerate, sinfit_smooth_spikerate] = ...
	SlowMLEDeNoise(stimtimes_on, stimtimes_off, stimids, spiketimes,'showfitting',1,'numIterations',3,...
	'mlesmoothness',mlesmoothness,'responses_s_i',[],'model','Poisson','verbose',0);

co.nosdn_f0vals{1} = rc.inds;
co.nosdn_f0curve{1} = rc.curve;
co.nosdn_f0blank = rc.blank;
co.nosdn_f0blankinds = rc.blankinds;

co.nosdn_f0normcurve{1} = rc.curve;
co.nosdn_f0normcurve{1}(2:end,:) = rc.curve(2:end,:)/max(rc.curve(2,:)); % normalize

co.f0smooth_time = smooth_time;
co.f0smooth_spikerate = smooth_spikerate;
co.f0sinfit_smooth_spikerate = sinfit_smooth_spikerate;

if any(isnan(stim_values)),
	co.f0mean = s_i_params(1:end-1)/max(s_i_params(1:end-1));
else,
	co.f0mean = s_i_params/max(s_i_params);
end;


resp = descramble_pseudorandom(responses_s_i, stim_values);
resp.curve = trimrespcurve(resp.curve); % remove the "blank" from the curve
resp.curve(2:end,:) = resp.curve(2:end,:) / max(resp.curve(2,:));

co.f0vals{1} = resp.inds;
co.f0curve{1} = resp.curve;
co.f0blank = resp.blank;
co.f0blankinds = resp.blankinds;
co.f0curve{1}(2,:) = co.f0mean;

rc_f1 = spikeresponse_tf(stimtimes_on,stimtimes_off,stim_values,spiketimes,0.001,myTf);
response_rate = [];
for i=1:length(stimtimes_on),
	spike_response_index = rc_f1.indexes(i,:);
	response_rate(i) = rc_f1.inds{spike_response_index(1)}(spike_response_index(2));
end;
response_s_i_f1_arg = abs(response_rate);

[s_i_params_f1, g_params_f1, sinparams_f1, mle_f1, responseobserved_f1, stimlist_f1, responses_s_i_f1, smooth_time_f1, smooth_spikerate_f1, sinfit_smooth_spikerate_f1] = ...
	SlowMLEDeNoise(stimtimes_on, stimtimes_off, stimids, spiketimes,'showfitting',1,'numIterations',6,...
	'mlesmoothness',mlesmoothness,'responses_s_i',response_s_i_f1_arg,'model','Gaussian');

co.nosdn_f1vals{1} = rc_f1.inds;
co.nosdn_f1curve{1} = rc_f1.curve;
co.nosdn_f1blank = rc_f1.blank;
co.nosdn_f1blankinds = rc_f1.blankinds;

co.nosdn_f1normcurve{1} = rc_f1.curve;
co.nosdn_f1normcurve{1}(2:end,:) = rc_f1.curve(2:end,:)/max(rc_f1.curve(2,:)); % normalize

if any(isnan(stim_values)),
	co.f1mean = s_i_params_f1(1:end-1)/max(s_i_params_f1(1:end-1));
else,
	co.f1mean = s_i_params_f1/max(s_i_params_f1);
end;

co.f1smooth_time = smooth_time_f1;
co.f1smooth_spikerate = smooth_spikerate_f1;
co.f1sinfit_smooth_spikerate = sinfit_smooth_spikerate_f1;

respf1 = descramble_pseudorandom(responses_s_i_f1, stim_values);
respf1.curve = trimrespcurve(respf1.curve); % remove the "blank" from the curve
respf1.curve(2:end,:) = respf1.curve(2:end,:) / max(respf1.curve(2,:));

co.f1vals{1} = respf1.inds;
co.f1curve{1} = respf1.curve;
co.f1blank = respf1.blank;
co.f1blankinds = respf1.blankinds;
co.f1curve{1}(2,:) = co.f1mean;

 % here need to convert responses to f0, f1 curve

if display,
	figure;
	subplot(2,2,1);
	h = myerrorbar(co.nosdn_f0normcurve{1}(1,:),co.nosdn_f0normcurve{1}(2,:),co.nosdn_f0normcurve{1}(4,:));
	set(h,'linewidth',2,'color',[0 0 1]);
	hold on;
	h = plot(co.f0curve{1}(1,:),co.f0mean,'linewidth',2,'color',[0 1 0]);
	box off;
	xlabel(paramname);
	ylabel('Spike rate (Hz)');
	subplot(2,2,2);
	h = myerrorbar(co.nosdn_f1normcurve{1}(1,:),abs(co.nosdn_f1normcurve{1}(2,:)),co.nosdn_f1normcurve{1}(4,:));
	set(h,'linewidth',2,'color',[0 0 1]);
	hold on;
	h = plot(co.f1curve{1}(1,:),abs(co.f1mean),'linewidth',2,'color',[0 1 0]);
	xlabel(paramname);
	ylabel('Modulation rate (Hz)');
	box off;
end;


pc = [];

[mf0,if0]=max(co.f0curve{1}(2,:));
[mf1,if1]=max(co.f1curve{1}(2,:));
maxgrating = [mf0 mf1];
f1f0=mf1/(mf0+0.00001);
otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];

if mf1>mf0, pref = otpref(2); else, pref = otpref(1); end;

return;



if iscell(paramname), inp.paramnames = paramname;
else, inp.paramnames = {paramname};
end;
inp.spikes = mycell;
inp.st = s;
inp.title = [mycellname ' ' dirname];

if display,
  where.figure=figure; where.rect=[0 0 1 1];
  where.units='normalized'; orient(where.figure,'landscape');
else, where = [];
end;

inp,inp.st,

pc = periodic_curve(inp,'default',where);
p = getparameters(pc);
p.graphParams(4).whattoplot = 6;
p.res = 0.001;
pc = setparameters(pc,p);
co = getoutput(pc);

[mf0,if0]=max(co.f0curve{1}(2,:));
[mf1,if1]=max(co.f1curve{1}(2,:));
maxgrating = [mf0 mf1];
f1f0=mf1/(mf0+0.00001);
otpref = [co.f0curve{1}(1,if0) co.f1curve{1}(1,if1)];

if mf1>mf0, pref = otpref(2); else, pref = otpref(1); end;

f0curve = [co.f0curve{1}];
f1curve = [co.f1curve{1}];

  % now add extra analysis here
