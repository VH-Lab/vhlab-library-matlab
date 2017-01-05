function s = associatessubset2struct(mdobject, varargin)
% ASSOCIATESSUBSET2STRUCT - Convert a subset of associates to a structure
%
%   S = ASSOCIATESSUBSET2STRUCT(MDOBJECT, ASSOCIATENAME1, ...
%            ASSOCIATENAME2, ...);
%
%  Converts a subset of the associates of a MEASUREDDATA object MDOBJECT to 
%  a Matlab structure. Only the named associates ASSOCIATENAME1,
%  ASSOCIATENAME2, etc., are converted, unless no associate names
%  are provided, in which case all are converted.
%
%  If MDOBJECT does not have an associate with the specified name,
%  then no entry in the structure is created.
%
%  See also: ASSOCIATES2STRUCT - Converts and removes associate fields such
%   as 'type','name','data',etc...

s = findassociate(mdobject,'','',''); % get them all

if length(varargin)>0,
	assoc_types = {s.type};
	[dummy,b] = intersect(assoc_types,varargin);
	s = s(b);
end;

