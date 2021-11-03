function [output] = extract_oridir_test(cell, prefix, testname, color, useF0)
% Extract common orientation/direction index values from a cell from a given test
%
%  [OUTPUT] = EXTRACT_ORIDIR_TEST(CELL, PREFIX, TESTNAME, COLOR [, USEF0])
%
%  Returns several common index values from a CELL that is an
%  object of type MEASUREDDATA.
%
%  PREFIX is the associate prefix, such as 'TP ' or 'SP F0'. If PREFIX begins
%  with 'SP' then the F0/F1 is examined, and the other indexes are based on the stimulus
%  that produced the greater response (F0 or F1). If the input USEF0 is present and is 0
%  then the F1 is used no matter what; if the input USEF0 is present and is 1, then F1 is
%  used no matter what (use empty to force the comparison when providing the input USEF0).
%
%  TESTNAME is the name of a test type such as 'Dir1Hz1'; if this experiment did
%  not involve multiple measurements, one can provide ''.
%
%  COLOR: The color to be examined. Most users will just put 'Ach ', which is the
%  default value if COLOR is not provided ('Ach ' means achromatic).
%
%  If CELL does not have the associates that provide the data for the fields marked with a 
%  '*' below, then NaN is returned for all fields.
%
%  Returns a structure OUTPUT with the following fieldnames:
%    *vis_resp_p -- the likelihood there are significant differences across all responses
%          and blank
%    *f1f0 -- the F1/(F0+F1) ratio (NaN for TP records or other records where
%          F0/F1 information is not available)
%    *dirpref -- the direction preference angle
%    *oi -- the orientation index from Li/Van Hooser et al. 2008
%    *tunewidth -- Half width at half height orientation fit
%    *cv -- the circular variance
%    *dcv -- the circular variance in direction space
%    *di -- the direction index from Li/Van Hooser et al. 2008
%    *sig_ori -- the P value that determines if there is a significant
%           orientation signal to be fit
%    *sig_vis -- the P value that determines if there is a significant
%           visual response
%    *blank_rate -- the firing rate during the "blank" stimulus
%    *max_rate -- The firing rate to the "best" stimulus
%    *coef_var -- the coefficient of variation to the best stimulus
%    *pref -- the response to the preferred direction (fit), blank subtracted
%    *null -- the response to the opposite direction (fit), blank subtracted
%    *orth -- the response to the orthogonal orientation (fit), blank subtracted
%    time -- the time of the test (in seconds since midnight of the first day of experiment)
%    dr - the direction ratio (with respect to the training angle)
%    trainingtype - The 'training type' used, if any
%    trainingangle - The training angle used, if any
%    trainingtf - the training temporal frequency used, if any
%    trainingstim - the training stim if any
% 

 % step 1 - set the input arguments correctly
if nargin<4,
	color = 'Ach ';
end;

if nargin<5,
	useF0 = [];
end;

 % gracefully add spaces if the user forgot (and not even requested for testname)

if prefix(end) ~= ' ', prefix(end+1) = ' '; end;
if (length(testname)>1) & (testname(end)) ~= ' ', testname(end+1) = ' '; end;
if color(end) ~= ' ', color(end+1) = ' '; end;

 % step 2 - initialize the output

 % initially, everything is NaN; it gets overwritten if it has an actual value
f1f0 = NaN; dirpref = NaN; oiind = NaN; tunewidth = NaN; cv = NaN;
dcv = NaN; di =NaN; sig_ori = NaN; blank_rate = NaN; max_rate = NaN; pref = NaN;
null = NaN; orth = NaN; coef_var = NaN; dr = NaN; sig_vis = NaN;
time = NaN; di_signtrainingangle = NaN;
OTresponsestruct = [];
OTresponsecurve = [];
OTfit = [];

trainingtype = '';
trainingangle = NaN;
trainingtf = NaN;
trainingstim = NaN;

 % step 3 - decide if we are F0 or F1 (complex/simple)

if strcmp(prefix(1:2),'SP'), % we need to examine both F0 and F1 and pick the best and calculate f1f0
	[b,f1f0dummy,f1f0] = issimplecell(cell, testname);

	if isnan(b), b = 0; end;

	if ~isempty(useF0),
		b = 1-useF0; % useF0
	end;

	if b,
		prefix = 'SP F1 ';
	else,
		prefix = 'SP F0 ';
	end;
end;



assoc_names = {'OT visual response p','OT Carandini Fit','OT Response struct',...
		'OT Tuning width','OT Fit Orientation index blr',...
		'OT Fit Direction index blr','OT vec varies p','OT Blank Response','OT Max Response',...
		'OT Fit Pref','OT Circular variance','OT Response curve'};

anyempty = 0;

for i=1:length(assoc_names),
	a{i} = findassociate(cell,[prefix testname color assoc_names{i}],'','');

	if isempty(a{i}), 
		anyempty = 1;
	end;
end;



if ~anyempty,
    OTresponsecurve = a{12}.data;
    OTfit = a{2}.data;
    OTresponsestruct = a{3}.data;
    blank_rate = a{8}.data(1);
	dirpref = a{10}.data;
	oiind = a{5}.data;
	tunewidth = a{4}.data;
	cv = a{11}.data;
	dcv = cell2dircircular_variance(cell,[prefix testname color]);
	di = a{6}.data;
	sig_ori = a{7}.data;
	sig_vis = a{1}.data;
	pref = fit2pref(a{2}.data(2,:))-blank_rate;
	null = fit2null(a{2}.data(2,:))-blank_rate;
	orth = fit2orth(a{2}.data(2,:))-blank_rate;
	[max_rate,coef_var] = neural_maxrate_variability(a{3}.data);
	max_rate = max_rate - blank_rate;
end;



t = findassociate(cell,[testname 'time'],'','');

if ~isempty(t),
	time = t.data;
end;

t1=findassociate(cell,['Training Type'],'','');
if ~isempty(t1), trainingtype = t1.data; end;
t2=findassociate(cell,['Training Angle'],'','');
if ~isempty(t2), trainingangle = t2.data; end;
t3=findassociate(cell,['Training TF'],'','');
if ~isempty(t3), trainingtf = t3.data; end;
t4=findassociate(cell,['Training Stim'],'','');
if ~isempty(t4), trainingstim = t4.data; end;

if ~isempty(t2)&~isempty(t1)
	if strcmp(lower(t1.data),'unidirectional'),
		%dr = fit_dr_ratio(cell,testname,'AssociateTestPrefix',prefix);
		dr = raw_dr_ratio(cell,testname,'AssociateTestPrefix',prefix);
	else,
		dr = NaN;
	end;
end;

 % make the output variable

allout = workspace2struct;

fn = {'f1f0', 'dirpref', 'oiind', 'tunewidth', 'cv', 'dcv','di', 'sig_ori', 'sig_vis','blank_rate', 'max_rate',  ...
		'pref', 'null', 'orth','coef_var','time','dr','trainingtype','trainingangle','trainingtf','trainingstim','OTresponsestruct','OTresponsecurve','OTfit'};

output = struct;

for i=1:length(fn), 
	output = setfield(output,fn{i},eval(fn{i}));
end;



