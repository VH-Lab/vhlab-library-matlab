function b = makeminidirstruct(source, destination, varargin)

% MAKEMINITPDIRSTRUCT-Make a small version of a two-photon directory structure
%
%  B = MAKEMINIDIRSTRUCT(SOURCEDIR, DESTINATIONDIR)
%
%  Makes a reduced copy of a DIRSTRUCT directory.  Files are copied
%  from SOURCEDIR to DESTINATIONDIR. The files reference.txt and any 
%  non-test directories are included in the copy.

b=1;
ds = dirstruct(source);

try, mkdir(destination);
catch, 
	b=0;
	error(['Directory ' destination ' could not be created: ' lasterr '.']);
end;

COPYLIST = {'reference.txt','stims.mat','stimtimes.txt','twophotontimes.txt',...
	'filename.txt','spiketimes.txt','filetime.txt'};

COPYLIST_wild = {'*.mat'};

T = getalltests(ds);
D = dir(source);

for i=1:length(D),
	if D(i).name~='.',
		if ~isempty(intersect(D(i).name,T))
			mkdir([destination filesep D(i).name]);
			sd = [source filesep D(i).name filesep];
			dst= [destination filesep D(i).name filesep];
			for g=1:length(COPYLIST),
				if exist([sd COPYLIST{g}])
					copyfile([sd COPYLIST{g}],[dst COPYLIST{g}]);
				end;
			end;
			for g=1:length(COPYLIST_wild),
				fn = dir([sd COPYLIST_wild{g}]);
				for gg=1:length(fn),
					copyfile([sd fn(gg).name],[dst fn(gg).name]);
				end;
			end;
			if exist([source filesep D(i).name '-001']),
				mkdir([destination filesep D(i).name '-001']);
				fn = dir([source filesep D(i).name '-001' filesep '*.tif']);
				for j=1:length(fn),
					if str2num(fn(j).name(end-7:end-4))<=50,
						copyfile([source filesep D(i).name '-001' filesep fn(j).name],...
							[destination filesep D(i).name '-001' filesep fn(j).name]);
					end;
				end;
				% now copy all non-tifs
				fn = dir([source filesep D(i).name '-001' filesep '*']);
				for j=1:length(fn),
					if isempty(strfind(fn(j).name,'tif'))&~strcmp(fn(j).name,'.')&~strcmp(fn(j).name,'..'),
						copyfile([source filesep D(i).name '-001' filesep fn(j).name],...
							[destination filesep D(i).name '-001' filesep fn(j).name]);
					end;
				end;
			end;
		else,
			docopy = 1;
			if length(D(i).name)>4,
				if strcmp(D(i).name(end-3:end),'-001')&~isempty(intersect(D(i).name(1:end-4),T)),
					docopy = 0;
				end;
			end;
			if docopy, copyfile([source filesep D(i).name],[destination filesep D(i).name]); end;
		end;
	end;
end;

% for debugging
%function copyfile(src,dst)
%disp(['Would have copied ' src ' to ' dst '.']);
