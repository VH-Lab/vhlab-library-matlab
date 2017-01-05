function isn_demo(cmd)


  % ISN demo

if nargin==0, cmd = 'start'; end;

TDfig = 1;

% n is noise

t0=0;
dt=1e-4;
t1=1.0;

N=2;

n=0;
I2E=0; %I to E connections
E2I=0; 
E2E=0;
I2I=0; 


C=0.32;
e=0.1;
Ie=40*C;

times = t0:dt:t1;
halftime = findclosest(times,0.5*(t0+t1));
tenthofsecond = findclosest(times,0.1);

I_local = 40*C*ones(size(times));
I_local(1:tenthofsecond) = 0;
I_inhib = zeros(size(times));
I_inhib(halftime:end) = 0.5*I_local(halftime:end);

Ie = [ I_inhib + I_local ; I_local ]; 

if ishandle(TDfig),
	
	I2E = get(ft(TDfig,'I2E'),'value'),
	E2E = get(ft(TDfig,'E2E'),'value'),
	I2I = get(ft(TDfig,'I2I'),'value'),
	E2I = get(ft(TDfig,'E2I'),'value'),

	lgntuned = get(ft(TDfig,'LGNTunedCB'),'value');
	corticalfeedback = get(ft(TDfig,'CorticalFeedbackCB'),'value');
	noise = get(ft(TDfig,'NoiseCB'),'value');

	W=1./(N)*([I2I E2I; I2E E2E]/10);

end;


switch (cmd),
	case 'start',
		if ishandle(TDfig), close(TDfig); end;
		isn_demo_fig;
		axes(ft(TDfig,'LGNAxes'));
		set(gca,'fontweight','bold','fontsize',16);
		xlabel('Time','fontweight','bold','fontsize',16);
		ylabel('Inputs','fontsize',16,'fontweight','bold');
		%axes(ft(TDfig,'InputAxes'));
		%set(gca,'fontweight','bold','fontsize',16);
		ylabel('CTX Input','fontsize',16,'fontweight','bold');
		axes(ft(TDfig,'CTXAxes'));
		set(gca,'fontweight','bold','fontsize',16);
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');
		set(ft(TDfig,'E2Et'),'string',num2str(E2E));
		set(ft(TDfig,'I2Et'),'string',num2str(I2E));
		set(ft(TDfig,'E2It'),'string',num2str(E2I));
		set(ft(TDfig,'I2It'),'string',num2str(I2I));
		set(ft(TDfig,'E2E'),'value',E2E);
		set(ft(TDfig,'I2I'),'value',I2I);
		set(ft(TDfig,'E2I'),'value',E2I);
		set(ft(TDfig,'I2E'),'value',I2E);

	case 'Run',
		r=zeros(N,1);
		[t,r]=rk4_isn(r,t0,dt,t1,Ie,W,n);

		axes(ft(TDfig,'LGNAxes'));
		hold off;
		plot(t,Ie(1,:),'b','linewidth',2);
		hold on;
		plot(t,Ie(2,:),'r:','linewidth',2);
		set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
		xlabel('Time (s)','fontweight','bold','fontsize',16);
		ylabel('Inputs','fontsize',16,'fontweight','bold');
		A = axis;
		axis([t0 t1 0 A(4)]);
		box off;
		
		axes(ft(TDfig,'CTXAxes'));
		hold off;
		plot(t,r(1,:),'b','linewidth',2);
		hold on;
		plot(t,r(2,:),'r:','linewidth',2);		
		set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');
		A = axis;
		axis([t0 t1 0 A(4)]);
		box off;

end;


function h = ft(h1,st)  % shorthand
h = findobj(h1,'Tag',st);

