function importspikedata(ds, nameref)
% IMPORTSPIKEDATA - Import spike data into a DIRSTRUCT experiment.mat record
%
%  IMPORTSPIKEDATA(DS)
%
%  Imports all spike available spike data to the experiment.mat file in
%  the directory managed by the DIRSTRUCT DS.  Spikes are imported
%  from all known acquisition and data processing environments.
%
%  Also can be called as:
%
%  IMPORTSPIKEDATA(DS, NAMEREFS)
%
%  where NAMEREFS(i) is a structure with fields NAME and REF. In this case,
%  only spikes from records with a given NAME and REF present in the associated
%  reference.txt file will be imported.

global importspikedata__lastupdate

 % only do this if it has been more than 5 seconds since it was last run

if ~isempty(importspikedata__lastupdate),
	[Y,MO,D,H,MI,S] = datevec(now-importspikedata__lastupdate);
	if any([Y MO D H MI]) | S>5,
		A = 1;  % go 
	else,
		A = 0;  % don't go
	end;
else,
	A = 1;
end;

if ~A,
	disp('too soon');
	return; % it's been too soon
end;

    % maybe down the road it can figure this out from the directory contents
importers_we_know = {'vhspike2_importcells','vhlv_importcells','vhintan_importcells','vhplexsp2_importcells','vhplexLV_importcells','vhwillow_importcells';};

for i=1:length(importers_we_know),
	disp(['Importing from ' importers_we_know{i} '...']);
	if nargin>1,
		eval([importers_we_know{i} '(ds,nameref);']);
	else,
		eval([importers_we_know{i} '(ds);']);
	end;
end;

importspikedata__lastupdate = now;

