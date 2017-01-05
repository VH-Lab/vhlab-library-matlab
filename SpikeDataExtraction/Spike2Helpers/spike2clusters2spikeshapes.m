function [spikeshapes, electrodeid, clusterid, time] = spike2clusters2spikeshapes(dirname, spikechans, timeoffset, samples)
% SPIKE2CLUSTERS2SPIKESHAPES - extracts spike waveforms from VHTOOLS spike2 data files
%
%   [SPIKESHAPES,ELECTRODEID,CLUSTERID,TIME] = SPIKE2CLUSTERS2SPIKESHAPES(DIRNAME, SPIKECHANS, TIMEOFFSET, SAMPLES)
%
%  Given a directory name DIRNAME and a spike channel numbers SPIKECHANS, this 
%  function pulls out all spike clusters that were identified by Spike2, opens the data file
%  'spike2data.smr', and reads the spike waveforms.
%
%  Inputs:
%     DIRNAME                 -  The name (full path) of the directory that should contain the following files:
%       spike2data.smr             - the spike2 record with raw data
%       spiketimes_N_00M.txt       - files that have spike times for each electrode N and each
%                                           spike and each cluster M
%     SPIKECHANS              -  A cell list of the spike channels to use; the first should 
%                                   contain all channels that comprise the first wavemark; 
%                                   e.g., SPIKECHANS{1} = [ 1 ] if the recording is a single
%                                   channel with the spike channel as channel 1.
%     TIMEOFFSET              -  A constant time offset that is applied to the spike times. This is
%                                   useful because spike2 reports the spike time as the time of the
%                                   beginning of its recording of the waveform rather than the peak time.
%     SAMPLES                 - The number of samples to return around each spike (before and after; the
%                     total samples returned will be 2*SAMPLES+1)
%
%   Outputs: SPIKESHAPES      - A cell list of An Nx2*SAMPLES+1 matrix of spike shapes; each row is
%                                   a different spikeshape; each element of the cell corresponds to a 
%                                   different wavemark codes
%            ELECTRODEID      - The wavemark codes corresponding to each of the wavemark codes
%            CLUSTERID        - A cell list with the cluster ID corresponding to each of the N spikes.
%            TIMES            - A cell list with the time record (centered on the spiketime) of the points
%                                   in SPIKESHAPES.
%                                   

d = dir([dirname filesep 'spiketimes_*_*.txt']);
time = [];

spikeshapes = {};
electrodeid = [];
clusterid = {};
times = {};

  % read in the spike times from every electrode

for i=1:length(d),
	z=load([dirname filesep d(i).name],'-ascii');
	%d(i).name,
	vals = sscanf(d(i).name,'spiketimes_%d_%d.txt');
	if length(vals)==1, vals(2) = 997; end; % should never happen anymore
	spikechan_index = vals(1)+1; % go from 0 .. n-1 indexing to 1 .. n indexing

	e_ind = find(electrodeid == vals(1));
	if isempty(e_ind), % first time we are here
		electrodeid(end+1) = vals(1);
		e_ind = length(electrodeid);
		spikeshapes{e_ind} = [];
		clusterid{e_ind} = [];
		times{e_ind} = [];
	end;

	times{e_ind} = cat(2,times{e_ind},z(:)');
	clusterid{e_ind} = cat(2,clusterid{e_ind},vals(2)*ones(1,length(z)));
end;

for i=1:length(electrodeid),
	e_ind = i;
	[time_ordered,index_ordered] = sort(times{e_ind}); % sort spikes by time so reading is faster
	times{e_ind} = times{e_ind}(index_ordered);
	clusterid{e_ind} = clusterid{e_ind}(index_ordered);

	myshapes = [];

	for k = 1:length(spikechans{e_ind}),
		ss = read_spike2_spikeshapes([dirname filesep 'spike2data.smr'], spikechans{e_ind}(k), times{e_ind}+timeoffset, samples);
		myshapes = cat(3,myshapes,ss);
	end;

	spikeshapes{e_ind} = myshapes;
end;
