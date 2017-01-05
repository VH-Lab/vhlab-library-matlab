function [output] = extract_spatial_frequency_test(cell, prefix, testname, color, useF0)
% Extract common orientation/direction index values from a cell from a given test
%
%  [OUTPUT] = EXTRACT_SPATIAL_FREQUENCY_TEST(CELL, PREFIX, TESTNAME, COLOR [, USEF0])
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
%    *sig_vis -- the P value that determines if there is a significant
%           visual response
%    *blank_rate -- the firing rate during the "blank" stimulus
%    *sf_pref -- the spatial frequency with the most firing
%    *max_rate -- The firing rate to the "best" stimulus
%    *coef_var -- the coefficient of variation to the best stimulus
%    *f0f1 -- the f1/f0 ratio
%    time -- the time of the test (in seconds since midnight of the first day of experiment)
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
f1f0 = NaN; sf_pref = NaN; blank_rate = NaN; max_rate = NaN;
coef_var = NaN; dr = NaN; sig_vis = NaN; time = NaN; sf_response_curve = NaN;

trainingtype = '';
trainingangle = NaN;
trainingtf = NaN;
trainingstim = NaN;

 % step 3 - decide if we are F0 or F1 (complex/simple)

if strcmp(prefix(1:2),'SP'), % we need to examine both F0 and F1 and pick the best and calculate f1f0
	[b,f1f0dummy,f1f0] = issimplecell(cell, testname, ...
		'AssociateTestPostfix','Ach SF Response curve', ...
		'BlankTestPostfix','Ach SF Blank Response');

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



assoc_names = {'SF visual response p','SF Blank Response','SF Pref', 'SF Response curve'};

anyempty = 0;

for i=1:length(assoc_names),
	a{i} = findassociate(cell,[prefix testname color assoc_names{i}],'','');

	if isempty(a{i}), 
		anyempty = 1;
	end;
end;

if ~anyempty,
	blank_rate = a{2}.data(1);
	sf_pref = a{3}.data;
	sig_vis = a{1}.data;
	%[max_rate,coef_var] = neural_maxrate_variability(a{2}.data);
	%max_rate = max_rate - blank_rate;
	sf_response_curve = a{4}.data;
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

 % make the output variable

allout = workspace2struct;

fn = {'f1f0', 'sf_pref', 'sig_vis','blank_rate', 'sf_response_curve', ...
		'time',...
		'trainingtype','trainingangle','trainingtf','trainingstim'};

output = struct;

for i=1:length(fn), 
	output = setfield(output,fn{i},eval(fn{i}));
end;



