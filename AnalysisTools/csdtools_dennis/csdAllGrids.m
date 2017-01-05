function csdAllGrids(X,rows,columns,delta,channel_order,start_time,path,tfile)
%csdAllGrids
%Plots out CSDs for all 300 grids.
%
%Example:
%extreme_csd(X,15,20,100,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6],0.050)
%extreme_csd(Xw2b,10,10,25,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16],0,'/Users/dennisou/Desktop/','t00001')
%extreme_csd(X,10,10,25,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 1 22 11 21 12 20 13 19 14 18 15 17 16],0)
%extreme_csd(X_new,10,10,50,[10 9 8 7 6 5 4 3 2 1 11 12 13 14 15 16],0.050)
%
%[L,H,I] = super_csd(X_new,100,50,[10 9 8 7 6 5 4 3 2 1 11 12 13 14 15 16])

special_tfile = [tfile '/'];
sync_channel = determine_sync_channel(path,special_tfile);  %32
sync_channel_position = 0;
for i = 1:length(channel_order)
    if channel_order(i) == sync_channel
        sync_channel_position = i;
    end
end
if sync_channel_position ~= 0
    above_sync = channel_order(sync_channel_position-1);
    below_sync = channel_order(sync_channel_position+1);
    channel_order(sync_channel_position) = [];
end

S = [];
minCSD = zeros(1,rows*columns);
maxCSD = zeros(1,rows*columns);

for i = 1:rows*columns  %iterates 300 times and i = grid numbers which also equates to columns in the X cell
    [L,H,I] = super_csd_interp(X,i,delta,channel_order,sync_channel_position,above_sync,below_sync);   %need to output all three outputs of super_csd since what we need is the output I which is the last one
    %super_csd_interp(X,gridloc,delta,channel_order,sync_channel_position,above_sync,below_sync)
    S(:,:,i) = I;  %S is a 14 by 31 by 300 array
    display(i);  %should end at 300
    minCSD(i) = min(min(H));
    maxCSD(i) = max(max(H));
end

trueminCSD = min(minCSD);
truemaxCSD = max(maxCSD);
truescale = max([abs(trueminCSD) abs(truemaxCSD)]);

%The following block creates the time axis for each of the grid CSD plots
size_L = size(L);   %the L here would of course be the L for the last grid, be it 300 or 100.
columns_L = size_L(2);
xaxis = 1:columns_L;   %if this were to be used as a testing function, use 1:10; otherwise, ignore the 1:10.
Ttime = xaxis * 83/25000;  %To convert the data points 1:31 to 1 to 100ms or 0.1s. The 83 comes from the fastread downsampling function which is called on by Super2.
TTtime(1) = 0;
TTtime(2:length(Ttime)+1) = Ttime;
T_time = [];    %an optimization step would be to preallocate initally with zeros
for i = 1:length(TTtime)
    T_time(i) = TTtime(i) - start_time;
end
T_time = T_time(1:end-1);
XX(1:length(T_time)) = T_time;
XX(length(T_time)+1) = XX(length(T_time))+83/25000;   %if fast read frame changes, this needs to change --- might be helpful to implement a function here

%The following block creates the depth axis for each of the grid CSD plots
size_I = size(I);   %the I here would of course be the I for the last grid, be it 300 or 100.
rows_I = size_I(1);
Y = [];
for i = 1:rows_I
    Y(i) = i*delta;
end


%QUESTION: ***Why does this go so fast when i <= 10 and so slow once i >
%10??????? maybe memory is accumulated and thus slows things down over time?

figure();
count = 1;
for i = 1:rows  %iterates 15 times
    for j = 1:columns   %iterates 20 times
        gridloc = coordinates_to_grid(j,i,rows);    %gridloc = grid# increases from top to bottom then left to right
        subplot(rows,columns,count);
        pcolor(XX,Y,S(:,:,gridloc)); %used pcolor rather than surf here because the 3D functionality is not needed
        hold on
        y = [0 max(Y)];
        x = [0 0];
        plot(x,y,'k-','LineWidth',1)
        set(gca,'ydir','reverse');
        caxis([trueminCSD truemaxCSD]);
        mymap = jet(256);
        invert_map = mymap(256:-1:1,:);
        colormap(invert_map);
        caxis(truescale*[-1 1]);
        shading interp    %can be changed to other types of shading for potentially better viewing
        count = count + 1;
        display(i)  %should end at 15
        display(j)  %should end at 20
    end
end

end