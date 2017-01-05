function b = verifytpdirexp(sourcedir)

% VERIFYTPDIREXP -Make sure all files are present in TP recordings
%
%  B = VERIFYTPDIREXP(SOURCEDIR)
%
%  Checks to make sure all numbered dir files are present in two-photon
%  recording.  Missing files are reported.

b = 1; % assume good until evidence to contrary

ds = dirstruct(sourcedir);

[cells,cellnames]=load2celllist(getexperimentfile(ds),'cell*','-mat');

[dirname,pn] = fileparts(getpathname(ds));

if isempty(pn), pn = dirname; end;

dirnames2check = {};

stacknames = findallstacks(cells);
sd = getscratchdirectory(ds);
stackcellsfound = {};
stackdata = {};
stackcellnames = {};
stackdbcellnames = {};

for i=1:length(stacknames),
    try,
        stackdata{i} = load([fixpath(sd) stacknames{i} '.stack','-mat');
    catch,
        stackdata{i} = [];
        warning('No stack data in the scratch director for stack ' stacknames{i} ' that is referenced by cells in database -- likely means these cells are left over from previous analysis and should be removed.']);
    end;
    if ~isempty(stackdata{i}),
        for j=1:length(stackdata{i}.celllist),
           if strcmp(stackdata{i}.celllist(j).type,'cell'),
                nrs = getnamerefs(ds,stackdata{i}.celllist(j).dirname);
                [dummy,ind] = intersect({nrs.name},'tp');
                stackdbcellnames{end+1} = ['cell_tp_' sprintf('%0.3d',nrs(ind).ref) '_' sprintf('%0.3d',stackdata{i}.celllist(j).index)];
                stackcellnames{end+1} = ['cell ' int2str(stackdata{i}.celllist(j).index) ' ref ' stackdata{i}.celllist(j).dirname];
           end;
        end;
    end;
end;

disp(['Checking relationship between directory response analysis and raw responses']);
for i=1:length(dirnames2check),
    founddir = 0;
    for j=1:length(stacknames),
        try,
            rawfilename = [fixpath(sd) stacknames{j} '_' dirnames2check(i) '_raw'];
            wholefilename = [fixpath(sd) stacknames{j} '_' dirnames2check(i)];
            z = load(rawfilename,'-mat');
            g = load(wholefilename,'-mat');
            founddir = 1;
        catch,
            z = []; g = [];
        end;
        if founddir, % not finding it is not an error necessarily
            if ~eqlen(sort(g.listofcellnames),sort(z.listofcellnames)),
                warning(['Files ' rawfilename ' and ' wholefilename ' do not agree; solution is to re-run analysis in analyzetpdirstack.']);
            end;
        end;
    end;
end;

for i=1:length(cellnames),
  
    disp(['Verifying that cell names are appropriate....']);
    if ~strcmp(pn,cellname2date(cellnames{i}))
        b = 0;
        warning(['Cell ' cellnames{i} ' should not be in directory ' pn '.']);
    end;
    
    A = findassociate(cells{i},'analyzetpstack','','');
    if isempty(A),
        warning(['Cell ' cellnames{i} ' has no stack identity. This is unexpected.']);
    end;
    
    if isempty(intersect(cellnames{i},stackdbcellnames)),
        warning(['Cell ' cellnames{i} ' has no stack record and is probably a stale or misplaced cell. Recommend remove it from database.']);
    end;

    disp(['Verifying that orientation tests correspond to actual directories with orientation data']);
    b = b&direxists(cells{i},cellnames{i},ds,'Best orientation test',{'angle'},1);
    b = b&direxists(cells{i},cellnames{i},ds,'Best OT recovery test',{'angle'},1);
    b = b&direxists(cells{i},cellnames{i},ds,'Best Flash OT recovery test',{'angle'},1);

    % check raw data against raw responses in directory
    
    dirnames2check = unique(cat(2,dirnames2check,conditiondirnames(cell,{'Best orientation test','Best OT recovery test','Best Flash OT recovery test'})));

end;




function dirnames = conditiondirnames(cell,assocnames);
dirnames = {};
for i=1:length(assocnames),
    A = findassociate(cell,assocname,'','');
    if ~isempty(A),
        dirnames = cat(2,dirnames,{A(end)});
    end;
end;
    
function b = direxists(cell,cellname,ds,assocname,whatvaries,prairietoo)
b = 1;
A = findassociate(cell,assocname,'','');
if ~isempty(A),
    if ~isempty(A(end).data),
        %[getpathname(ds) filesep A(end).data],
        %exist([getpathname(ds) filesep A(end).data]),
        if ~(exist([getpathname(ds) filesep A(end).data])==7), b=0; warning(['Cell ' cellname ' record ' assocname ' does not exist on disk: ' [getpathname(ds) filesep A(end).data]]);
        else,
            [ss,mti]=getstimscript(ds,A(end).data);
            whatv = sswhatvaries(ss);
            if ~(whatvaries==whatv),
                b = 0;
                warning(['Cell ' cellname ' stimdata in ' A(end).data ' does not expected type.']);
                warning(['Expected:']); disp(whatvaries); warning('Got:'); disp(whatv);
            end;
        end;
        if prairietoo,
            if ~(exist([getpathname(ds) filesep A(end).data '-001'])==7), b=0; warning(['Cell ' cellname ' record ' assocname ' has no prairie data: ' [getpathname(ds) filesep A(end).data '-001']]); end;
        end;
    end;
end;

