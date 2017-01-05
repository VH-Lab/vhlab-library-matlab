function [t, yrk4] = rk4(y,t0,dt,t1,I,W,n);
t=t0:dt:t1;
yrk4=[y zeros(length(y),length(t)-1)];
for i=2:length(t),
	y=yrk4(:,i-1);
	k1=dt*dydt_broadinhibition(y,I,W,n)/6;
	k2=dt*dydt_broadinhibition(y+k1/2,I,W,n)/3;
	k3=dt*dydt_broadinhibition(y+k2/2,I,W,n)/3;
	k4=dt*dydt_broadinhibition(y+k3,I,W,n)/6;
	yrk4(:,i)=y+k1+k2+k3+k4;
end;
