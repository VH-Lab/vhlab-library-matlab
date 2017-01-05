function loop_intrinsic( dirname, rangelow, rangehigh )
%LOOP_INTRINSIC Loop a set of intrinsic signal images
%
%   LOOP_INTRINSIC(DIRNAME, RANGELOW, RANGEHIGH)
%
%   Loops through the non-blank single condition images of the 
%   intrinsic image directory DIRNAME (provide the full pathname).  
%
%   The images are scaled from RANGELOW to RANGEHIGH
%   (for example, one might use -0.0001 and 0.0001)
%
%   The function loops until the user hits CONTROL-C to stop
%   execution.

d = dir([fixpath(dirname) 'singlecondition0*.mat']);

img = {};

for i=1:length(d), 
    g = load([fixpath(dirname) d(i).name]);
    img{i} = rescale(g.imgsc,[rangelow rangehigh],[0 255]);
end;

figure;
colormap(gray(256));

i = 0;

while 1,
    i = 1 + mod(i,length(img)-1); % leave out blank image
    image(img{i});
    pause(0.5);
end;

end

