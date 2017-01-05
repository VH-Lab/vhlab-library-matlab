function b = verifytprecordings(source)

% VERIFYTPRECORDINGS -Make sure all files are present in TP recordings
%
%  B = VERIFYTPRECORDINGS(SOURCEDIR)
%
%  Checks to make sure all numbered TIF files are present in two-photon
%  recording.  Missing files are reported.

b=1;
ds = dirstruct(source);

COPYLIST = {'reference.txt','stims.mat','stimtimes.txt','twophotontimes.txt',...
	'filename.txt','spiketimes.txt'};

T = getalltests(ds);
D = dir(source);

CH = [ 1 2];
CYC = [ 1 2 3];

for i=1:length(D),
	if D(i).name~='.',
		if ~isempty(intersect(D(i).name,T))
			if exist([source filesep D(i).name '-001']),
				for ch=CH, for cyc=CYC,
					fn = dir([source filesep D(i).name '-001' filesep '*Cycle00' int2str(cyc) '*Ch' int2str(ch) '*.tif']);
					count = 0;
					for j=1:length(fn),
						count = count+1;
						if str2num(fn(j).name(end-7:end-4))~=count,
							b=0;
							disp(['File previous to ' fn(j).name ' is missing in ' D(i).name '-001']);
							count = count + 1;
						end;
					end;
				end; end;
			end;
		end;
	end;
end;

clear mex;
