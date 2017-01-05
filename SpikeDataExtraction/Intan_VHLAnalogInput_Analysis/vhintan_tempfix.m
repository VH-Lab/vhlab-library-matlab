function vhintan_tempfix

d = dir('intan_st_*.txt');

intan2spike2_adjust = load('spike2time2intantime.txt','-ascii');

forward = 0;

for i=1:length(d),
	spiketimes = load(d(i).name,'-ascii');
	if forward,
		spiketimes = intan2spike2_adjust(2) * spiketimes  + intan2spike2_adjust(1);
	else,
		spiketimes = (spiketimes - intan2spike2_adjust(1))/intan2spike2_adjust(2);
	end;
	dlmwrite(d(i).name,spiketimes,'delimiter',' ','precision',15);
end;

