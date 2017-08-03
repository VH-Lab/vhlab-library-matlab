function [otindexstruct] = extract_oridir_indexes_struct(cell,varargin)
% Extract common orientation/direction index values from a cell
%
%  [OTINDEXSTRUCT] = EXTRACT_ORIDIR_INDEXES_STRUCT(CELL)
%
%  Returns several common index values from a CELL that is an
%  object of type MEASUREDDATA.
%
%  Returns a structure OTINDEXSTRUCT with fields:
%    F1F0 -- the F1/(F0+F1) ratio
%    DIRPREF -- the direction preference angle
%    OI -- the orientation index from Li/Van Hooser et al. 2008
%    TUNEWIDTH -- Half width at half height orientation fit
%    CV -- the circular variance
%    DI -- the direction index from Li/Van Hooser et al. 2008
%    DIRCV -- the direction circular variance from Mazurek et al. 2014
%    SIG_ORI -- the P value that determines if there is a significant
%           orientation signal to be fit
%    BLANK_RATE -- the firing rate during the "blank" stimulus
%    MAX_RATE -- The firing rate to the "best" stimulus
%    COEFF_VAR -- the coefficient of variation to the best stimulus
%    PREF -- the response to the preferred direction (fit), blank subtracted
%    NULL -- the response to the opposite direction (fit), blank subtracted
%    ORTH -- the response to the orthogonal orientation (fit), blank subtracted
%    FIT -- the fitted response, blank-subtracted
%  This function's beheavior may be modified by name/value pairs:
%  Parameters (default)     | Description
%  -----------------------------------------------------------
%  TestType ('OT')          | The test type
%  ColorType ('Ach')        | The color type

TestType = 'OT';
ColorType = 'Ach';

assign(varargin{:});

[f1f0,dirpref,oiind,tunewidth,cv,di,sig_ori,blank_rate, max_rate, coeff_var, pref, null, orth, fit, sig_vis,dircv] = extract_oridir_indexes(cell,...
	'TestType',TestType,'ColorType',ColorType);

otindexstruct = var2struct('f1f0','dirpref','oiind','tunewidth','cv','di','sig_ori','blank_rate', ...
		'max_rate', 'coeff_var', 'pref', 'null', 'orth', 'fit','sig_vis','dircv');
