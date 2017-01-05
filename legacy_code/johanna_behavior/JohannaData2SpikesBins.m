function [spikes, timebins, EventTimes, numcells] = JohannaData2SpikeBins(filename, varargin)
% JOHANNADATA2SPIKEBINS - Convert from Johanna's spike and event data to categorized spiketrains
%
% [SPIKES_IN_BINS, TIMEBINS, EVENTTIMES, NUMCELLS]=JOHANNADATA2SPIKES(FILENAME)
%
% This converts data from Johanna's format and sorts the spikes into binary
% sequences of 0's and 1's with the temporal resolution specified below.
%
% INPUTS:
%
% The file in FILENMAE is assumed to be in .mat format and have the
% following variable types:
%    1) 'sig1a', 'sig1b', 'sib2a', ...  are spikes represented by 
%        timestamps. Each different 'sig**' variable represents the
%        spikes from a different cell. The number indicates the channel
%        number and unique letters indicate unique spike waveforms on
%        each channel. 
%    2) 'Spont','Noise','Grating','Movie' These are event timestamps
%        that indicate the time of particular events.
% 
% Default parameters can be overriden by passing additional arguments in
% the form of 'PARAM', 'VALUE':
%
% Parameter name (default) :  Description
% -----------------------------------------------------------------
% tRes (0.002)             :  Bin size in same time units as spike times
% EventNames {'Spont',...  :  Event names
%   'Noise','Grating',...
%   'Movie'}
% EventDuration {120,...   :  Event duration time of each event type listed
%    120,120,120} ...      :    in 'EventNames'; these times are in same
%                          :    time units as spiketimes
%                          
%                             
%
% OUTPUTS:
%  SPIKES is a cell array that is the same size as EventNames. SPIKES{1}
%  has the spike data that corresponds to EventNames{1}, for example. The
%  contents of each SPIKES element is a NUMCELLS x LENGTH(TIMEBINS) matrix
%  of 0's and 1's, where SPIKES{k}(i,j) indicates to whether or not there
%  is a spike for the kth from the ith cell in the jth time bin.
%  TIMEBINS is a cell array of the time bins for each event.
%  EVENTTIMES is a cell array that is the same size as EventNames. Each
%  element has a matrix of the onset and offset times for the events found.
%  Each row i contains the onset time and the offset times for the ith
%  occurrence of the event.  
%  NUMCELLS are the number of cells identified from the 'sig**' variables.
%  
%  See also: KL_Estimation


  % Step 0) Define default variable names
EventNames = {'Spont','Noise','Grating','Movie'};
EventDuration = {120, 120, 120, 120};
tRes = 0.002;

assign(varargin{:}); % assign any values the user might have specified

 % Step 1) Load in the file

z = load(filename,'-mat');

 % Step 2) Loop through all of the known events and find the times of
 %         occurrence

EventTimes = { [] [] [] [] };  % start with a blank list of event times
for i=1:length(EventNames),
    EventData = getfield(z,EventNames{i}); % get the data
      % this will make a matrix with a row for each occurrence of the 
      % stimuluation; the first column will be just the onset that
      % is given in EventData, and the second column will be that value
      % plus the EventDuration
    EventTimes{i} = [EventData(:) EventData(:)+EventDuration{i}];
end;

  % Step 3) Identify all of the spike channels

  % get all of the fieldnames of the variables in z
fn = fieldnames(z);
  % now search to see which ones begin with 'sig'
sigfields_truefalse = strncmp('sig',fn,3);
  % now store the fieldnames that match
sigfield_names = fn((sigfields_truefalse==1));
numcells = length(sigfield_names);

  % Step 4) Create the spikes binned in 0's and 1's

spikes = cell(1,length(EventNames)); % make empty cell
timebins = cell(1,length(EventNames)); % make empty cell

for i=1:length(EventNames),
    timebins{i} = 0:tRes:EventDuration{i};
    % get the start/stop times for each interval
    for j=1:size(EventTimes{i},1),
        onset = EventTimes{i}(j,1);
        offset = EventTimes{i}(j,2);
        spikes_thisevent = [];
        for k=1:length(sigfield_names),
            spiketimes_here = getfield(z,sigfield_names{k});
            % now select the subset of these spiketimes that occur during
            % our present event
            spiketimes_thisevent_indexes = find(spiketimes_here>=onset & spiketimes_here<=offset);
            spiketimes_thisevent = spiketimes_here(spiketimes_thisevent_indexes);
            % now convert to 0's and 1's
            spikebins_thiseventthiscell = spiketimes2bins(spiketimes_thisevent, onset+timebins{i});
            % set any bin with more than 1 spikes per bin to 1
            spikebins_thiseventthiscell(spikebins_thiseventthiscell>1) = 1;
            spikes_thisevent = cat(2,spikes_thisevent,spikebins_thiseventthiscell(:));
        end;
        spikes{i} = cat(1,spikes{i},spikes_thisevent);
    end;
end;

