function output=OriDirCurveDemo(varargin)

% ORIDIRCURVEDEMO - Creates an artificial tuning curve 
%
%  OUTPUT = ORIDIRCURVEDEMO
%
%  Produces a double-gaussian direction tuning curve of the form:
%
%  OrCurve = Rsp + Rp*exp(-(angdiffwrap(measured_angles-Opref,360).^2)/(2*sigma^2)) + ...
%         Rn*exp(-(angdiffwrap(measured_angles-Opref+180,360).^2)/(2*sigma^2));
%
%  Experimental data is generated consisting of 'numTrials' trials with gaussian noise of
%  magnitude 'noise_level' added in.
%
%  First, the mean and standard error of the experimental data are plotted in a new figure.
%  Second, the vector responses of each trial are plotted on the complex plane.
%  Third, the results of a double-gaussian fit to the data are plotted.
%
%  The parameters of the function can be adjusted by providing input arguments in
%  name/value pairs, such as OUTPUT = ORIDIRCURVEDEMO('noise_level',2,'numTrials',4)
%
%  PARAMETER:                       COMMENTS:
%  'Rsp'         (default 2)      | Constant offset
%  'Rp'          (default 10)     | Height of the preferred response above Rsp
%  'Rn'          (default 5)      | Height of the null direction response above Rsp
%  'sigma'       (default 30)     | The width of the gaussian peaks
%  'Opref'       (default 40)     | The direction angle preference
%  'noise_level' (default 4)      | The magnitude of the noise added to the curve
%  'noise_method' (default 0)     | The noise method. 0: Gaussian noise (noise_level is standard deviation)
%                                 |        1: Gaussian noise, standard deviation is noise_level * mean
%                                 |        2: Gaussian noise, standard deviation is constant (noise_level(1)) + noise_level(2)*mean
%  'anglestep'   (default 22.5)   | The step between the direction angles that are measured
%  'numTrials'   (default 7)      | The number of trials to simulate
%  'doplotting'  (default 1)      | 0/1 Should we draw the plots?
%  'dofitting'   (default 1)      | 0/1 Should we perform a double gaussian fit?
%  'sigmahints'  (default 20)     | List of hints for sigma
%  'fit_reps'    (default 1)      | Number of times to repeat fit attempts
%  'constrainfit'(default 1)      | 0/1 Should we constrain the fit output?
%  'dounconstrainedfit (default 0)| 0/1 Should we additionally plot an unconstrained fit?
%  'doplotting_orispace' (def. 0) | 0/1 Should we plot the orientation in orientation space?
%  'doplotting_orispace_mean_ori_vector' (def. 0) | 0/1 Should we plot the mean ori vector?
%  'doplotting_dirspace_mean_dir_vector' (def. 0) | 0/1 Should we plot the mean dir vector?
%
%  The workspace variables of the function are returned in the structure OUTPUT.
%
%  FIELD:
%  'measuredangles'               | The direction angles that were measured in the simulation
%  'experimentaldata'             | The simulated 
%  'dirmean'                      | The mean responses in each direction
%  'dirstddev'                    | The standard deviation of the response in each direction
%  'dirstde'                      | The standard error of the response in each direction
%  'vecresp'                      | An array of trial-by-trial orientation space vector responses
%                                 |        in complex plane
%  'vectormean'                   | The mean of these orientation space vector responses
%  'Rsp_','Rp_','Rn_','sigm_',   | If fitting is done, these are the best-fit parameters
%      'Op_'                      |   for Rsp, Rp, Rn, sigma, and Op, respectively.
%  'FITCURVE'                     | The value of the fit for directions [0:359]
%
%  See also:  OTFIT_CARANDINI

anglestep = 22.5;
Rsp = 2;
Rn = 5;
Rp = 10;
sigma = 30;
Opref = 40;
noise_level = 4; % strong tuning
noise_method = 0;
numTrials = 7;
doplotting = 1;
dofitting = 1;
constrainfit = 1;
fit_reps = 1;
sigmahints = [20];
dounconstrainedfit=0;

doplotting_orispace = 0;
doplotting_orispace_mean_ori_vector = 0;
doplotting_dirspace_mean_dir_vector = 1;

assign(varargin{:});

measured_angles = 0:anglestep:360-anglestep;

all_angles = 0:359;

OrCurve = Rsp + Rp*exp(-(angdiffwrap(measured_angles-Opref,360).^2)/(2*sigma^2)) + ...
	Rn*exp(-(angdiffwrap(measured_angles-Opref+180,360).^2)/(2*sigma^2));

experimentaldata = repmat([OrCurve],numTrials,1);

switch noise_method,
	case 0,
		experimentaldata = experimentaldata + ...
			noise_level*randn(numTrials,length(measured_angles));
	case 1,
		experimentaldata = experimentaldata + ...
			experimentaldata.*noise_level.*randn(numTrials,length(measured_angles));
	case 2,
		if numel(noise_level)~=2,
			error(['When using noise_method==2 (constant + factor * mean), noise_level must have 2 elements.']);
		end;
		experimentaldata = experimentaldata + ...
			noise_level(1)*randn(numTrials,length(measured_angles)) +...
			experimentaldata.*noise_level(2).*randn(numTrials,length(measured_angles));
end;

 % calculate mean, standard deviation, and standard error
dirmean = mean(experimentaldata,1);
dirstddev = std(experimentaldata,1);
dirstde = stderr(experimentaldata);

if doplotting,
	figure;
	myerrorbar(measured_angles,dirmean,dirstde,dirstde);
	box off;
	title('Direction response');
	xlabel('Angle of grating motion');
	ylabel('Reponse (Hz)');
	A = axis;
end;

vecresp = (experimentaldata*transpose(exp(sqrt(-1)*2*mod(measured_angles*pi/180,pi))))/2;
vectormean = mean(vecresp);

if doplotting,
	figure;
	plot([-25 25],[0 0],'k--');
	hold on;
	plot([0 0],[-25 25],'k--');
	plot(vecresp,'o');
	plot(vectormean,'kx');
	plot([0 real(vectormean)],[0 imag(vectormean)],'k-');
	title(['Vector representation of orientation responses']);
	xlabel(['Real component']);
	ylabel(['Imaginary component']);
	box off;
	axis equal;
end;

if doplotting,  % polar direction plot
	figure;
	[hh,polaroutputs_dir]=polarplot_dir(measured_angles, dirmean,'showmeanvector',doplotting_dirspace_mean_dir_vector);
end;

if doplotting_orispace,
	figure;
	[angles_ori,resp_ori] = dirspace2orispace(measured_angles,dirmean);
	[hh,polaroutputs_ori]=polarplot_ori(angles_ori, resp_ori,'showmeanvector',doplotting_orispace_mean_ori_vector);
end;

if dofitting,
 % now fit this cell once
	da = measured_angles(2)-measured_angles(1);
	[maxresp,locofmaxresp] = max(dirmean);
	anglehint = measured_angles(locofmaxresp(1));
	Rpint = [0 3*maxresp];
	Rnint = [0 3*maxresp];
	spontint = [min(dirmean) max(dirmean)];
	if ~constrainfit,
		da = 0; % let the fits be as narrow as they wanna be!
		Rpint = [ -1000 1000];
		Rnint = [ -1000 1000];
		spontint = [-1000 1000];
	end;
	
	Rsp_b = []; Rp_b = []; Rn_b = []; Op_b = []; sigm_b = [];
	ERR_b = Inf; % current best error
	FITCURVE_b = [];

	for k=1:length(fit_reps),
		for s=1:length(sigmahints),
			[Rsp_,Rp_,Op_,sigm_,Rn_,FITCURVE,ERR]=otfit_carandini(measured_angles,0, maxresp, anglehint, sigmahints(s),'widthint',[da/2 180],...
				'Rpint',Rpint,'Rnint',Rnint,'spontint',spontint,'data',dirmean);
			if ERR<ERR_b, % we have a new best
				Rsp_b = Rsp_; Rp_b = Rp_; Rn_b = Rn_; Op_b = Op_; ERR_b = ERR; FITCURVE_b = FITCURVE;
			end;
		end;
	end;
	Rsp_ = Rsp_b; Rp_ = Rp_b; Rn_ = Rn_b; Op_ = Op_b; ERR = ERR_b; FITCURVE = FITCURVE_b;

	if doplotting,
		disp(['Now displaying fit parameters:']);
		Rsp_,Rp_,Op_,sigm_,Rn_,
	end;
end;

if dounconstrainedfit,
        [maxresp,locofmaxresp] = max(dirmean);
        anglehint = measured_angles(locofmaxresp(1));
	da = 0; % let the fits be as narrow as they wanna be!
	Rpint = [ -1000 1000];
	Rnint = [ -1000 1000];
	spontint = [-1000 1000];
	[Rsp_u,Rp_u,Op_u,sigm_u,Rn_u,FITCURVE_u,ERR_u]=otfit_carandini(measured_angles,0, maxresp, anglehint, 20,'widthint',[da/2 180],...
		'Rpint',Rpint,'Rnint',Rnint,'spontint',spontint,'data',dirmean);

end;



 % now plot the fit with data points
if dofitting&doplotting,
	figure;
	h= myerrorbar(measured_angles,dirmean,dirstde,dirstde);
	delete(h(2));
	hold on;
	plot(all_angles,FITCURVE,'r');
	if dounconstrainedfit,
		plot(all_angles,FITCURVE_u,'m');
	end;
	box off;
	title('Direction response');
	xlabel('Angle of grating motion');
	ylabel('Reponse (Hz)');
	axis(A);
end;

clear A;

 % save our locoal variables and return them in case the user wants to play around with them
output = workspace2struct;
