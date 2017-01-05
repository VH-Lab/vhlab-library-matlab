function write_interconnect_textfiles(dirname, out)
% WRITE_INTERCONNECT_TEXTFILES - Write interconnect text file info for a given directory
% 
%  WRITE_INTERCONNECT_TEXTFILES(DIRNAME, OUT) 
%
%  Inputs:
%  DIRNAME - The full path to the directory where the textfiles should be written
%  OUT - A structure with the following fields:
%  -------------------------------|-----------------------------
%  StimTrigger                    | Times of stimulus triggers
%  StimTriggerOFF                 | Off times of all stimuli
%  FrameTriggerRaw                | Times of all frame triggers (not divided by stimulus)
%  StimulusMonitorVerticalRefresh | Vertical refresh times
%  TwoPhotonFrameTrigger          | 2-photon frame trigger
%  StimCode                       | Stim codes for each stim trigger
%
%  If there is a field 'FrameTrigger', it is assumed that this is a cell list with frame
%  triggers divided by stimulus (see WRITE_STIMTIMES_TXT)
%
%  It writes the files 'stimtimes.txt','verticalblanking.txt','stimontimes.txt',
%  'twophotontimes.txt'
%
%  This function also writes an empty text file 'Intan_decoding_finished.txt'. This serves
%  to indicate that the program need not decode this directory again.
%

if ~isfield(out,'FrameTrigger'),
	out.FrameTrigger = frametimesraw2frametimes(out.FrameTriggerRaw,out.StimTrigger);
end;

fnames = {'stimtimes.txt','stimontimes.txt','verticalblanking.txt','twophotontimes.txt','Intan_decoding_finished.txt'};
for i=1:length(fnames), 
	if exist([dirname filesep fnames{i}],'file'),
		delete([dirname filesep fnames{i}]);
	end;
end;

write_stimtimes_txt(dirname,out.StimCode,out.StimTrigger,out.FrameTrigger);
write_stimtimes_txt(dirname,out.StimCode,out.StimTrigger);

if isfield(out,'TwoPhotonFrameTrigger'),
	dlmwrite([dirname filesep 'twophotontimes.txt'],out.TwoPhotonFrameTrigger,...
		'delimiter','\n','precision','%10.5f');
end;

if isfield(out,'StimulusMonitorVerticalRefresh'),
	dlmwrite([dirname filesep 'verticalblanking.txt'],out.StimulusMonitorVerticalRefresh,...
		'delimiter','\n','precision','%10.5f');
end;


 % now write an empty file indicating that our work is done
fid=fopen([dirname filesep 'Intan_decoding_finished.txt'],'wt');
fclose(fid);

