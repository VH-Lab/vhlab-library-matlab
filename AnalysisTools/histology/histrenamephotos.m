function histrenamephotos(inputfile, caps, docheck)

%  HISTRENAMEPHOTOS - Renames photos of brain slices
%
%  HISTRENAMEPHOTOS(INPUTFILE, CAPS, DOCHECK)
%
%  This function copies histology photograph files in the same directory as
%  INPUTFILE to files with new names according to the information in the
%  INPUTFILE.  If DOCHECK is 1, then nothing is done but INPUTFILE is parsed
%  to verify there are no errors.  If DOCHECK is not given, it is assumed to
%  be 0.  Specify CAPS=1 if the file names are in all caps, or 0 if they are
%  in lowercase.  Filenames are assumed to be DSCNXXXX.JPG, where X is the
%  file number to 4 digits.
%  
%  Lines of INPUTFILE can be any of the following:
%
%  date YYYY-MM-DD % indicates pictures are from the date YYYY-MM-DD
%  right           % indicates subsequent pictures are from right hemisphere
%  left            % indicates subsequent pictures are from left hemisphere
%  counter N       % indicates counter on camera is presently at N
%  M X J           % indicates J pictures were taken of slice X of brain chunk M

if nargin>1, chk = docheck; else, chk=0; end;

if chk==0,
	disp(['Checking file first....']);
	histrenamephotos(inputfile,caps,1);
end;

errmsg = '';

[fid,errmsg] = fopen(inputfile);

if fid<0, error(['Could not open ' inputfile ': ' errmsg]); end;

firstcounter = 1; lineno=0;
origline = 0; datestr =''; counter = 0; hem = 'U';
while ~(eqlen(origline,-1)),
	lineno = lineno + 1;
	origline = fgetl(fid); line = origline;
	h = find(line=='%');
	if ~isempty(line)&~isempty(h),line=line(1:(h(1)-1)); end;
    % now check against all input arguments
	ll = length(line);
	if ll>0,
		if ll>=15,
			if strcmp(line(1:4),'date'),
				datestr = line(6:end);
				disp(['Date now ' datestr]);
			else warning(['Cannot interpret line: ' origline]);
			end;
		elseif ll>=9,
			if strcmp(line(1:7),'counter'),
				newcounter=eval([line(9:end)]);
				if ~firstcounter,
					if counter~=newcounter,
						error(sprintf(['Error parsing file ''' inputfile ...
								''' at line %d: '...
							'counters do not agree: %d ~= %d'],...
							lineno,counter,newcounter));
					end;
				end;
				counter = newcounter; firstcounter = 0;
				disp(['Counter now ' int2str(counter) '.']);
			elseif strcmp(line(1:7),'deleted'),
				g = eval(line(8:end));
				disp(['User reports he/she deleted ' int2str(g) ' files.']);
				counter = counter + g;
			else, warning(['Cannot interpret line: ' origline]);
			end;
		elseif strcmp(line,'right'),
				hem='R'; disp(['Hemisphere now right']);
		elseif strcmp(line,'left'),
				hem='L'; disp(['Hemisphere now left']);
		elseif ll>=5, % must be photo line
			g = eval([ '[' line ']' ]);
			if length(g)~=3,
				error(['Could not evaluate line ' origline '.']);
			end;
			for i=1:g(3), % write each picture
				counter = counter + 1;
				oldfname=['dscn' sprintf('%.4d',counter) '.jpg'];
				if caps, oldfname = upper(oldfname); end;
				newfname=...
					[datestr sprintf('_%s_%d_%.3d_%d.jpg',hem,g(1),g(2),i)];
				disp(['File ' oldfname ' goes to ' newfname '.']);
				if ~chk,
					copyfile(oldfname,newfname);
				end;
			end;
		end;
	end;
end;
