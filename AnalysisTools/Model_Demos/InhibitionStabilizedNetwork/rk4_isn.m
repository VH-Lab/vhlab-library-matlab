function [t, yrk4] = rk4_isn(y,t0,dt,t1,I,W,n);
t=t0:dt:t1;
yrk4=[y zeros(length(y),length(t)-1)];
for i=2:length(t),
	y=yrk4(:,i-1);
	k1=dt*dydt_isn(y,I(:,i),W,n)/6;
	k2=dt*dydt_isn(y+k1/2,I(:,i),W,n)/3;
	k3=dt*dydt_isn(y+k2/2,I(:,i),W,n)/3;
	k4=dt*dydt_isn(y+k3,I(:,i),W,n)/6;
	yrk4(:,i)=y+k1+k2+k3+k4;
end;
