function csd_SGSBL_extract_lfp(dirname, varargin)
% CSD_SGSBL_EXTRACT_LFP - Extract local field potentials from responses to STOCHASTICGRIDSTIM or BLINKINGSTIM
%
%   
%  The user can modify this function by passing additional parameters as name/value pairs:
%  Parameter (default)              | Description
%  ---------------------------------------------------------------------------------------
%  filename ('LFPs.mat')            | Filename where extracted LFPs are stored
%  channels (2:32)                  | Channel numbers to be extracted (channels are in the .vld file)
%  T0 (-0.100)                      | Time to extract before each trigger
%  T1 (0.250)                       | Time to extract after each trigger
%  TRANS_FROM1 *                    | Transitions to look for in 1 direction; this is from OFF
%                                   |   (black or gray) to ON (white) or black to gray
%                                   |    
%  TRANS_TO1   *                    |
%                                   |  
%  TRANS_FROM2 *                    | Transitions to look for in 2nd direction; this is from ON
%                                   |   (white) to OFF (black or gray) or gray to black
%                                   |    
%  TRANS_TO2   *                    |
%  Notch_Filter (1)                 | Notch filter to remove 60Hz noise?
%  LFP_SampleRate (600)             | Sample rate of the LFPs (Cheby1 Filter); use at least
%                                   |   twice the rate of the frequencies you want to capture
%  ColorTolerance (2)               | Color tolerance for transition matches
%  UseWaitBar (1)                   | Show progress bar
%                                   |  
%
%  *By default: TRANS_FROM1 = { [0 0 0; 128 128 128] , [0 0 0] }
%  *By default: TRANS_TO1 =   { [255 255 255] , [128 128 128]  }
%  *By default: TRANS_FROM2 = { [255 255 255 ] , [128 128 128] }
%  *By default: TRANS_TO2 =   { [0 0 0; 128 128 128] , [0 0 0] }
%

filename = 'LFPs.mat';
channels = 2:32;
T0 = -0.250;
T1 = 0.450;
TRANS_FROM1 = { [0 0 0; 128 128 128] , [0 0 0] };
TRANS_TO1 =   { [255 255 255] , [128 128 128]  };
TRANS_FROM2 = { [255 255 255 ] , [128 128 128] };
TRANS_TO2 =   { [0 0 0; 128 128 128] , [0 0 0] };
Notch_Filter = 1;
LFP_SampleRate = 300;
ColorTolerance = 2;
UseWaitBar = 1;

assign(varargin{:});

  % step 1 - find the times of all of these transitions

T_ON = findtransitionsSGSBL(dirname,TRANS_FROM1{1},TRANS_TO1{1},'ColorTolerance');
for i=2:length(TRANS_FROM1),
	T__ = findtransitionsSGSBL(dirname,TRANS_FROM1{i},TRANS_TO1{i},'ColorTolerance',ColorTolerance);
	for j=1:length(T_ON),
		T_ON{j} = sort([T_ON{j}(:); T__{j}(:);]);
	end;
end;

T_OFF = findtransitionsSGSBL(dirname,TRANS_FROM2{1},TRANS_TO2{1},'ColorTolerance',ColorTolerance);
for i=2:length(TRANS_FROM2),
	T_ = findtransitionsSGSBL(dirname,TRANS_FROM2{i},TRANS_TO2{i},'ColorTolerance',ColorTolerance);
	for j=1:length(T_OFF),
		T_OFF{j} = sort([T_OFF{j}(:); T_{j}(:);]);
	end;
end;

params = var2struct('filename','channels','T0','T1','TRANS_FROM1','TRANS_TO1','TRANS_FROM2','TRANS_TO2','Notch_Filter','LFP_SampleRate','ColorTolerance');

if exist([dirname filesep filename]),
	oldparams = load([dirname filesep filename],'params','-mat');
	if eqlen(params,oldparams.params), 
		disp(['LFPs in ' dirname ' are up to date.']);
		return; % nothing more to do
	end;
end;

save([dirname filesep filename],'T_ON','T_OFF','params','-mat');

[shift,scale] = vhlv_sync2spike2(dirname);

header = readvhlvheaderfile([dirname filesep 'vhlvanaloginput.vlh']);

number_of_points = length(T_ON) + length(T_OFF);

if UseWaitBar,
	WB = waitbar(0/number_of_points,'Reading LFP data');
end;

 % filters

notch = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',55,'HalfPowerFrequency2',65, ...
               'DesignMethod','butter','SampleRate',header.SamplingRate);

[lowpass_b,lowpass_a] = cheby1(2,0.5,(LFP_SampleRate*0.5)/(2*header.SamplingRate),'low');
[highpass_b,highpass_a] = cheby1(2,0.5,(LFP_SampleRate*0.5)/(2*header.SamplingRate),'high');


[T,D] = readvhlvdatafile([dirname filesep 'vhlvanaloginput.vld'],header,channels(1),3*T1+T0,4*T1-1/header.SamplingRate);
number_of_samples = size(D,1);

T = T - (3*T1+T0) + T0;

t0 = findclosest(T,T0);
t_zero = findclosest(T,0);

T_lfpsamp = T(1):1/LFP_SampleRate:T(end);
samples_to_grab = interp1(T,1:length(T),T_lfpsamp,'nearest');

T = T(samples_to_grab);

D_on = cell(length(T_ON),1);
D_off = cell(length(T_OFF),1);

Noise_on = NaN(length(T_ON),size(D,2));
Noise_off = NaN(length(T_OFF),size(D,2));

for i=1:length(T_ON),
	D_on{i} = zeros(length(samples_to_grab),length(channels));
	Noise_here = [];
	for j=1:length(T_ON{i}),
		[T_,D] = readvhlvdatafile([dirname filesep 'vhlvanaloginput.vld'],header,channels,...
			(-shift+T_ON{i}(j)+T0)/scale,(-shift+T_ON{i}(j)+T1)/scale);
		for k=1:size(D,2),
			if Notch_Filter,
				D(:,k) = filtfilt(notch,double(D(:,k)));
			end;
			D(:,k) = filtfilt(lowpass_b,lowpass_a,double(D(:,k)));
			high = filtfilt(highpass_b,highpass_a,double(D(:,k)));
			Noise_here(j,k) = std(high(t0:t_zero));
		end;
		D_on{i} = D_on{i} + (1/length(T_ON{i})) * (D(samples_to_grab,:));
	end;
	Noise_on(i,1:size(D,2)) = mean(Noise_here);

	if UseWaitBar,
		waitbar( (i) / number_of_points, WB);
	end;

end;

for i=1:length(T_OFF),
	D_off{i} = zeros(length(samples_to_grab),length(channels));
	Noise_here = [];
	for j=1:length(T_OFF{i}),
		[T_,D] = readvhlvdatafile([dirname filesep 'vhlvanaloginput.vld'],header,channels,T_OFF{i}(j)+T0,T_OFF{i}(j)+T1);
		for k=1:size(D,2),
			if Notch_Filter,
				D(:,k) = filtfilt(notch,double(D(:,k)));
			end;
			D(:,k) = filtfilt(lowpass_b,lowpass_a,double(D(:,k)));
			high = filtfilt(highpass_b,highpass_a,double(D(:,k)));
			Noise_here(j,k) = std(high(t0:t_zero));
		end;
		D_off{i} = D_off{i} + (1/length(T_OFF{i})) * D(samples_to_grab,:);
	end;
	Noise_off(i,1:size(D,2)) = mean(Noise_here);

	if UseWaitBar,
		waitbar( (length(T_ON)+i) / number_of_points, WB);
	end;
end;

save([dirname filesep filename],'T_ON','T_OFF','params','D_on','D_off','T','Noise_on','Noise_off','-mat');

if UseWaitBar,
	close(WB);
end;

