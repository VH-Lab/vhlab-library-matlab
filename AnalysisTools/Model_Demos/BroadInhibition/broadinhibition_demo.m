function broadinhibition_demo(cmd)

if nargin==0, cmd = 'start'; end;

TDfig = 1;

% n is noise

t0=0;dt=1e-4;t1=0.10; N=50; theta = -pi/2:(pi/N):pi/2-pi/N;

n=0; J0=-7.3;J2=11; C=0.32;e=0.1; Ie=40*C*(1-e+e*cos(2*(theta)))';
W=1./(N)*((J0+J2*cos(2*((cumsum(repmat(pi/N,N,N))'+repmat(((pi/2-2*pi/N):-(pi/N):(-pi/2-pi/N))',1,N))+pi/2+pi/N))));

if ishandle(TDfig),
	lgntuned = get(ft(TDfig,'LGNTunedCB'),'value');
	corticalfeedback = get(ft(TDfig,'CorticalFeedbackCB'),'value');
	noise = get(ft(TDfig,'NoiseCB'),'value');

	if corticalfeedback,
		J0=-7.3;J2=11;
	else,
		J0 = 0; J2 = 0;
	end;

	if lgntuned,
		e = 1;
	else,
		e = 0.1;
	end;

	if noise, n=5; else, n=0; end;

	W=1./(N)*((J0+J2*cos(2*((cumsum(repmat(pi/N,N,N))'+repmat(((pi/2-2*pi/N):-(pi/N):(-pi/2-pi/N))',1,N))+pi/2+pi/N))));
	Ie=max([40*C*(1-e+e*cos(2*(theta)));zeros(size(theta))])';
	Ie_orth=max([40*C*(1-e+e*cos(2*(theta-pi/4)));zeros(size(theta))])';
end;


switch (cmd),
	case 'start',
		if ishandle(TDfig), close(TDfig); end;
		broadinhibition_fig;
		axes(ft(TDfig,'LGNAxes'));
		axis([-90 90 0 1]); set(gca,'fontweight','bold','fontsize',16);
		xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
		ylabel('LGN FR','fontsize',16,'fontweight','bold');
		axes(ft(TDfig,'InputAxes'));
		axis([-90 90 0 1]); set(gca,'fontweight','bold','fontsize',16);
		ylabel('CTX Input','fontsize',16,'fontweight','bold');
		axes(ft(TDfig,'CTXAxes'));
		axis([-90 90 0 1]); set(gca,'fontweight','bold','fontsize',16);
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');

	case 'Run',
		r=zeros(N,1);
		[t,r]=rk4_broadinhibition(r,t0,dt,t1,Ie,W,n);

		axes(ft(TDfig,'LGNAxes'));
		plot(theta*180/pi,Ie,'g','linewidth',2);
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
		xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
		ylabel('LGN FR','fontsize',16,'fontweight','bold');
		
		axes(ft(TDfig,'InputAxes')); hold off;
		plot(theta*180/pi,W*r(:,end),'r','linewidth',2);
		hold on;
		plot(theta*180/pi,0,'k--','linewidth',2);hold off;
		axis([-90 90 -90 50]); set(gca,'fontweight','bold','fontsize',16,'Tag','InputAxes');
		ylabel('CTX Input','fontsize',16,'fontweight','bold');
		
		
		axes(ft(TDfig,'CTXAxes'));
		plot(theta*180/pi,r(:,end),'b','linewidth',2);		
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');
	case 'RunSlow',
		r=zeros(N,1);
		[t,r]=rk4_broadinhibition(r,t0,dt,t1,Ie,W,n);
		for i=1:50:size(r,2),
			axes(ft(TDfig,'LGNAxes'));
			plot(theta*180/pi,Ie+n*randn(N,1),'g','linewidth',2);
			axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
			xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
			ylabel('LGN FR','fontsize',16,'fontweight','bold');

			axes(ft(TDfig,'InputAxes'));hold off;
			plot(theta*180/pi,W*r(:,i),'r','linewidth',2);
			hold on;
			plot(theta*180/pi,0,'k--','linewidth',2);hold off;
			axis([-90 90 -90 50]); set(gca,'fontweight','bold','fontsize',16,'Tag','InputAxes');
			ylabel('CTX Input','fontsize',16,'fontweight','bold');

			
			axes(ft(TDfig,'CTXAxes'));
			plot(theta*180/pi,r(:,i),'b','linewidth',2);		
			axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
			ylabel('Cortex FR','fontsize',16,'fontweight','bold');
			drawnow;
			pause(1);
		end;	

	case '2Contrasts',
		C = 0.32;
		Ie1=Ie;
		r1=zeros(N,1);
		[t,r1]=rk4_broadinhibition(r1,t0,dt,t1,Ie1,W,n);
		Ie2=Ie1-0.5*max(Ie1);		
		r2=zeros(N,1);
		[t,r2]=rk4_broadinhibition(r2,t0,dt,t1,Ie2,W,n);

		axes(ft(TDfig,'LGNAxes')); hold off;
		plot(theta*180/pi,Ie1,'g','linewidth',2);
		hold on; plot(theta*180/pi,Ie2,'g:','linewidth',2); hold off;
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
		xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
		ylabel('LGN FR','fontsize',16,'fontweight','bold');
		
		axes(ft(TDfig,'InputAxes')); hold off;
		plot(theta*180/pi,W*r1(:,end),'r','linewidth',2);
		hold on;
		plot(theta*180/pi,0,'k--','linewidth',2);
		plot(theta*180/pi,W*r2(:,end),'r:','linewidth',2);
		hold off;
		axis([-90 90 -90 50]); set(gca,'fontweight','bold','fontsize',16,'Tag','InputAxes');
		ylabel('CTX Input','fontsize',16,'fontweight','bold');
		
		
		axes(ft(TDfig,'CTXAxes'));
		hold off; plot(theta*180/pi,r1(:,end),'b','linewidth',2); hold on;
		plot(theta*180/pi,r2(:,end),'b:','linewidth',2); hold off;		
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');		
		
	case '5Contrasts',
		Cs = [ 0 0.2 0.4 0.6 0.8];
		for c=1:5,
			r=zeros(N,1);
			Iec=Ie-Cs(c)*max(Ie);		
			[t,r]=rk4_broadinhibition(r,t0,dt,t1,Iec,W,n);

			axes(ft(TDfig,'LGNAxes')); if c==1, hold off; else, hold on; end;
			plot(theta*180/pi,Iec,'g','linewidth',2); hold off;
			axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
			xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
			ylabel('LGN FR','fontsize',16,'fontweight','bold');
		
			axes(ft(TDfig,'InputAxes')); if c==1, hold off; else, hold on; end;
			plot(theta*180/pi,W*r(:,end),'r','linewidth',2);
			hold on;
			plot(theta*180/pi,0,'k--','linewidth',2); hold off;
			axis([-90 90 -90 50]); set(gca,'fontweight','bold','fontsize',16,'Tag','InputAxes');
			ylabel('CTX Input','fontsize',16,'fontweight','bold');
		
		
			axes(ft(TDfig,'CTXAxes')); if c==1, hold off; else, hold on; end;
			plot(theta*180/pi,r(:,end),'b','linewidth',2); hold off;		
			axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
			ylabel('Cortex FR','fontsize',16,'fontweight','bold');
			drawnow;
		end;

	case '2Orientations',
		
		C = 0.32;
		Ie1=Ie;
		r1=zeros(N,1); [t,r1]=rk4_broadinhibition(r1,t0,dt,t1,Ie1,W,n);
		Ie2=Ie_orth;
		r2=zeros(N,1); [t,r2]=rk4_broadinhibition(r2,t0,dt,t1,Ie2,W,n);
		Ie3=Ie_orth+Ie;
		r3=zeros(N,1); [t,r3]=rk4_broadinhibition(r3,t0,dt,t1,Ie3,W,n);

		axes(ft(TDfig,'LGNAxes')); hold off;
		plot(theta*180/pi,Ie1,'g','linewidth',2);
		hold on;
		plot(theta*180/pi,Ie2,'g:','linewidth',2); 
		plot(theta*180/pi,Ie3,'g--','linewidth',2); hold off;
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','LGNAxes');
		xlabel('Neuron #/Orientation','fontweight','bold','fontsize',16);
		ylabel('LGN FR','fontsize',16,'fontweight','bold');
		
		axes(ft(TDfig,'InputAxes')); hold off;
		plot(theta*180/pi,W*r1(:,end),'r','linewidth',2);
		hold on;
		plot(theta*180/pi,0,'k--','linewidth',2);
		plot(theta*180/pi,W*r2(:,end),'r:','linewidth',2);
		plot(theta*180/pi,W*r3(:,end),'r--','linewidth',2);
		hold off;
		axis([-90 90 -90 50]); set(gca,'fontweight','bold','fontsize',16,'Tag','InputAxes');
		ylabel('CTX Input','fontsize',16,'fontweight','bold');
		
		
		axes(ft(TDfig,'CTXAxes'));
		hold off;
		plot(theta*180/pi,r1(:,end),'b','linewidth',2);
		hold on;
		plot(theta*180/pi,r2(:,end),'b:','linewidth',2); 
		plot(theta*180/pi,r3(:,end),'b--','linewidth',2);
		hold off;		
		axis([-90 90 0 30]); set(gca,'fontweight','bold','fontsize',16,'Tag','CTXAxes');
		ylabel('Cortex FR','fontsize',16,'fontweight','bold');		

end;	


function h = ft(h1,st)  % shorthand
h = findobj(h1,'Tag',st);

