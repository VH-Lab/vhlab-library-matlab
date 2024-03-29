function [cksds] = cksdirstruct(pathname)

%  [CKSDS] = CKSDIRSTRUCT(PATHNAME)
%
%  Returns a CKSDIRSTRUCT object.  This class is intended to manage data
%  recorded from the Nelson lab at Brandeis University.  Our data are organized
%  into separate directories, with each directory containing one epoch of
%  recording.  Each such directory has a file called acq_params_out, which
%  contains information about the signals that were acquired during that epoch.
%
%  

warning('The CKSDIRSTRUCT object has been replaced by the DIRSTRUCT object. CKSDIRSTRUCT will be removed in a future release and this will become an error. Please edit your code or tell the author.');

pathname = fixpath(pathname); % add a '/' if necessary

if exist(pathname)~=7, error(['''' pathname ''' does not exist.']); end;
   % build list
  % create some empty structs
nameref_str = struct('name','','ref',0,'listofdirs',{});
dir_str     = struct('dirname','','listofnamerefs',{});
dir_list    = {};
nameref_list= struct('name',{},'ref',{}); % create empty
extractor_list = struct('name',{},'ref',{},'extractor1','','extractor2','');
autoextractor_list = struct('type',{},'extractor1',{},'extractor2',{});
active_dir_list = {};

S = struct('pathname',pathname);
S.nameref_str = nameref_str;
S.dir_str = dir_str;
S.nameref_list = nameref_list;
S.dir_list = dir_list;
S.extractor_list = extractor_list;
S.autoextractor_list = autoextractor_list;
S.active_dir_list={};
cksds = class(S,'cksdirstruct');

cksds = update(cksds);
