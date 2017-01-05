function dr = raw_dr_ratio(thecell, testname, varargin)
% RAW_DR_RATIO - Calculate direction ratio based on raw responses for unidirectionally-trained data
%
%  DR = RAW_DR_RATIO(THECELL, TESTNAME, ...)
%
% Loads data from TESTNAME (e.g., 'Dir1Hz3') and calculates the
% direction ratio for cell THECELL based on a fit to direction tuning.
% The training angle is looked up with the 'Training Angle' associate. 
%
% If there is no response in either direction, then 0 will be returned
% instead of NaN.
%
% The behavior of the program can be modified by passing NAME/VALUE
% pairs as additional arguments:
% Parameter (default)            | Description:
% -------------------------------------------------------------------
% ErrorIfTrainingTypeNotUni (1)  | Generate an error if the Training Type
%                                |   associate is not 'unidirectional'.
%                                |   If the user specifies TheTrainingAngle
%                                |   then this error is not generated.
% AssociateTestPrefix ('SP F0 ') | Prefix of associate to read
% AssociateTestPostfix           | Postfix of associate to read
% ('Ach OT Response curve') |
% BlankTestPostfix               | Postfix of blank response
%  ('Ach OT Blank Response')     |
% TrainingAngleAssociate         | TrainingAngleAssociate name
%   ('Training Angle')           |
% TheTrainingAngle ([])          | If provided, this is used as the
%                                |   training angle instead of reading
%                                |   from an associate. 
% UseDIForm (-1)                 | If 1, then calculate (Response(TheTrainingAngle) - 
%                                |   Response(TheTrainingAngle+180))/Response(TheTrainingAngle)
%
% See also: FIT_DR_RATIO

 % create default variables

ErrorIfTrainingTypeNotUni = 1;
AssociateTestPrefix = 'SP F0 ';
AssociateTestPostfix = 'Ach OT Response curve';
BlankTestPostfix = 'Ach OT Blank Response';
TrainingAngleAssociate = 'Training Angle';
TheTrainingAngle = [];
useDIForm = -1;

assign(varargin{:});

if testname(end)==' ', testname = testname(1:end-1); end; % trim any spaces


if ErrorIfTrainingTypeNotUni & isempty(TheTrainingAngle),
	B = findassociate(thecell,'Training Type','','');

	if isempty(B),
		error(['No Training Type associate.']);
	end;

	if ~strcmp(lower(B.data),'unidirectional'),
		error(['Expected unidirectional training but got ' B.data '.']);
	end;
end;

A = findassociate(thecell,[AssociateTestPrefix testname ' ' AssociateTestPostfix],'','');
Bl= findassociate(thecell,[AssociateTestPrefix testname ' ' BlankTestPostfix],'','');
C = findassociate(thecell,TrainingAngleAssociate,'','');

if isempty(A),
	error(['No associate ' [AssociateTestPrefix testname ' ' AssociateTestPostfix] '.']);
end;
if isempty(Bl),
	error(['No associate ' [AssociateTestPrefix testname ' ' BlankTestPostfix] '.']);
end;
if isempty(C) & isempty(TheTrainingAngle);,
	error('No Training Angle associate.');
end;

if isempty(TheTrainingAngle),
	TheTrainingAngle = C.data;
end;

angle_index = findclosest(angdiff(TheTrainingAngle-A.data(2,:)),0);
angleopp_index = findclosest(angdiff(180+TheTrainingAngle-A.data(2,:)),0);

respTrain = rectify(A.data(2,angle_index) - Bl.data(1));
respOppTrain = rectify(A.data(2,angleopp_index) - Bl.data(1));

if useDIForm<0,
	dr = respTrain / (respTrain+respOppTrain);
else,
	dr = (respTrain-respOppTrain) / (respTrain);
end;

if isnan(dr), dr = 0; end;

