function v = dydt(y,I,W,Ja)
T=0;tau=0.005;l=length(W); tau2=0.050;
v=[(-y(1:l)+max([zeros(l,1) I+W*y(1:l,:)-T-y(l+1:end,:)]')')/tau; (-y(l+1:end)+Ja*y(1:l,:))/tau2];
