function [assoc]=zabotanalysis(resp,cellname,display)

%   DONT READ BELOW
%       ASSOC = ZABOTANALYSIS(RESP,CELLNAME,DISPLAY)
%
%      RESP= [ ANGLES ; RESPONSES]
%  
%  TPOTANALYSIS
%
%  [NEWSCELL,ASSOC]=TPOTANALYSIS(DS,CELL,CELLNAME,DISPLAY)
%
%  Analyzes the orientation tuning tests.  DS is a valid DIRSTRUCT
%  experiment record.  CELL is a list of MEASUREDDATA objects, CELLNAME is a
%  string list containing the names of the cells, and DISPLAY is 0/1 depending
%  upon whether or not output should be displayed graphically.  If REANALYZE
%  is 1 then the responses are recomputed from the raw data.  Fits are always
%  recalculated regardless of whether responses are recomputed.
%  
%  Measures gathered from the OT Test (associate name in quotes):
%  'OT Pref'                      |   Direction w/ max firing
%  'OT Max response'              |   Max response during drifting gratings
%  'OT Circular variance'         |   Circular variance
%  'OT Tuning width'              |   Tuning width (half width at half height)
%  'OT Direction index'           |   Directionality index
%  'OT Spontaneous rate'          |   Spontaneous rate and std dev.
%  'OT Orientation index'         |   Orientation index
%  'OT Carandini Fit Params'      |   Carandini Fit params [Rsp Rp Op sigm Rn]
%  'OT Fit Pref'                  |   Direction preference from fit
%  'OT Fit Direction index'       |   Directionality index
%  'OT Fit Direction index sp'    |   Directionality index w/ spont subtracted
%  'OT Fit Orientation index'     |   Orientation index based on fit
%  'OT Fit Orientation index sp'  |   Orientation index based on fit w/ spont subtracted
%  'OT Carandini Fit'             |   The fit at points 0:359
%  'OT visual response'           |   0/1 Was response significant w/ P<0.05?
%  'OT visual response p'         |   Anova p across stims and blank (if available)
%  'OT varies'                    |   0/1 Was response significant across OT?
%  'OT varies p'                  |   Anova p across stims
%  'OT vec varies'                |   0/1 Was Hotelling's T^2 test of orientation vector
%                                 |      significant w/ P<0.05?
%  'OT vec varies p'              |   Hotelling's T^2 test of orientation vector data
%  'OT Carandini 2-peak Fit'      |   Fit w/ two gaussians not constrained to
%                                 |      180 degrees apart (called 2-peak fit)
%  'OT Carandini 2-peak Fit Params'   [Rsp Rp Op sigm Rn OnOffset]
%  'OT Fit Pref 2 Peak'           |   Direction peak as determined by 2-peak fit
%  'OT Fit Pref 2nd Peak'         |   Nonpreferred peak as determined by 2-peak fit
%  'OT Direction index 2 peak'    |   Direction index from 2-peak fit
%  'OT Direction index 2 peak sp' |   Direction index from 2-peak fit w/ spont subtracted
%  'OT Tuning width 2 Peak'       |   Tuning width (half width at half height)
%  'OT Orientation index 2 peak'  |   Orientation index based on fit
%  'OT Orientation index 2 peak sp'   Orientation index based on fit w/ spont subtracted
%
%  A list of associate types that TPOTANALYSIS computes is returned if
%  the function is called with no arguments.

if nargin==0,
	newcell = {'OT Pref','OT Max Response','OT Circular variance','OT Tuning width',...
			'OT Direction index','OT Fit Direction index','OT Fit Pref','OT varies','OT varies p',...
			'OT Carandini Fit','OT Carandini Fit Params','OT visual response',...
			'OT visual response p','OT Fit Direction Index',...
			'OT Carandini 2-peak Fit','OT Fit Pref 2 Peak','OT Fit Pref 2nd Peak','OT Carandini 2-peak Fit Params',...
			'OT Direction index 2 peak','OT Orientation index 2 peak','OT Orientation index 2 peak sp',...
			'OT Direction index 2 peak sp','OT Fit Orientation index','OT Fit Orientation index sp',...
			'OT vec varies p','OT vec varies','OT Response curve'};
	return;
end;

assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

  maxresp = []; 
  fdtpref = []; 
  circularvariance = [];
  tuningwidth = [];

  %resp = otresp.data.curve;

  angles = resp(1,:);

  [maxresp,if0]=max(resp(2,:)); 
  otpref = [resp(1,if0)];

	if 0,  % none of these stats available
  groupmem = [];
  vals = [];
  for i=1:length(otresp.data.ind),
	vals = cat(1,vals,otresp.data.ind{i});
	groupmem = cat(1,groupmem,i*ones(size(otresp.data.ind{i})));
  end;
  ot_varies_p = anova1(vals,groupmem,'off');
  if isfield(otresp.data,'blankresp'),
 	vals = cat(1,vals,otresp.data.blankind);
	groupmem = cat(1,groupmem,(length(otresp.data.ind)+1)*ones(size(otresp.data.blankind)));
  	ot_vis_p = anova1(vals,groupmem,'off');
  else, ot_vis_p = ot_varies_p;
  end;
  % now use Hotelling's T^2 test to see if vectorized points deviate from 0,0
  allresps = [otresp.data.ind{:}];
     % remove any NaN's
  notnans = find(0==isnan(mean(allresps')));
  allresps = allresps(notnans,:);
  if size(allresps,1)>0,
	vecresp = (allresps*transpose(exp(sqrt(-1)*2*mod(angles*pi/180,pi))));
	[h2,vecp]=hotellingt2test([real(vecresp) imag(vecresp)],[0 0]);
  else, vecp = 1;
  end;
	end;  % cutting this out

  if max(angles)<=180,
        tuneangles = [angles angles+180]; tuneresps = [resp(2,:) resp(2,:)];
	if size(resp,1)>=4, tuneerr = [resp(4,:) resp(4,:)]; else, tuneerr = 0 * [resp(2,:) resp(2,:)]; end;
  else,
	tuneangles = angles; tuneresps = resp(2,:);
	if size(resp,1)>=4, tuneerr = [resp(4,:)]; else, tuneerr = 0*resp(2,:); end;
	directionindex = compute_directionindex(angles,resp(2,:));
  end;
    
  circularvariance = compute_circularvariance(tuneangles,tuneresps);
  tuningwidth = compute_tuningwidth(tuneangles,tuneresps);
  orientationindex = compute_orientationindex(tuneangles,tuneresps);
  da = diff(sort(angles)); da = da(1);

  if(1)  % fit with Carandini function
	%[rcurve,n_otpref,n_tuningwidth]=fit_otcurve([tuneangles; tuneresps],otpref,90,maxresp,0);
	% tuning_width is not calculated with spontaneous rate subtracted
	[Rsp,Rp,Ot,sigm,Rn,fitcurve,er] = otfit_carandini(tuneangles,0,maxresp,otpref,90,'widthint',[da/2 180],...
		'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
	[Rsp_,Rp_,Ot_,sigm_,Rn_,OnOff_,fitcurve_,er_]=otfit_carandini2(tuneangles,0,maxresp,otpref,90,...
		'widthint',[da/2 180],'OnOffInt',[130 230],'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],...
		'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
	%[Rsp Rp Ot sigm Rn ],
	%[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_],
	if max(angles)<=180&Ot>180, Ot = Ot-180; end;

	OtPi = findclosest(0:359,Ot); OtNi = findclosest(0:359,mod(Ot+180,360));
	OtO1i = findclosest(0:359,mod(Ot+90,360)); OtO2i = findclosest(0:359,mod(Ot-90,360));
	otindfit = (fitcurve(OtPi)+fitcurve(OtNi)-fitcurve(OtO1i)-fitcurve(OtO2i))/(fitcurve(OtPi)+fitcurve(OtNi));
	otindfitsp = (fitcurve(OtPi)+fitcurve(OtNi)-fitcurve(OtO1i)-fitcurve(OtO2i))/(fitcurve(OtPi)+fitcurve(OtNi)-Rsp-Rsp);

	OtPi_ = findclosest(0:359,Ot_); OtNi_ = findclosest(0:359,mod(Ot_+OnOff_,360));
	OtO1i_ = findclosest(0:359,mod(Ot_+OnOff_/2,360)); OtO2i_ = findclosest(0:359,mod(Ot_-(360-OnOff_)/2,360));
	otindfit_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_));
	otindfitsp_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_)-Rsp_-Rsp_);

	if display,
	  figure;
	  errorbar(tuneangles,tuneresps,tuneerr,'o'); 
	  hold on
	  plot(0:359,fitcurve,'r');
	  plot(0:359,fitcurve_,'g');
      
	  xlabel('Direction')
	  ylabel('\Delta F/F');
          title(cellname,'interp','none');
	end % display
  end  % function fitting

  assoc(end+1)=myassoc('OT Response curve',resp);
  assoc(end+1)=myassoc('OT Max Response',maxresp);
  assoc(end+1)=myassoc('OT Fit Pref',Ot);
  assoc(end+1)=myassoc('OT Pref',otpref);
  assoc(end+1)=myassoc('OT Circular variance',circularvariance);
  assoc(end+1)=myassoc('OT Tuning width',sigm*sqrt(log(4)));
  assoc(end+1)=myassoc('OT Tuning width 2 Peak',sigm_*sqrt(log(4)));
  assoc(end+1)=myassoc('OT Carandini Fit Params',[Rsp Rp Ot sigm Rn]);
  assoc(end+1)=myassoc('OT Carandini Fit',fitcurve);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index',directionindex); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index',(Rp-Rn)/(Rp+Rsp)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index sp',(Rp-Rn)/(Rp)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index 2 peak',(Rp_-Rn_)/(Rp_+Rsp_)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index 2 peak sp',(Rp_-Rn_)/(Rp_)); end;
  assoc(end+1)=myassoc('OT Orientation index',orientationindex);
  assoc(end+1)=myassoc('OT Fit Orientation index',otindfit);
  assoc(end+1)=myassoc('OT Fit Orientation index sp',otindfitsp);
  %assoc(end+1)=myassoc('OT varies',ot_varies_p<0.05);
  %assoc(end+1)=myassoc('OT varies p',ot_varies_p);
  assoc(end+1)=myassoc('OT Carandini 2-peak Fit Params',[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_]);
  assoc(end+1)=myassoc('OT Carandini 2-peak Fit',fitcurve_);
  assoc(end+1)=myassoc('OT Fit Pref 2 Peak',Ot_);
  assoc(end+1)=myassoc('OT Fit Pref 2nd Peak',mod(Ot_+OnOff_,360));
  assoc(end+1)=myassoc('OT Orientation index 2 peak',otindfit_);
  assoc(end+1)=myassoc('OT Orientation index 2 peak sp',otindfitsp_);
  %if exist('ot_vis_p')==1,
%	  assoc(end+1)=myassoc('OT visual response',ot_vis_p<0.05);
%	  assoc(end+1)=myassoc('OT visual response p',ot_vis_p);
%  end;
  %assoc(end+1)=myassoc('OT vec varies p',vecp);
  %assoc(end+1)=myassoc('OT vec varies',vecp<0.05);

outstr = []; % no longer used

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

