function [LFPmeans, CSDmeans,LFP,CSD] = lfp_csd_comp(pathname,channels,chanmap,gains,chan0,normalized,int1,int2,comps)

% LFP_CSD_COMP  Extracts LFP and CSD means and performs analysis computations
%
%  [LFPMEANS, CSDMEANS, LFP, CSD] = LFP_CSD(PATHNAME, CHANNELS, CHANMAP, NORMALIZE, [T0 T1], [TS0 TS1], COMPS)
%
%  Returns LFP and CSD waveforms for stimuli in directory PATHNAME.
%  CHANMAP can be 'flat' or 'umich16' to indicate channels should be
%  decoded according to map of the long linear University of Michigan
%  probes.  If NORMALIZE is 1, then LFPs and CSD's are
%  normalized to standard deviation of spontaneous activity.
%
%  Data are analyzed in the poststimulus interval [T0..T1].  Spontaneous
%  activity is assessed in the interval [TS0..TS1].
%
%  LFPMEANS is a (NUMBER OF STIMS)x(LENGTH(CHANNELS))x(LENGTH(T0..T1)) matrix
%  containing mean LFP waveforms for each stimulus and channel.
%  CSDMEANS is a (NUMBER OF STIMS)x(LENGTH(CHANNELS)-2)x(LENGTH(T0..T1)) matrix
%  containing mean CSD waveforms for each stimulus and channel.
%
%  LFP and CSD are LENGTH(CHANNELS)x1 and LENGTH(CHANNELS)-2x1 structs.
%  The structs will have the following elements by default and can have additional
%  elements if additional computations are performed.
%
%  spontmean - mean waveform from TS0 to TS1
%  spontstd - standard deviation of waveform from TS0 to TS1
%  mean - the mean waveform from T0 to T1.
%  std  - the standard deviation from T0 to T1
%  stderr - the standard error from T0 to T1
%  meanspont - mean waveform from TS0 to TS1
%  stdspont - the standard deviation from TS0 to TS1
%  meanstd - the mean standard deviation from TS0 to TS1
%  min - the minimum value of mean response in range T0..T1.
%  max - the maximum value of mean response in range T0..T1.
%  latencymin - the time of the minimum value
%  latencymax - the time of the maximum value
%  responsesmin - the individual data values at latency min time
%  responsesmax - the individual data values at latency max time
%  responses_ti - the individual data values at time ti 
%  normalized - 0/1 are data normalized?
%  T - the times of each sample in the waveforms
%
%  Optionally, one may provide additional computation functions
%  the struct array COMPS.  Each COMP struct should have the
%  following elements:
%
%    function       -   the name of the function
%    csd            -   0/1 should we call it for csd?
%    lfp            -   0/1 should we call it for lfp?
%    varargin       -   cell list of remaining arguments to the function
%                           (after the data and time indices),
%                       
%
%  The first argument to the function is a
%  [number of samples]x[number of stimulus repetitions+1]
%  matrix with the individual trial data samples.  The first column
%  contains sample times and subsequent columns contain each
%  individual trial.  The second argument is a list of time indices,
%  [t0ind t1ind ts0ind ts1ind] that contains the sample indices of
%  the sample number of T0 and T1 and TS0 and TS1.  The function
%  should return a struct and the entries of the struct will be
%  added to LFP and CSD.
%  
%
stimgood = 1;

probechanlist=[1 9 2 10 5 13 4 12 7 15 8 16 6 14 3 11];
probechanlist=probechanlist(end:-1:1);
if strcmp(chanmap,'umich16'), channels = probechanlist(channels-chan0+1)+chan0-2; end; % would be 1 instead of 2 if all channels recorded

t0 = int1(1); t1 = int1(2); ts0 = int2(1); ts1 = int2(2);

stim = 1;


while (stimgood==1),
	if exist([fixpath(pathname) 'stim' int2str(stim) ...
			'chan' int2str(channels(1)) '.dat'])==2,

		csdinc = 0;
		Lprepre = [];
		Lpre = [];
		for j=1:length(channels),
			fname=[fixpath(pathname) 'stim' int2str(stim) ...
				'chan' int2str(channels(j)) '.dat'],
			L = readLFPbinary(fname);

			if j==1&stim==1,  % find our indices
				ts0ind = findclosest(L(:,1),ts0);
				ts1ind = findclosest(L(:,1),ts1);
				t0ind = findclosest(L(:,1),t0);
				t1ind = findclosest(L(:,1),t1);
			end;

			tempLstruct.spontmean = mean(L(ts0ind:ts1ind,2:end)')';
			tempLstruct.spontstd = std(L(ts0ind:ts1ind,2:end)')';
			tempLstruct.meanstd = mean(tempLstruct.spontstd);
			if normalized,
				L(:,2:end) = L(:,2:end)/tempLstruct.meanstd;
			else, L(:,2:end) = L(:,2:end)./gains(j);
			end;
			tempLstruct.mean = mean(L(t0ind:t1ind,2:end)')';
			tempLstruct.std = std(L(t0ind:t1ind,2:end)')';
			tempLstruct.stderr = stderr(L(t0ind:t1ind,2:end)')';

			% find min/max responses and latencies

			[tempLstruct.mn,lat]=min(tempLstruct.mean);
			tempLstruct.responsesmin = L(t0ind+lat-1,2:end);
			tempLstruct.latencymin = L(t0ind+lat,1);
			[tempLstruct.mx,latmx]=max(tempLstruct.mean);
			tempLstruct.responsesmax = L(t0ind+latmx-1,2:end);
			tempLstruct.latencymx = L(t0ind+latmx,1);

			tempLstruct.T = L(t0ind:t1ind,1);
			tempLstruct.normalized = normalized;


			% perform comps
			for C = 1:length(comps),
				if comps(C).lfp,
					output=feval(comps(C).function,L,[t0ind t1ind ts0ind ts1ind],comps(C).varargin{:});
					fn = fieldnames(output);
					for f=1:length(fn),
						tempLstruct=setfield(tempLstruct,fn{f},getfield(output,fn{f}));
					end;
				end;
			end;

			% now finish

			LFPmeans(:,j,stim) = tempLstruct.mean;

			LFP(stim,j) = tempLstruct;

			Lcur = L;

			%now compute csd
			if ~isempty(Lprepre),
				disp(['Computing CSD.']);
				csdinc = csdinc + 1;
				C = Lcur(:,1);
				C = [C (Lprepre(:,2:end)+Lcur(:,2:end)-2*Lpre(:,2:end))/((100e-6)^2)];

				tempCstruct.spontmean = mean(C(ts0ind:ts1ind,2:end)')';
				tempCstruct.spontstd = std(C(ts0ind:ts1ind,2:end)')';
				tempCstruct.meanstd = mean(tempCstruct.spontstd);
				tempCstruct.mean = mean(C(t0ind:t1ind,2:end)')';
				tempCstruct.std = std(C(t0ind:t1ind,2:end)')';
				tempCstruct.stderr = stderr(C(t0ind:t1ind,2:end)')';

				[tempCstruct.min,latc]=min(tempCstruct.mean);
				tempCstruct.responsesmin = C(t0ind+lat-1,2:end);
				tempCstruct.latencymin = C(t0ind+lat,1);
				[tempCstruct.max,latmxc]=max(tempCstruct.mean);
				tempCstruct.responsesmax = C(t0ind+latmx-1,2:end);
				tempCstruct.latencymax = C(t0ind+latmx,1);

				tempCstruct.T = L(t0ind:t1ind,1);
				tempCstruct.normalized = normalized;

				% perform comps
				for Cc = 1:length(comps),
					if comps(Cc).csd,
						output=feval(comps(Cc).function,C,[t0ind t1ind ts0ind ts1ind],comps(Cc).varargin{:});
						fn = fieldnames(output);
						for f=1:length(fn),
							tempCstruct=setfield(tempCstruct,fn{f},getfield(output,fn{f}));
						end;
					end;
				end;

			% now finish


				CSDmeans(:,csdinc,stim) = tempCstruct.mean; 

				CSD(stim,csdinc) = tempCstruct;
			end;

			Lprepre = Lpre;
			Lpre = Lcur;

		end;
		stim = stim + 1;
	else,
		stimgood = 0; % stop looping
	end;
end;

