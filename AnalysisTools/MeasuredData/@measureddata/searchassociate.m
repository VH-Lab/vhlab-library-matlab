function [a,i,typetokenlist,ownertokenlist,desctokenlist] = searchassociate(md,type,owner,description)
%  Search associate type, owner, and description using regular expressions
%
%  NOTE: If you just want to find exact matches for associates, the function 
%  you want is FINDASSOCIATE
%
%  [A,I,TYPETOKENS,OWNERTOKENS,DESCTOKENS] = SEARCHASSOCIATE(MD,TYPE_STRING,...
%     OWNER_STRING, DESCRIPTION_STRING);

%     Searches associates of MEASUREDDATA object MD to find those that match
%   regular expressions for the type, owner, and description that match
%  TYPE_STRING, OWNER_STRING, DESCRIPTION_STRING specified.
%  It will only return in A associates which match all of the criteria.  To
%  indicate that a field is not to be searched, set the value to
%  empty.  I returns the indexes of the associates.  The associates are sorted in
%  alphabetical order according to their TYPE.
%
%  TYPETOKENS return all of the matches of the search expression for the TYPE
%  field, OWNERTOKENS returns all of the matches of the search
%  expression for the OWNER field, and DESCRIPTION_STRING returns all of the
%  matches for the DESCRIPTION field.
%
%  Example:
%      [A,I,typetokens] = searchassociate(mycell,'Eyes (.*)','','')
%      % will return all associates that start with 'Eyes '
%      % if there is an associate called 'Eyes open', then A will be that
%      % associate, I will be the corresponding associate index, and
%      % typetokens will be equal to {'open'}
%      
%
%  See also: MEASUREDDATA, ASSOCIATE, FINDASSOCIATE, REGEXP

  % fix to allow full wildcards

if ~isempty(type)&~strcmp(class(type),'char'),error('type must be string.');end;
if ~isempty(description)&~strcmp(class(description),'char'),
	error('description must be string.');
end;
if ~isempty(owner)&~strcmp(class(owner),'char'),
	error('owner must be string.');
end;

i = [];

typelist = {};
typetokenlist = {};
ownerlist = {};
ownertokenlist = {};
desclist = {};
desctokenlist = {};

for j=1:numassociates(md),
	a = getassociate(md,j);

	% do we match type??
	A = isempty(type);
	type_token_here = {''};
	owner_token_here = {''};
	desc_token_here = {''};

	if ~A, % then we have to check
		[type_token_here,type_match_here] = regexp(a.type,type,'tokens');
		A = type_match_here;
	end;
	if A,	
		% if we might have a match, continue on to description
		B = isempty(description);
		if ~B,
			[desc_token_here,desc_match_here] = regexp(a.desc,desc,'tokens');
			B = desc_match_here;
		end;
		if B,
			C = isempty(owner);
			if ~C,
				[owner_tokens_here,owner_match_here] = regexp(a.owner,owner,'tokens');
				C = owner_match_here;
			end;

			if C, % we have a total match, so add it, record names and tokens
				i(length(i)+1) = j;
				typelist{end+1} = a.type;
				desclist{end+1} = a.desc;
				ownerlist{end+1} = a.owner;
				typetokenlist(end+1) = type_token_here;
				desctokenlist(end+1) = desc_token_here;
				ownertokenlist(end+1) = owner_token_here;
			end;
		end;
	end;
end;

if length(i)>1,
	[newlist,neworder] = sort(typelist);
	i = i(neworder);
	%typelist = typelist(neworder);  % don't run since output not used
	%desctokenlist = desctokenlist(neworder);  % don't run since output not used
	%ownerlist = ownerlist(neworder);  % don't run since output not used
	typetokenlist = typetokenlist(neworder);
	desctokenlist = desctokenlist(neworder);
	ownertokenlist = ownertokenlist(neworder);
end;

a = getassociate(md,i);

