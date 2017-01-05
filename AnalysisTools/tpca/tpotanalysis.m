function [newcell,assoc]=tpotanalysis(ds,cell,cellname,display)

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
%
%  Measures derived from raw responses:
%  'OT Pref'                      |   Direction w/ max firing
%  'OT Max response'              |   Max mean response
%  'OT Circular variance'         |   Circular variance
%  'OT Orientation index'         |   Orientation index
%  'OT Direction index'           |   Directionality index
%  'OT Response curve'            |   Curve of responses
%  'OT visual response'           |   0/1 Was response significant w/ P<0.05?
%  'OT visual response p'         |   Anova p across stims and blank (if available)
%  'OT varies'                    |   0/1 Was response significant across OT?
%  'OT varies p'                  |   Anova p across stims
%
%  Measures dervied from vector analysis:
%  'OT Pref Vec'                  |   Angle preference in orientation space
%  'OT Mag Vec'                   |   Magnitude of response in orientation space
%  'OT Dir Pref Vec'              |   Angle preference in direction space
%  'OT Dir Mag Vec'               |   Magnitude of response in direction space
%  'OT Dir Ind Vec'               |   Direction index in vector space
%  'OT vec varies'                |   0/1 Was Hotelling's T^2 test of orientation vector
%                                 |      significant w/ P<0.05?
%  'OT vec varies p'              |   Hotelling's T^2 test of orientation vector data
%  'OT dir sig vec'               |   0/1 Is direction vector significant?
%  'OT dir sig vec p'             |   P value of direction vector significance
%
%  Gaussian fit: first, two peak gaussian w/ different heights
%  'OT Carandini Fit Params'      |   Carandini Fit params [Rsp Rp Op sigm Rn]
%  'OT Carandini Fit'             |   The fit at points 0:359
%  'OT Fit Pref'                  |   Direction preference from fit
%  'OT Fit Orientation index'     |   Orientation index based on fit
%  'OT Fit Orientation index sp'  |   Orientation index based on fit w/ spont subtracted
%  'OT Tuning width'              |   Tuning width (half width at half height)
%  'OT Carandini R2'              |   R^2 value of fit
%  'OT Fit Direction index'       |   Directionality index
%  'OT Fit Direction index sp'    |   Directionality index w/ spont subtracted
%
%  Another gaussian fit: two peak gaussian w/ same heights
%  'OT Carandini Rp Fit Params'   |   Carandini Fit params [Rsp Rp Op sigm Rn]
%  'OT Carandini Rp Fit'          |   The fit at points 0:359
%  'OT Fit Pref Rp'               |   Direction preference from fit
%  'OT Fit Orientation index Rp'  |   Orientation index based on fit
%  'OT Fit Orientation index Rp sp'   Orientation index based on fit w/ spont subtracted
%  'OT Tuning width Rp'           |   Tuning width (half width at half height)
%  'OT Carandini Rp R2'           |   R^2 value of fit
%  'OT Fit Direction index Rp'    |   Directionality index
%  'OT Fit Direction index Rp sp' |   Directionality index w/ spont subtracted
%
%  'OT Significant Direction'     |   0/1 Nested F test: is the fit where two peaks
%                                 |     can vary significantly better than
%                                 |     the fit where two peaks do not vary?
%  'OT Significant Direction p'   |   P value for above
%
%  Another gaussian fit: two peak gaussian w/ same heights
%  'OT Carandini 2-peak Fit Params'|   Carandini Fit params [Rsp Rp Op sigm Rn]
%  'OT Carandini 2-peak Fit'      |   The fit at points 0:359
%  'OT Fit Pref 2 Peak'           |   Direction preference from fit
%  'OT Fit Pref 2nd Peak'         |   Second peak location
%  'OT Fit Orientation index 2 peak'|   Orientation index based on fit
%  'OT Fit Orientation index 2 peak sp'|   Orientation index based on fit w/ spont subtracted
%  'OT Tuning width 2 Peak'       |   Tuning width (half width at half height)
%  'OT Carandini 2-peak R2'       |   R^2 value of fit
%  'OT Fit Direction index 2 peak'|   Directionality index
%  'OT Fit Direction index 2 peak sp' |   Directionality index w/ spont subtracted
%
%  A list of associate types that TPOTANALYSIS computes is returned if
%  the function is called with no arguments.

if nargin==0,

	newcell = {'OT Response curve','OT Max Response','OT Pref','OT Circular variance', ...
		'OT Orientation index', 'OT Direction index', ... 
		'OT varies', 'OT varies p','OT visual response','OT visual response p',   ... %responses
		'OT Pref Vec','OT Mag Vec','OT Dir Pref Vec','OT Dir Mag Vec','OT Dir Ind Vec',...
		'OT vec varies p','OT vec varies','OT dir sig vec','OT dir sig vec p', ... %vector
		'OT Carandini Fit Params', 'OT Carandini Fit','OT Fit Pref','OT Fit Orientation index',...
		'OT Fit Orientation index sp','OT Tuning width','OT Carandini R2',...
		'OT Fit Direction index', 'OT Fit Direction index sp', ...  % gaussian fit w/ Rp, Rn
		'OT Carandini Rp Fit Params', 'OT Carandini Rp Fit','OT Fit Pref Rp','OT Fit Orientation index Rp',...
		'OT Fit Orientation index Rp sp','OT Tuning width Rp','OT Carandini Rp R2',...
		'OT Fit Direction index Rp', 'OT Fit Direction index Rp sp', ...  % gaussian fit w/ same heights
		'OT Carandini 2-peak Fit Params', 'OT Carandini 2-peak Fit','OT Fit Pref 2 Peak','OT Fit Pref 2nd Peak',...
		'OT Fit Orientation index 2 peak',...
		'OT Fit Orientation index 2 peak sp','OT Tuning width 2 Peak','OT Carandini 2-peak R2',...
		'OT Fit Direction index 2 peak', 'OT Fit Direction index 2 peak sp', ...% gaussian fit w/ diff peak locs
		'OT Significant Direction','OT Significant Direction p'};  % nested f test
	return;
end;

newcell = cell;
assoc=struct('type','t','owner','t','data',0,'desc',0); assoc=assoc([]);

otresp = findassociate(newcell,'Best orientation resp','',[]);
ottest = findassociate(newcell,'Best orientation test','',[]);

if ~isempty(ottest)&~isempty(otresp),  % do analysis
  g=load([getpathname(ds) ottest(end).data filesep 'stims.mat'],'saveScript','MTI2','-mat');
  s=stimscripttimestruct(g.saveScript,g.MTI2);
  
  % now loop through list and do fits

  assoclist = tpotanalysis;

  for I=1:length(assoclist),
	[as,i] = findassociate(newcell,assoclist{I},'',[]);
	if ~isempty(as), newcell = disassociate(newcell,i); end;
  end;

  maxresp = []; 
  fdtpref = []; 
  circularvariance = [];
  tuningwidth = [];

  resp = otresp.data.curve;

  if eqlen(resp(1,:),1:length(resp(1,:))),
      % if resp(1,:)=[1 2 3 ...] then the user analyzed by stim number and we will extract angle values here
      myx = [];
      for j=1:numStims(s.stimscript),
         if ~isfield(getparameters(get(s.stimscript,j)),'isblank'),
             myx(end+1) = getfield(getparameters(get(s.stimscript,j)),'angle');
         else, blankind=j;
         end;
      end;
      if length(myx)<length(resp(1,:)),
        resp = resp(:,[1:j-1 j+1:length(resp(1,:))]);
      end;
      resp(1,:) = myx;
  end;
  angles = resp(1,:);

  [maxresp,if0]=max(resp(2,:)); 
  otpref = [resp(1,if0)];

  if max(angles)<=180,
        tuneangles = [angles angles+180]; tuneresps = [resp(2,:) resp(2,:)]; tuneerr = [resp(4,:) resp(4,:)];
  else,
	tuneangles = angles; tuneresps = resp(2,:); tuneerr = resp(4,:);
	directionindex = compute_directionindex(angles,resp(2,:));
  end;

  circularvariance = compute_circularvariance(tuneangles,tuneresps);
  tuningwidth = compute_tuningwidth(tuneangles,tuneresps);
  orientationindex = compute_orientationindex(tuneangles,tuneresps);

  % compute significance of responses

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

  % vector analysis

  % use Hotelling's T^2 test to see if vectorized points deviate from 0,0
  allresps = [otresp.data.ind{:}];
     % remove any NaN's
  notnans = find(0==isnan(mean(allresps')));
  allresps = allresps(notnans,:);
  if size(allresps,1)>0,
	% in orientation space
	vecresp = (allresps*transpose(exp(sqrt(-1)*2*mod(angles*pi/180,pi))));
	[h2,vecp]=hotellingt2test([real(vecresp) imag(vecresp)],[0 0]);
	vecotpref = mod(180/pi*angle(mean(vecresp)),180);
	vecotmag = abs(mean(vecresp));

	% in direction space
	vecdirresp = (allresps*transpose(exp(sqrt(-1)*mod(angles*pi/180,2*pi))));
	[h3,vecdirp]=hotellingt2test([real(vecdirresp) imag(vecdirresp)],[0 0]);
	vecdirpref = mod(180/pi*angle(mean(vecdirresp)),360);
	vecdirmag = abs(mean(vecdirresp));
	vecdirind = abs(mean(vecdirresp))/maxresp;
  else, vecp = 1; vecdirp = 1; vecotpref = NaN; vecdirpref = NaN; vecotmag = 0; vecdirmag = 0; vecdirind = 0;
  end;

  da = diff(sort(angles)); da = da(1);

  if(1)  % fit with Carandini function
	%[rcurve,n_otpref,n_tuningwidth]=fit_otcurve([tuneangles; tuneresps],otpref,90,maxresp,0);
	% tuning_width is not calculated with spontaneous rate subtracted
	% do five fits of each type, varying initial width seed
	widthseeds = [da/2 da 40 60 90];
	errors = [Inf Inf Inf];
	for i=1:length(widthseeds),
		ws = widthseeds(i);
		[Rsp_0t,Rp_0t,Ot_0t,sigm_0t,fitcurve_0t,er_0t,R2_0t] = otfit_carandini0(tuneangles,0,maxresp,otpref,ws,'widthint',[da/2 180],...
			'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
		if er_0t<errors(1),
			Rsp_0=Rsp_0t;Rp_0=Rp_0t;Ot_0=Ot_0t;sigm_0=sigm_0t;fitcurve_0=fitcurve_0t;er_0=er_0t;R2_0=R2_0t;
			errors(1) = er_0t;
		end;
		[Rspt,Rpt,Ott,sigmt,Rnt,fitcurvet,ert,R2t] = otfit_carandini(tuneangles,0,maxresp,otpref,ws,'widthint',[da/2 180],...
			'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
		if ert<errors(2),
			Rsp=Rspt;Rp=Rpt;Ot=Ott;sigm=sigmt;fitcurve=fitcurvet;er=ert;R2=R2t;Rn=Rnt;
			errors(2) = ert;
		end;
		[Rsp_t,Rp_t,Ot_t,sigm_t,Rn_t,OnOff_t,fitcurve_t,er_t,R2_t]=otfit_carandini2(tuneangles,0,maxresp,otpref,ws,...
			'widthint',[da/2 180],'OnOffInt',[130 230],'Rpint',[0 3*maxresp],'Rnint',[0 3*maxresp],...
			'spontint',[min(tuneresps) max(tuneresps)],'data',tuneresps);
		if er_t<errors(3),
			Rsp_=Rsp_t;Rp_=Rp_t;Ot_=Ot_t;sigm_=sigm_t;fitcurve_=fitcurve_t;er_=er_t;R2_=R2_t;Rn_=Rn_t;OnOff_=OnOff_t;
			errors(3) = er_t;
		end;
	end;

	if 0,
	% try adaptiveMCMC Monte-Carlo Markov Chain to get confidence intervals

	parameter_bounds = [ min(tuneresps) max(tuneresps) ; 0 3*maxresp ; 0 360; da/2 180 ; 0 3*maxresp];
	% define prior expectation of variance in terms of SE of measured data, use tuning width for peak position, guess for width
	par_var_est = [ mean(resp(4,:))/2 mean(resp(4,:)) sigm (180-da/2)/4 mean(resp(4,:)) ];
	[par_mmse,par_conf_interval, par_samples_conf_interval]=adaptiveMCMCfit_MIS(@otfit_carandini_err,[Rsp Rp Ot sigm Rn],...
			par_var_est, tuneresps,parameter_bounds(:,1)',parameter_bounds(:,2)','data',tuneresps);
	end;
	

	%[Rsp Rp Ot sigm Rn ],
	%[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_],
	if max(angles)<=180&Ot>180, Ot = Ot-180; end;

	if max(angles)>=180,  % if in direction space
		toter = otfit_carandini_err([Rsp Rp Ot sigm Rn],tuneangles,'data',[otresp.data.ind{:}]);
		toter0 = otfit_carandini_err0([Rsp_0 Rp_0 Ot_0 sigm_0],tuneangles,'data',[otresp.data.ind{:}]);
		Dpts = prod(size([otresp.data.ind{:}]));
		p_directional = 1-fcdf( ((toter0-toter)/toter)/ ( ((Dpts-4)-(Dpts-5))/(Dpts-5) ), 2, Dpts-5);
	end;

	OtPi = findclosest(0:359,Ot); OtNi = findclosest(0:359,mod(Ot+180,360));
	OtO1i = findclosest(0:359,mod(Ot+90,360)); OtO2i = findclosest(0:359,mod(Ot-90,360));
	otindfit = (fitcurve(OtPi)+fitcurve(OtNi)-fitcurve(OtO1i)-fitcurve(OtO2i))/(fitcurve(OtPi)+fitcurve(OtNi));
	otindfitsp = (fitcurve(OtPi)+fitcurve(OtNi)-fitcurve(OtO1i)-fitcurve(OtO2i))/(fitcurve(OtPi)+fitcurve(OtNi)-Rsp-Rsp);

	OtPi_ = findclosest(0:359,Ot_); OtNi_ = findclosest(0:359,mod(Ot_+OnOff_,360));
	OtO1i_ = findclosest(0:359,mod(Ot_+OnOff_/2,360)); OtO2i_ = findclosest(0:359,mod(Ot_-(360-OnOff_)/2,360));
	otindfit_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_));
	otindfitsp_ = (fitcurve_(OtPi_)+fitcurve_(OtNi_)-fitcurve_(OtO1i_)-fitcurve_(OtO2i_))/(fitcurve_(OtPi_)+fitcurve_(OtNi_)-Rsp_-Rsp_);

	if display&(ot_vis_p<0.05)
	  figure;
	  errorbar(tuneangles,tuneresps,tuneerr,'o'); 
	  hold on
	  plot(0:359,fitcurve,'r');
	  plot(0:359,fitcurve_,'g');
      cellname,
	[Rsp Rp Ot sigm Rn ],
	[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_],
      
	  xlabel('Direction')
	  ylabel('\Delta F/F');
          title(cellname,'interp','none');
	end % display
  end  % function fitting


  % Indices based on responses alone
  assoc(end+1)=myassoc('OT Response curve',resp);
  assoc(end+1)=myassoc('OT Max Response',maxresp);
  assoc(end+1)=myassoc('OT Pref',otpref);
  assoc(end+1)=myassoc('OT Orientation index',orientationindex);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index',directionindex); end;
  assoc(end+1)=myassoc('OT Circular variance',circularvariance);

  assoc(end+1)=myassoc('OT varies',ot_varies_p<0.05);
  assoc(end+1)=myassoc('OT varies p',ot_varies_p);
  if exist('ot_vis_p')==1,
	  assoc(end+1)=myassoc('OT visual response',ot_vis_p<0.05);
	  assoc(end+1)=myassoc('OT visual response p',ot_vis_p);
  end;

  % Vector analysis
  assoc(end+1)=myassoc('OT Pref Vec', vecotpref);
  assoc(end+1)=myassoc('OT Mag Vec', vecotmag);
  assoc(end+1)=myassoc('OT Dir Pref Vec', vecdirpref);
  assoc(end+1)=myassoc('OT Dir Mag Vec',vecdirmag);
  assoc(end+1)=myassoc('OT Dir Ind Vec',vecdirind);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT dir sig vec',vecdirp<0.05); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT dir sig vec p',vecdirp); end;
  assoc(end+1)=myassoc('OT vec varies p',vecp);
  assoc(end+1)=myassoc('OT vec varies',vecp<0.05);

  % Gaussian fits
  assoc(end+1)=myassoc('OT Carandini Fit Params',[Rsp Rp Ot sigm Rn]);
  assoc(end+1)=myassoc('OT Carandini Fit',fitcurve);
  assoc(end+1)=myassoc('OT Fit Pref',Ot);
  assoc(end+1)=myassoc('OT Fit Orientation index',otindfit);
  assoc(end+1)=myassoc('OT Fit Orientation index sp',otindfitsp);
  assoc(end+1)=myassoc('OT Tuning width',sigm*sqrt(log(4)));
  assoc(end+1)=myassoc('OT Carandini R2',R2);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index',(Rp-Rn)/(Rp+Rsp)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index sp',(Rp-Rn)/(Rp)); end;

  assoc(end+1)=myassoc('OT Carandini Rp Fit Params',[Rsp Rp Ot sigm Rn]);
  assoc(end+1)=myassoc('OT Carandini Rp Fit',fitcurve);
  assoc(end+1)=myassoc('OT Fit Pref Rp',Ot);
  assoc(end+1)=myassoc('OT Fit Orientation index Rp',otindfit);
  assoc(end+1)=myassoc('OT Fit Orientation index Rp sp',otindfitsp);
  assoc(end+1)=myassoc('OT Tuning width Rp',sigm*sqrt(log(4)));
  assoc(end+1)=myassoc('OT Carandini Rp R2',R2);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index Rp',(Rp-Rn)/(Rp+Rsp)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Fit Direction index Rp sp',(Rp-Rn)/(Rp)); end;

  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Significant Direction',p_directional<0.05); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Significant Direction p',p_directional); end;

  assoc(end+1)=myassoc('OT Carandini 2-peak Fit Params',[Rsp_ Rp_ Ot_ sigm_ Rn_ OnOff_]);
  assoc(end+1)=myassoc('OT Carandini 2-peak Fit',fitcurve_);
  assoc(end+1)=myassoc('OT Fit Pref 2 Peak',Ot_);
  assoc(end+1)=myassoc('OT Fit Pref 2nd Peak',mod(Ot_+OnOff_,360));
  assoc(end+1)=myassoc('OT Orientation index 2 peak',otindfit_);
  assoc(end+1)=myassoc('OT Orientation index 2 peak sp',otindfitsp_);
  assoc(end+1)=myassoc('OT Tuning width 2 Peak',sigm_*sqrt(log(4)));
  assoc(end+1)=myassoc('OT Carandini 2-peak R2',R2_);
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index 2 peak',(Rp_-Rn_)/(Rp_+Rsp_)); end;
  if exist('directionindex')==1, assoc(end+1)=myassoc('OT Direction index 2 peak sp',(Rp_-Rn_)/(Rp_)); end;

end;

for i=1:length(assoc), newcell=associate(newcell,assoc(i)); end;

outstr = []; % no longer used

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');

