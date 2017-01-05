function vhlv_tempfix

d = dir('lv_st_*.txt');

lv2spike2_adjust = load('spike2time2labviewtime.txt','-ascii');

forward = 0;

for i=1:length(d),
	spiketimes = load(d(i).name,'-ascii');
	if forward,
		spiketimes = lv2spike2_adjust(2) * spiketimes  + lv2spike2_adjust(1);
	else,
		spiketimes = (spiketimes - lv2spike2_adjust(1))/lv2spike2_adjust(2);
	end;
	dlmwrite(d(i).name,spiketimes,'delimiter',' ','precision',15);
end;
