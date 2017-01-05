function psth = tpquickpsth(ds,testname,dataname,cell,cellname,channel,binsize,stepsize)


psth = [];

testasc = findassociate(cell,testname,'','');
fulldirname = [getpathname(ds) filesep testasc.data];

dataasc = findassociate(cell,dataname,'','');

pixelarg.data= {dataasc.data.data};
pixelarg.t = {dataasc.data.t};

pixelindsasoc = findassociate(cell,'pixelinds','','');
pixelarg.listofcells = {pixelindsasoc.data};
pixelarg.listofcellnames = {cellname};

listofcellnames = {cellname};
plotit = 0;

[mydata,myt,myavg,mybins]=...
    prairieviewquickpsthsliding(fulldirname,channel,[],pixelarg,plotit,listofcellnames,binsize,stepsize,0,[]);

psth.avg = myavg; psth.bins = mybins; psth.data = mydata; psth.t = myt;