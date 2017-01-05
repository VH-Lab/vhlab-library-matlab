function cells=importcells_bigarrange(path,bigtrial,bundlename,suffix,outputname,replace)
%IMPORTCELLS_BUNDLE stores spike2cell-sorted spikes into Nelsonlab experiment file
%
%   CELLS=IMPORTCELLS_BIGARRANGE(PATH,BIGTRIALDIR,BUNDLENAMES,SUFFIX,...
%         OUTPUTNAME,REPLACE)
%
%       PATH, root directory of experiment data, e.g. /home/data/2002-08-01
%       TRIALS, full trial names, e.g. 't00000'
%       BUNDLENAMES, the names of the bundle recording, e.g., {'lgn'}
%       SUFFIX, empty or `matched' or `merged'
%       OUTPUTNAME, the names of cells in output e.g., {'lgn'} or {'lgn1'}
%       REPLACE 0/1 should we replace data already stored about cells?
%
%   This is a workaround for a small bug in spike2cell that is likely to be
%   fixed soon.  It allows the user to put multiple trials into one directory
%   and extract them.  The one large directory is BIGTRIALDIR.
%   
%  It is assumed that many channels are named with the prefix
%  BUNDLENAME; for example, BUNDLENAME={'lgn'} suggests there are channels
%  named lgn1, lgn2, ....  There can also be more than one bundle name, such
%  as BUNDLENAME={'lgn1_','lgn2_'}, which indicates bundles lgn1_1, lgn1_2, ...
%  and lgn2_1, lgn2_2, ....
%
% note: uses loadcells and transfercells functions
% August 2002, Alexander Heimel, heimel@brandeis.edu
% Modified May/June/August 2004, Steve Van Hooser


try 
  cksds=cksdirstruct(path);
catch
  disp(['importcells: Could not create/open cksdirstruct ' path])
  return
end
%try 
  cells=loadcells(bigtrial,bundlename,cksds,suffix,outputname,replace);
%catch
%  disp(['importcells: Could not load cells of trial ' num2str(trial) ])
%  return
%end
try 
  transfercells(cells,cksds);
catch
  disp(['importcells: Could not transfer cells to cksdirstruct'])
  return
end


return


function cells=loadcells(bigtrial,bundlename,cksds,suffix,outputname,replace)
% LOADCELLS reads spike2cell-spiketable file into spikedata object
%
%   CELLS=LOADCELLS(TRIAL,CKSDS,SUFFIX)
%  
%   SUFFIX can be empty or `merged' or `matched'
%
% note that for deleteexpvar to work
%   name should be changed to namepattern or something els
%   and MClust should not be in the path because of streq 
% 
% Aug 2004, SDV, vanhoosr@brandeis.edu, modified from 
% import_bundle


[px,expf] = getexperimentfile(cksds,1);


bigdirinfo = loadStructArray([getpathname(cksds) filesep ...
		bigtrial filesep 's2cbf.dat']);
if exist('bigdirinfo')~=1,
	disp(['Warning - no s2cbf.dat file, assuming a single test.']);
	   bigdirinfo = struct('test',bigtrial,'num',0);
end;

% load acquisitionfile for sampling frequency samp_dt
ff=fullfile(getpathname(cksds),bigdirinfo(1).test,'acqParams_out');
f=fopen(ff,'r');
fclose(f);  % just to get proper error
acqinfo=loadStructArray(ff);
if bigdirinfo(1).num==0, bigdirinfo(1).num=acqinfo(1).reps; end; % if no file

n_channels=zeros(1,length(bundlename)); ref = zeros(1,length(bundlename));
  % assume user has only included trials with one nameref pair
for k=1:length(bundlename),
	for i=1:size(acqinfo,2)
	  if strncmp(acqinfo(i).name,bundlename{k},length(bundlename{k})),
		ref(k) = acqinfo(i).ref;
	    n_channels(k)=n_channels(k)+1;
	  end;
	end;
end;

disp([num2str(n_channels) ' channels found.']);

if(length(suffix)>0)
     suffix=['.' suffix '.'];
else
  suffix='.'; 
end

spiketable = [];
intervals = [];

% load spiketable

filename = sprintf('%s%s/tet%d%sspiketable',...
	getscratchdirectory(cksds),bigtrial,1,suffix);
spiketableglobal = load(filename,'-ascii');
spiketableglobal(:,1)=spiketableglobal(:,1)*acqinfo(1).samp_dt;
indstampscell = {bigdirinfo.num};
indstamps = cat(2,indstampscell{:});
iscs = [0 cumsum(indstamps)];

ignorefilename = sprintf('%s%s/tet%d.ignore',...
	getscratchdirectory(cksds),bigtrial,k);
try, ignoreclusts=load(ignorefilename,'-ascii')-1; %need -1 b/c index mismatch
catch, ignoreclusts = [];
end;

for k=1:length(bundlename),  % for each bundlename do

  for j=1:length(bigdirinfo),
	  if ~strcmp(bigdirinfo(j).test,'blah'), % cheap workaround if one clusters a dead trial
	  % DON'T load spiketable because there is a global spiketable above
    % load spiketable file for each trial
    %filename=sprintf('%s%s/tet%d%sspiketable',...
	%	   getscratchdirectory(cksds),trials{j},k,suffix);

    %spiketablenew=load(filename,'-ascii');
    %spiketablenew(:,1)=spiketablenew(:,1)*acqinfo(1).samp_dt;

    % correct spiketable for stimulus starttime
    stimsfilename=fullfile(getpathname(cksds),bigdirinfo(j).test,'stims.mat');
    stimsfile=load(stimsfilename);
    intervalnew=[stimsfile.start stimsfile.start+indstamps(j)*10];

	globinds = find(spiketableglobal(:,1)>10*iscs(j)&spiketableglobal(:,1)<=10*iscs(j+1));
	spiketablenew = spiketableglobal(globinds,:);
    spiketablenew(:,1)=spiketablenew(:,1)+stimsfile.start-10*iscs(j);
	disp(['start: ' int2str(10*iscs(j)) ' start: ' int2str(min(spiketablenew(:,1))) '.']);

	inds2ignore = [];
	for i=1:length(ignoreclusts),inds2ignore=[inds2ignore;find(spiketablenew(:,2)==ignoreclusts(i));];end;

	spiketable = [spiketable;spiketablenew(setdiff(1:size(spiketablenew,1),inds2ignore),:)];
	intervals = [intervals; intervalnew];

    if 0, % let's not do this now because I don't understand it yet - SDV
      %load spikes
        filename=sprintf('%s%s/tet%d%sspikes',getscratchdirectory(cksds),trials{j},k,suffix);
        [spikes,before,after]=loadspikes(filename);
        spikewindow=before+after;

      %load shapes
		filename=sprintf('%s%s/tet%d%sshapes.asc',...
		   getscratchdirectory(cksds),trials{j},k,suffix);
        shapes=load(filename,'-ascii');
        shapes=reshape(shapes,spikewindow,size(shapes,1)/spikewindow,size(shapes,2));   
    end;
  end;  % above section should produce a good spike table
  end;

  desc_long='';
  desc_brief='';
  detector_params=[];
  n_classes=max(spiketable(:,2))+1;

 cellnamedel=sprintf('cell_%s_%.4d_*',outputname{k},ref(k));
 %deleteexpvar(cksds,cellnamedel); % delete all old representations
  
  cellnumber=1; % no direct link with classnumber
  for cl=0:n_classes-1,
    data=spiketable(find(spiketable(:,2)==cl),1)';
	cellintervals = intervals;

    if isempty(ignoreclusts)|isempty(find(cl==ignoreclusts)), % only store non-ignored clusters
      %cells(k,cellnumber).spikes=  ...
      %           spikes(:,:,find(spiketable(:,2)==cl));

      %cells(k,cellnumber).shape=shapes(:,:,cl+1);
         % cellname needs to start with 'cell' to be recognized
      % by cksds
	  cksdsname = getfield(load(getexperimentfile(cksds),'name','-mat'),'name');
	  cksdsname(find(cksdsname=='-'))='_';
      cells(k,cellnumber).name=sprintf('cell_%s_%.4d_%.3d_%s',...
	     [outputname{k}],ref(k),cellnumber,cksdsname);
	  %   [bundlename{k} '1'],ref(k),cellnumber,cksdsname);
      cells(k,cellnumber).desc_long=desc_long;
      cells(k,cellnumber).desc_brief=desc_brief;
	  if ~replace,
		  try,
			  oldcell = getfield(load(getexperimentfile(cksds),cells(k,cellnumber).name,'-mat'),...
			  			cells(k,cellnumber).name);
			  oldspikes = get_data(oldcell,[-Inf Inf],2);
			  disp(['Number of old spikes: ' int2str(length(oldspikes)) '.']);
			  for iiii=1:size(intervals,1),
			     oldspikes=oldspikes(find(oldspikes<intervals(iiii,1)|...
				 		oldspikes>intervals(iiii,2)));
			  end;
			  disp(['Number of old spikes after trim: ' int2str(length(oldspikes)) '.']);
			  oldintervals = get_intervals(oldcell);
			  newintervals = sortrows([oldintervals; intervals]);
              [B,I,J]=unique(newintervals,'rows');
			  cellintervals = newintervals(I,:),
			  data = sort([data oldspikes]);
			  disp(['Number of total spikes: ' int2str(length(data)) '.']);
		  catch, disp(['Note: No old cell ' cells(k,cellnumber).name ' found (no replacement).']);
		  end;
	  end;
      cells(k,cellnumber).data=data;
      cells(k,cellnumber).intervals=cellintervals;
      cells(k,cellnumber).detector_params=detector_params;
      %cells(k,cellnumber).trial=trial; % removed because now load over trials
      %not really important but nice for plotting
      cellnumber=cellnumber+1;
	  disp(['Added class ' int2str(cl) '.']);
   end
  end
end

return

function transfercells(cells,cksds)
%TRANSFERCELLS Transfers cells from loadcells to the cksdirstruct
%
%    TRANSFERCELLS(CELLS,CKSDS)
%
% June 2002, Alexander Heimel, heimel@brandeis.edu


n_tetrodes=size(cells,1);
n_cells_per_tetrode=size(cells,2);


for tet=1:n_tetrodes
  for cl=1:n_cells_per_tetrode
    %if ~isempty(cells(tet,cl).shape)  % should be okay
      acell=cells(tet,cl);
      thecell=cksmultipleunit(acell.intervals,acell.desc_long,...
		acell.desc_brief,acell.data,acell.detector_params);
      saveexpvar(cksds,thecell,acell.name,1);
    % end
  end
end

return







function [spikes, before, after]=loadspikes(filename,first,last)
% LOADSPIKES Load spikes from spike2cell file
%
%   [SPIKES, BEFORE, AFTER]=LOADSPIKES(FILENAME,FIRST,LAST)
%
%  (first record is 1) inclusive last
%
% June 2002, Alexander Heimel (heimel@brandeis.edu)


fspikes=fopen(filename,'r');
spikecount=fread(fspikes,1,'int');    
n_channels=fread(fspikes,1,'int');    
before=fread(fspikes,1,'int');
after=fread(fspikes,1,'int');

if nargin==1
  spikes=fread(fspikes,'float');
  spikes=reshape(spikes,before+after,n_channels,spikecount);
  return
end

if nargin==2
  last=spikecount;
end

n_records=last-first+1;
spikewindow=before+after;
recordsize=spikewindow*n_channels;
fseek(fspikes,recordsize*(first-1)*4,'cof');
spikes=fread(fspikes,n_records*recordsize,'float');
spikes=reshape(spikes,spikewindow,n_channels,n_records);

return
