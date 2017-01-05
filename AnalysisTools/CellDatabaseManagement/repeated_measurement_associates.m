function n = repeated_measurement_associates(cell, associatename, nmax)
% REPEATED_MEASUREMENT_ASSOCIATE - Find all instances of a repeated measurement associate
%
%  N = REPEATED_MEASUREMENT_ASSOCIATES(CELL, ASSOCIATENAME, NMAX)
%
%  Searches the associates of the MEASUREDDATA object CELL for occurances of
%  ASSOCIATENAME string. The ASSOCIATENAME sting should have a '%d' where different
%  numbers can occur.
%
%  By default, this function will look for occurrences from 0 up to NMAX.
%
%  N is an array containing all numbers that match.
%
%  Example:
%    [cells,cellnames]=load2celllist(getexperimentfile(dirstruct(PATHNAME)),'cell*','-mat');
%    associatename = 'SP F0 TFOP%d TF Response curve';
%    n = repeated_measurement_associate(cells{1},associatename,10);
%    % if there is a TFOP1 and TFOP2 then n = [1 2]
%   
%  See also: MEASUREDDATA, FINDASSOCIATE, ASSOCIATE

n = [];

for i=0:nmax,
	if ~isempty(findassociate(cell,sprintf(associatename,i),'','')),
		n(end+1) = i;
	end;
end;

