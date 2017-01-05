function [h,workspace] = csd_SGSBL_plot_csd(dirname, gridnumber, ONorOFF, varargin)
% CSD_SGSBL_PLOT - Plot CSD responses from SGS or BL stim on current axes
%
%   [H,WORKSPACE] = CSD_SGSBL_PLOT_CSD(DIRNAME, GRIDNUMBER, ONorOFF)
%
%   Plots CSD responses on the current axes. The axes are cleared before plotting.
%   DIRNAME is the directory name to process (where the file 'LFP.mat' is read).
%   GRIDNUMBER is the grid number of the STOCHASTICGRIDSTIM or BLINKINGSTIM to plot.
%   ONorOFF is a 1/0 value that indicates whether ON responses should be plotted (1)
%   or OFF responses (0).
%
%   This function assumes the electrode is a linear array with constant distance between
%   the pads (the median distance between pads is taken to be the distance between any
%   neighboring pads).
%
%   H is an array of Line handles that correspond to each line plotted (including any
%   scale bars).
%   WORKSPACE is a structure with the entire workspace of the function.
%
%   This function can be modified by passing name/value pairs:
%   Name (default value)                  | Description
%   -------------------------------------------------------------------------
%   ClearAxes (1)                         | 0/1 Should we really clear the axes?
%   Color ([0 0 0])                       | Plot color (rgb values in 0..1)
%   ElectrodeMap ('MCS_A1Poly32_right')   | Electrode map function
%   SubtractMedian (1)                    | 0/1 Should we subtract the median of the LFP signal?
%   SubtractTimeRange([-0.05 0])          | Time range over which we should calculate the median.
%   ShadeColor ([0 0 0])                  | Color for shading points below the 0 line (NaN for none)
%   
%
%   Note: This function depends on CSD_SGSBL_PLOT_LFP

 % step 1 - set up variables

ClearAxes = 1;
Color = [0 0 0];
ElectrodeMap = 'MCS_A1Poly32_right';
SubtractMedian = 1;
SubtractTimeRange = [-0.050 0];
ShadeColor = [0 0 0];

assign(varargin{:});
 
 % step 2 - load LFP data, and transform so it conforms to electrode geometry
 %  call csd_SGSBL_plot_lfp for this purpose

[h,lfp_workspace]=csd_SGSBL_plot_lfp(dirname,gridnumber,ONorOFF,varargin{:});
delete(h); 

 % step 3 - compute csd

  % un-normalize the LFP data
Data = lfp_workspace.Data * (2*lfp_workspace.max_deviation) / lfp_workspace.median_delta_depth;
csd_data = NaN(size(Data));
for i=2:size(Data,2)-1,
	csd_data(:,i) = (Data(:,i-1)+Data(:,i+1)-2*Data(:,i)) / (lfp_workspace.median_delta_depth^2);
end;

 % step 4 - plot the data

 % normalize the CSD data

max_deviation = 0;
for i=1:size(Data,2),
	deviation_here = max(abs(csd_data(:,i)-mean(csd_data(:,i))));
	max_deviation = max(max_deviation,deviation_here);
end;

csd_data = csd_data * lfp_workspace.median_delta_depth / (2*max_deviation);

if ClearAxes,
	cla;
end;

h = [];
for i=1:size(csd_data,2),
	h(end+1) = plot(lfp_workspace.T,csd_data(:,i)+lfp_workspace.channel_depths(i),'color',Color);
	hold on;
	if ~all(isnan(ShadeColor)),
		h(end+1) = plotshade(lfp_workspace.T,csd_data(:,i)+lfp_workspace.channel_depths(i),lfp_workspace.channel_depths(i),ShadeColor);
	end;
end;
box off;

axis([lfp_workspace.T(1) lfp_workspace.T(end) ...
		min(lfp_workspace.depths)-lfp_workspace.median_delta_depth ...
		max(lfp_workspace.depths)+lfp_workspace.median_delta_depth]);

