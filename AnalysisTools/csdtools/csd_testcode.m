

% must be in directory
load LFPs

testchan = 7;
testchan_LFP = testchan - 1;
testLoc = 3;

[T2,D] = readvhlvdatafile([dirname filesep 'vhlvanaloginput.vld'],[],testchan,0,Inf);

samps = -25000:25000;

myavg = [];

for i=1:length(T_ON{testLoc}),
	ti = findclosest(T2,T_ON{testLoc}(i));
	myavg(i,:) = D(samps+ti);
end;

figure;
plot(samps*1/25000,mean(myavg),'b');
hold on;
plot(T,D_on{testLoc}(:,testchan_LFP),'g');

figure;
plot(samps*1/25000,myavg,'b');
hold on;

