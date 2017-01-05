function [cells,cellnames] = addassociatedata2experdir(dirname, assoc, saveit, penetration_assoc, penetration_number)

% ADDASSOCIATEDATA2EXPERDIR - Add an associate information to an experiment
%
%   [CELLS,CELLNAMES]=ADDASSOCIATEDATA2EXPERDIR(DIRNAME,ASSOCIATE, SAVEIT)
%
%   Adds associate data to cells in an experiment, restricting to a particular
%   penetration if necessary.
%
%   DIRNAME should be a directory name of an experiment that confirms to
%   the DIRSTRUCT organization.
%
%   ASSOCIATE should be the associate structure to add (see 'help ASSOCIATE')
%
%   If SAVEIT is 1, then the changes are saved to disk.  If SAVEIT is 0, the
%   changes are applied to the list of cell data in CELLS that is returned.
%
%   This function returns all cells and cellnames in the experiment in CELLS
%   and CELLNAMES.
%
%   One can also restrict the assignment of the associate to particular
%   penetrations:
%   
%      ... = ADDASSOCIATEDATA2EXPERDIR(DIRNAME,BORDERDEPTHS,SAVEIT,...
%                PENETRATION_ASSOC, PENETRATION_NUMBER)
%
%   If PENETRATION_ASSOC is empty (that is, []) then the associate name
%   'penetration' will be used.
%
%   See also:  ASSOCIATE, FINDASSOCIATE
%

p_assoc = ''; p_num = 0;

if nargin > 3,
	if nargin < 5,
		error(['If a penetration associate name is specified, then a penetration number must also be specified.']);
	end;
	p_assoc = penetration_assoc;
	if isempty(p_assoc), penetration_assoc = 'penetration'; end;
	p_num = penetration_number;
end;

ds = dirstruct(dirname);

[cells,cellnames] = load2celllist(getexperimentfile(ds),'cell*','-mat');

if isempty(p_assoc),
	warning(['No penetration specified; we will be adding the associate to all cells indiscriminately.']);
end;

for j=1:length(cells),
	if ~isempty(p_assoc),
		p = findassociate(cells{j},p_assoc,'','');
		if ~isempty(p),
			if p.data==p_num,
				[b,i] = findassociate(cells{j},assoc.type,'','');
				if ~isempty(b), cells{j} = disassociate(cells{j},i); end;
				cells{j} = associate(cells{j},assoc);
			end;
        end;
	else, % we will add it regardless of the penetration number
		[b,i] = findassociate(cells{j},assoc.type,'','');
		if ~isempty(b), cells{j} = disassociate(cells{j},i); end;
		cells{j} = associate(cells{j},assoc);
	end;
end;

if saveit,
	saveexpvar(ds,cells,cellnames);
end;

