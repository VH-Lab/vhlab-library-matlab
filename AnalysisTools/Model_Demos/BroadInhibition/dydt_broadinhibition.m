function v = dydt_broadinhibition(y,I,W,n)
T=0;
tau=0.005;
l=length(W);
v=[(-y+max([zeros(l,1) I+n*randn(l,1)+W*y-T]')')/tau];
