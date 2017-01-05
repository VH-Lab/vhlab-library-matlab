function [h,workspace] = csd_SGSBL_plot_lfp(dirname, gridnumber, ONorOFF, varargin)
% CSD_SGSBL_PLOT - Plot LFP responses from SGS or BL stim on current axes
%
%   [H,WORKSPACE] = CSD_SGSBL_PLOT_LFP(DIRNAME, GRIDNUMBER, ONorOFF)
%
%   Plots LFP responses on the current axes. The axes are cleared before plotting.
%   DIRNAME is the directory name to process (where the file 'LFPs.mat' is read).
%   GRIDNUMBER is the grid number of the STOCHASTICGRIDSTIM or BLINKINGSTIM to plot.
%   ONorOFF is a 1/0 value that indicates whether ON responses should be plotted (1)
%   or OFF responses (0).
%   The maximum deviation from the mean is examined for each channel, and signals
%   are normalized by twice the amount of the largest such deviation found across
%   channels. Further, signals are normalized by the median distance between electrode
%   pads so that each signal can be plotted with a y value offset equal to the channel
%   depth.
%
%   H is an array of Line handles that correspond to each line plotted (including any
%   scale bars).
%   WORKSPACE is a structure with the entire workspace of the function.
%
%   This function can be modified by passing name/value pairs:
%   Name (default value)               | Description
%   -------------------------------------------------------------------------
%   ClearAxes (1)                      | 0/1 Should we really clear the axes?
%   Color ([0 0 0])                    | Plot color (rgb values in 0..1)
%   ElectrodeMap ('MCS_A1Poly32_right')| Electrode map function
%   SubtractMedian (0)                 | 0/1 Should we subtract the median of the signal?
%   SubtractTimeRange([-0.05 0])       | Time range over which we should calculate the median.
%   PlotVoltageScaleBar (1)            | 0/1 Plot a scale bar (in Y) to indicate voltage.
%   VoltageScaleBarValue (0.1)         | Size of scale bar (in volts)
%   PlotTimeScaleBar (1)               | 0/1 Plot a scale bar (in X) to indicate time
%   TimeScaleBarValue (0.1)            | Size of scale bar (in time, seconds)
%   ScaleBarOrigin ([0 0])             | Scale bar origin (x (seconds), y (meters))
%   PlotTimeZeroLine (1)               | 0/1 Plot a thin black line at time = 0
%   NormalizeByNoise (0)               | 0/1 Normalize by average noise before the analysis
%                                      |       pulse time. This equalizes small differences in
%                                      |       electrode impedance
%

 % step 1 - set up variables

ClearAxes = 1;
Color = [0 0 0];
ElectrodeMap = 'MCS_A1Poly32_right';
SubtractMedian = 1;
SubtractTimeRange = [-0.050 0];
PlotVoltageScaleBar = 1;
VoltageScaleBarValue = 0.100; % 100 mV
PlotTimeScaleBar = 1;
TimeScaleBarValue = 0.1; % 100ms
ScaleBarOrigin = [0 0];
PlotTimeZeroLine = 1;
NormalizeByNoise = 0;

assign(varargin{:});
 
 % step 2 - load data, and transform so it conforms to electrode geometry

load([dirname filesep 'LFPs.mat']);

[number_of_samples,number_of_channels] = size(D_on{1});

channel_numbers = 1:number_of_channels;

electrode_pad_numbers = eval([ElectrodeMap '(''channel'',channel_numbers);']);
depths = (eval([ElectrodeMap '(''depth'',channel_numbers);']));
max_channels = (eval([ElectrodeMap '(''number of channels'');']));

depths_sorted = sort(depths);

median_delta_depth = median(diff(depths_sorted(find(~isnan(depths_sorted)))));

Data = NaN(number_of_samples,max_channels);
Noise_values = NaN(size(Noise_on,1), max_channels);

channel_depths = [];

if ONorOFF,
	for i=1:length(electrode_pad_numbers),
		if ~isnan(electrode_pad_numbers(i)),
			Data(:,electrode_pad_numbers(i)) = D_on{gridnumber}(:,channel_numbers(i));
			Noise_values(:,electrode_pad_numbers(i)) = Noise_on(:,channel_numbers(i));
			channel_depths(electrode_pad_numbers(i)) = depths(channel_numbers(i));
		end;
	end;
else,
	for i=1:length(electrode_pad_numbers),
		if ~isnan(electrode_pad_numbers(i)),
			Data(:,electrode_pad_numbers(i)) = D_off{gridnumber}(:,channel_numbers(i));
			Noise_values(:,electrode_pad_numbers(i)) = Noise_off(:,channel_numbers(i));
			channel_depths(electrode_pad_numbers(i)) = depths(channel_numbers(i));
		end;
	end;
end;

 % step 3 - remove baseline, if requested

if SubtractMedian,
	s0 = findclosest(T,SubtractTimeRange(1));
	s1 = findclosest(T,SubtractTimeRange(2));

	for i=1:size(Data,2),
		Data(:,i) = Data(:,i) - median(Data(s0:s1,i));	
	end;
end;

 % step 4 - plot the data

 % step 4a - normalize for noise

if NormalizeByNoise,
	noises = [];
	for i=1:size(Data,2),
		noises(end+1) = mean(Noise_values(:,i));
	end;
	true_noise_estimate = nanmedian(noises);

	for i=1:size(Data,2),
		Data(:,i) = Data(:,i) * true_noise_estimate / noises(i);
	end;
end;

 % step 4b - find how the data deviates around its mean 

max_deviation = 0;
for i=1:size(Data,2),
	deviation_here = max(abs(Data(:,i)-mean(Data(:,i))));
	max_deviation = max(max_deviation,deviation_here);
end;

 % step 4c - normalize the data so that 2*max_deviation is equal to median electrode spacing in space

Data = median_delta_depth * Data/(2*max_deviation);

 % step 4d - actually plot the data

if ClearAxes,
	cla;
end;

h = [];
for i=1:size(Data,2),
	h(end+1) = plot(T,Data(:,i)+channel_depths(i),'color',Color);
	hold on;
end;
box off;

if PlotVoltageScaleBar,
	hold on;
	h(end+1) = plot(ScaleBarOrigin(1)+[0 0],...
			ScaleBarOrigin(2)+[0 median_delta_depth*VoltageScaleBarValue/(2*max_deviation)],...
			'linewidth',2,'color',[0 0 0]);
end;

if PlotTimeScaleBar,
	hold on;
	h(end+1) = plot(ScaleBarOrigin(1)+[0 TimeScaleBarValue],...
			ScaleBarOrigin(2)+[0 0], ...
			'linewidth',2,'color',[0 0 0]);
end;

if PlotTimeZeroLine,
	hold on;
	h(end+1) = plot([0 0],[min(depths)-median_delta_depth max(channel_depths)+median_delta_depth],...
		'linewidth',1,'color',[0 0 0]);
end;

axis([T(1) T(end) min(depths)-median_delta_depth max(channel_depths)+median_delta_depth]);

if nargin>1,
	workspace = workspace2struct;
end;

