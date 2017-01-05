function mystruct=associates2struct(md, initial_struct_list)
% ASSOCIATES2STRUCT - Convert associates to Matlab structure 
%
%  MYSTRUCT = ASSOCIATES2STUCT(MD, [INITIAL_STRUCT_LIST])
%
%  Converts a list of associates of the measureddata object MD
%  to a Matlab structure type.
%
%  Sometimes it is useful to work with a Matlab structure instead of
%  the associates list.  This function performs the conversion.
%
%  Each associate has the fields:
%          associate(i).type    - the type, a string
%          associate(i).owner   - the owner, a string
%          associate(i).data    - the data, arbitrary
%          associate(i).desc    - a description, a string
% 
%  The new structure will be created with fields with the
%  same name as the associate type such that 
%          mystruct.associate(i).type = associate(i).data
%
%  The associate type will be converted so that it is a legal
%  field name; spaces and '-' will be replaced with '_' and 
%  leading numbers will be led with an 'A'.
%
%  If the user provides an existing structure in 
%  INITIAL_STRUCTURE_LIST, then the associate types are added
%  to that structure.
%
%  See also: ASSOCIATESSUBSET2STRUCT
%
%  Example:
%
%      md = measureddata([0 1],'','')
%      md = associate(md,'My type','My owner','My data','My desc');
%      mystruct = associates2struct(md) 
%
%  Example 2:  Convert a whole list of cells to structures with the same field names:
%
%      (run Example 1 first)
%      md2 = measureddata([0 1],'','')
%      md2 = associate(md2,'My other type','My other owner','My other data','My other desc');
%      mdlist = {md md2 md md2};
%      mystruct = [];
%      for i=1:length(mdlist),
%         mystruct = associates2struct(mdlist{i},mystruct);
%      end;
%
%  Contributed by Gordon Smith 2012

if nargin>1,
	in = initial_struct_list;
else,
	in = [];
end;

ass=md.associates;
assn=cell(length(ass),1);
[assn{:}]=ass.type;
assn=cellfun(@(x) strrep(x,' ','_'),assn,'UniformOutput',false); % fix unallowable characters in fieldnames
assn=cellfun(@(x) strrep(x,'-','_'),assn,'UniformOutput',false);

mystruct=in;
index = length(in);

for i=1:length(assn)
	if assn{i}(1)>=48&assn{i}(1)<=58,
		assn{i} = ['A' assn{i}];
	end;
	mystruct(index+1).(assn{i})=ass(i).data;
end
