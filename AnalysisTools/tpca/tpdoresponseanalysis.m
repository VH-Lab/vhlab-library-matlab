function [newcells,cellnames]=tpdoresponseanalysis(ds)

newcells = {}; cellnames = {};

ef = getexperimentfile(ds);

gcells = load(ef,'cell*','-mat'); fn = fieldnames(gcells);
for i=1:length(fn),
	newcells{i} = getfield(gcells,fn{i}); cellnames{i} = fn{i};
end;

finished = zeros(1,length(fn));

ind = 1;

while sum(finished)~=length(fn),
	grpi = [];
	for i=ind:length(fn),
		if strcmp(cellnames{i}(1:end-14),cellnames{ind}(1:end-14))&...
			strcmp(cellnames{i}(end-10:end),cellnames{ind}(end-10:end)),
			grpi = [grpi i];
			finished(i) = 1;
		end;
	end;

	asc = findassociate(newcells{ind},'','',''); % find all associates
	for i=1:length(asc),
		if length(asc(i).type)>3,
			if strcmp(upper(asc(i).type(end-3:end)),'TEST'),
				if strcmp(class(asc(i).data),'char'),
					[asc(i).type ' ' asc(i).data],
					nc=tpmulticellresponseanalysis(asc(i).data,'',...
						[asc(i).type(1:end-4) 'resp'],newcells(grpi),cellnames(grpi),ds,0);
					newcells(grpi) = nc;
					%disp(['Processed ' asc(i).type ' for cell ' cellnames{grpi(1)} '.']);
				elseif strcmp(class(asc(i).data),'cell'), % make a list of values
					assoclists = {}; associnds = {};
					for jj=1:length(asc(i).data),
						[dummy,assoclists{jj},associnds{jj}] = tpmulticellresponseanalysis(asc(i).data{jj},'',...
							[asc(i).type(1:end-4) 'resp'],newcells(grpi),cellnames(grpi),ds,0);
					end;
					for ci = 1:length(grpi), %for each cell recorded here
						newassoc = myassoc('','');
						for j1 = 1:length(assoclists), % loop over all directories
							for k1=1:length(assoclists{j1}), % loop through the list to find assocs for this cell
								if associnds{j1}(k1)==ci, %if we found one for this cell
									%and if we haven't added it yet
									if isempty(intersect({newassoc.type},assoclists{j1}(k1).type)),
										typename = assoclists{j1}(k1).type;
										mydata = {};
										for j2 = 1:length(assoclists),
											foundithere = 0;
											for k2 = 1:length(assoclists{j2}),
												if associnds{j2}(k2)==ci&strcmp(assoclists{j2}(k2).type,typename),
													if ~iscell(assoclists{j2}(k2).data),
														mydata = cat(2,mydata,{assoclists{j2}(k2).data});
													else,
														mydata = cat(2,mydata,assoclists{j2}(k2).data);
													end;
													foundithere = 1;
												end;
											end;
											if ~foundithere, mydata = cat(2,mydata,{[]}); end;
										end;
										newassoc(end+1) = myassoc(typename,{mydata});
										newcells{grpi(ci)} = associate(newcells{grpi(ci)},newassoc(end));
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;

	ind = find(finished==0);
	if length(ind)>1, ind = ind(1); end;
end;

function assoc=myassoc(type,data)
assoc=struct('type',type,'owner','twophoton','data',data,'desc','');
end
