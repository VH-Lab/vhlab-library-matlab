function output = stimlickanalysis(stimonset, stimduration, licktimes_noreward, licktimes_reward)
% STIMLICKANALYSIS - Calculate lick rates relative to a stimulus
%
%  OUTPUT = STIMLICKANALYSIS(STIMONSET, STIMDURATION, ...
%              LICKTIMES_NOREWARD, LICKTIMES_REWARD)
%
%  Given an array of stim onset times in STIMONSET and the stimulus
%  duration STIMDURATION, the times when the animal licked and was not
%  rewarded LICKTIMES_NOREWARD, and the times when the animal licked during
%  the stimlus presentation (LICKTIMES_REWARD), the function will calculate
%  the following fields of the structure OUTPUT.
%
%  OUTPUT field:
%  -----------------------------------------------------------------------------
%  lick_count_pre      | lick count in time STIMDURATION before each stim
%  lick_count_stim     | lick count during the stimulus
%  lick_count_post     | lick count during the time STIMDURATION after each stim
%  lick_count_stats    | mean, standard deviation, and standard error of lick counts
%  lick_rate_pre       | lick rate in time STIMDURATION before each stim
%  lick_rate_stim      | lick rate during the stimulus
%  lick_rate_post      | lick rate during the time STIMDURATION after each stim
%  lick_rate_stats     | mean, standard deviation, and standard error of lick rates

 % in the future, we will grab catch trials and remove them, but not now

output.lick_count_pre = [];
output.lick_count_stim = [];
output.lick_count_post = [];

output.lick_rate_pre = [];
output.lick_rate_stim = [];
output.lick_rate_post = [];

lick_times = sort([licktimes_noreward(:) ; licktimes_reward(:)]);  % we just need to know when the animal was licking

for i=1:length(stimonset),
	output.lick_count_pre(i) = length(find(lick_times>stimonset(i)-stimduration&lick_times<=stimonset(i)+0*stimduration));
	output.lick_count_stim(i) = length(find(lick_times>stimonset(i)-0*stimduration&lick_times<=stimonset(i)+1*stimduration));
	output.lick_count_post(i) = length(find(lick_times>stimonset(i)+stimduration&lick_times<=stimonset(i)+2*stimduration));
end;

output.lick_rate_pre = output.lick_count_pre / stimduration;
output.lick_rate_stim = output.lick_count_stim / stimduration;
output.lick_rate_post = output.lick_count_post / stimduration;

 % now calculate stats for both

output.lick_count_stats.pre_mean = mean(output.lick_count_pre);
output.lick_count_stats.pre_stddev = std(output.lick_count_pre);
output.lick_count_stats.pre_stderr = stderr(output.lick_count_pre);

output.lick_count_stats.stim_mean = mean(output.lick_count_stim);
output.lick_count_stats.stim_stddev = std(output.lick_count_stim);
output.lick_count_stats.stim_stderr = stderr(output.lick_count_stim);

output.lick_count_stats.post_mean = mean(output.lick_count_post);
output.lick_count_stats.post_stddev = std(output.lick_count_post);
output.lick_count_stats.post_stderr = stderr(output.lick_count_post);

output.lick_rate_stats.pre_mean = mean(output.lick_rate_pre);
output.lick_rate_stats.pre_stddev = std(output.lick_rate_pre);
output.lick_rate_stats.pre_stderr = stderr(output.lick_rate_pre);

output.lick_rate_stats.stim_mean = mean(output.lick_rate_stim);
output.lick_rate_stats.stim_stddev = std(output.lick_rate_stim);
output.lick_rate_stats.stim_stderr = stderr(output.lick_rate_stim);

output.lick_rate_stats.post_mean = mean(output.lick_rate_post);
output.lick_rate_stats.post_stddev = std(output.lick_rate_post);
output.lick_rate_stats.post_stderr = stderr(output.lick_rate_post);
