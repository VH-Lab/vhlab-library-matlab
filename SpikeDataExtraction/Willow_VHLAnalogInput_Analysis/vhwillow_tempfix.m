function vhwillow_tempfix

d = dir('willow_st_*.txt');

willow2spike2_adjust = load('spike2time2willowtime.txt','-ascii');

forward = 0;

for i=1:length(d),
	spiketimes = load(d(i).name,'-ascii');
	if forward,
		spiketimes = willow2spike2_adjust(2) * spiketimes  + willow2spike2_adjust(1);
	else,
		spiketimes = (spiketimes - willow2spike2_adjust(1))/willow2spike2_adjust(2);
	end;
	dlmwrite(d(i).name,spiketimes,'delimiter',' ','precision',15);
end;

