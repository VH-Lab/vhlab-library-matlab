function s = modifyflanktuningstimforanalysis(s)
% MODIFYFLANKTUNINGSTIMFORANALYSIS - Convert a flank tuning stimscript to a periodicscript for use of standard analysis scripts
%
%  S = MODIFYFLANKTUNINGSTIMFORANALYSIS(S)
%
%  Given a structure S with fields 'stimscript' and 'mti', the structure is examined to
%  see if it is a flank tuning stimulus (that is, if it varies in 'flanklocori' and if all
%  stims except blank are of class 'multistim').
% 
%  If it is NOT a flank tuning stimulus, then S is returned unmodified.
%
%  If it IS a flank tuning stimulus, then a new stimscript is created with periodicscript
%  entries that correspond to the tuning properties of the center stimulus. This allows the
%  stimscript to be passed to our standard grating analysis routines.
%  

 % first, examine whether or not this is a flank tuning stimulus
  %  could be separated out into a isflanktuningstimscript.m file someday


whatvaries = sswhatvaries(s.stimscript);

if ~any(strcmp('flanklocori',whatvaries)),
	return; % definitely not a flankstim
end;

stimclasses = {};

for n=1:numStims(s.stimscript),
	stimclasses{n} = class(get(s.stimscript,n));
end;

if ~eqlen(unique(stimclasses),{'multistim','stochasticgridstim'}),
	return;
end;

 % if we are here, then we have a flankoristim

alt_stimscript = stimscript(0);

for n=1:numStims(s.stimscript),
	stim = get(s.stimscript,n);
	if strcmp(stimclasses{n},'multistim'),
		p = getparameters(stim);
		new_parameters = p.stimparameters{1};
		new_parameters.flanklocori = p.flanklocori;
		ps_stim = periodicstim(new_parameters);
		alt_stimscript = append(alt_stimscript, ps_stim);
	else,
		alt_stimscript = append(alt_stimscript, stim);
	end;
end;

do = getDisplayOrder(s.stimscript);

alt_stimscript = setDisplayMethod(alt_stimscript,2,do);

s.stimscript = alt_stimscript;

