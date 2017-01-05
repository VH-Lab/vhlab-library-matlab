function [KL_matrix, h_matrix] = JohannaKL(spikes)
% JOHANNAKL - Compute KL estimation for Johanna's experiments
%
%  [KL_matrix, h_matrix] = JOHANNAKL(SPIKES_IN_BINS)
%
%  Given a cell array of SPIKES_IN_BINS that has the same length
%  as the number of stimulus conditions, this function returns
%  an estimate of the KL distance comparing the distributions of
%  spike data across all conditions.
%
%  Outputs:
%    KL_matrix(i,j) is the KL_distance between the spikes
%       in SPIKES_IN_BINS{i} and SPIKES_IN_BINS{j}.
%    H_matrix(i,j) is the entropy between the distributions.
%    Both of these values are returned by KL_Estimation.m.
%
%  See also: KL_Estimation
%

KL_matrix = [];
h_matrix = [];

 % Step 1) Translate spikes in bins to states


for i=1:length(spikes), 
	spikes_states{i} = spikes2states(spikes{i},size(spikes{i},2));
end;

for i=1:length(spikes),
	for j=1:length(spikes),
		if i~=j, % dont compute kl distance to self
			[KL_matrix(i,j),h_matrix(i,j)]=KL_Estimation(spikes_states{i},spikes_states{j},...
				1,1,1,1:size(spikes{i},2));
		end;
	end;
end;


