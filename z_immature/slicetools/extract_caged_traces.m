function trace = extract_caged_traces(abffile,  analysis_window, baseline_window)

[data,h,s] = import_abf(abffile,1,1);

numEpisodes = h.lActualEpisodes;
dt = h.fADCSampleInterval;

trace = extract_episode(abffile,1,dt,analysis_window,baseline_window);

if ~isempty(trace),
	for i=2:numEpisodes,
		trace(end+1) = extract_episode(abffile,i,dt,analysis_window,baseline_window);
	end;
end;

function trace = extract_episode(abffile,i,dt,analysis_window,baseline_window);

[data,h,s] = import_abf(abffile,i,dt);

 % extract position_label

if length(unique(h.sFileComment))<=2, trace = []; return; end;  % file must have comment

ind = findstr('#',char(h.sFileComment'));
trace.position_label = str2num(char(h.sFileComment(ind+1:end))');

trace.position = get_stim_position(abffile, trace.position_label); 
trace.condition = get_slice_condition(abffile);

 % extract Vh

inds = findstr('mV',char(h.sFileComment')); % assume 3 occurrences

Vh0 = str2num( char(h.sFileComment(inds(1)-3:inds(1)-1)') )/1000; % use volts
Vh1 = str2num( char(h.sFileComment(inds(2)-3:inds(2)-1)') )/1000;
Vhs = str2num( char(h.sFileComment(inds(3)-3:inds(3)-1)') )/1000;



myVhs = Vh0:Vhs:Vh1;
if myVhs(end)~=Vh1,
	myVhs(end+1) = Vh1;
	warning(['Voltage steps do not evenly indicate Voltage bounds in comment:' mat2str([Vh0 Vhs Vh1])]);
end;

trace.Vh = myVhs(i);

trace.Ih = 0;

trace.T = data(:,1) * 1e-6 * (h.lNumSamplesPerEpisode)/(h.lFinishDisplayNum-h.lStartDisplayNum);
trace.laser_data = data(:,3);
trace.data  = data(:,2);

trace.analysis_window = analysis_window;
trace.baseline_window = baseline_window;

[trace.laser_t,trace.laser_duration,trace.baseline,trace.tpeakPSE,trace.peakPSE,trace.totPSE] = ...
  analyze_caged_PSE(trace.T,trace.laser_data,trace.data,trace.analysis_window,trace.baseline_window,trace.Vh>-0.045);

