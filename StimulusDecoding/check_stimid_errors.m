function bits = check_stimid_errors(stimids)
% CHECK_STIMID_ERRORS - check bits that might correlate with stimid glitches
%
% BITS = CHECK_STIMID_ERRORS(STIMIDS)
%

bits = zeros(8,1);
N = 0;

for i=1:numel(stimids),
	if i~=numel(stimids),
		if stimids(i+1)==255, % glitch
			stimbits = dec2bin(stimids(i),8);
			for j=1:numel(stimbits),
				bits(j) = bits(j) + str2num(stimbits(j));
			end;
		end;
	end;
end;
