function plotintrinsicframes(dirname, stimnum)

g = load([dirname filesep 'stimorder']);

im0 = imread([dirname filesep 'trig0000_frame0000.tiff']); 

d = find(g.stimorder==stimnum);

% reads first 10 data frames per trigger

i = 1;
while i<=(length(d)),
    framestart = i;
    im_ = zeros(10*size(im0,1),10*size(im0,2));
    for j=1:10,
        if i<=length(d),
            for k=1:10,
                im = imread([dirname filesep 'trig' sprintf('%0.4d',d(i)-1) '_frame' sprintf('%0.4d',k-1) '.tiff']);
                    im_(1+(j-1)*size(im0,1):j*size(im0,1),1+(k-1)*size(im0,2):k*size(im0,2))=im;
            end;
        end;
        i = i + 1;
    end;
    frameend = i;
    imagedisplay(im_,'fig',0);
    title(['Extracted stims ' int2str(framestart) ' to ' int2str(frameend)]);
    r = input('Press return to continue...');
    close(gcf);
end;

