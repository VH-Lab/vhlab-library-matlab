function csdPlot(L,H,I,channel_order,start_time,delta)
%csdPlot
%%To plot the LFPs, CSDs, and a 3D Surf Plot from top to bottom for a specific grid. This
%function is used following super_csd.m and after identifying the optimal grid from extreme_CSD.
%It takes in the output arrays 'L','H','I' from super_csd.m.
%
%After identifying the optimal grid in extreme CSD, you will need to define
%the coordinates of the grid. To find the coordinates, use the top left
%corner as the origin, x as the column, and y as the row. x and y are both
%positive values and are not defined for negative values. After defining
%the coordinates for the optimal grid, input the coordinates into
%super_CSD. This ouputs the arrays 'L','H','I'. Take those outputs and use
%them as inputs in this function.
%
%Basically, this function gives you a more detailed view for the
%information related to a specific grid.
%
%Example:
%plotCSD(L,H,I,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6],0.050)
%plotCSD(L,H,I,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16],0.050,25)
%plotCSD(L,H,I,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 1 22 11 21 12 20 13 19 14 18 15 17 16],0,25)
%plotCSD(L,H,I,[10 9 8 7 6 5 4 3 2 1 11 12 13 14 15 16],0)

%%
%Part A: Plotting out the LFPs
size_L = size(L);
rows_L = size_L(1);
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

L_organized = [];

for i = 1:rows_L    %to organize the channels
    L_organized(i,:) = L(channel_order(i),:);
end

s = size(L_organized);
r = s(1);
c = s(2);

figure('Color',[1 1 1])
ha = tight_subplot_dennis(rows_L+1, 1,[0 0], [0 0], [0 0]);  %might need to change

minL0 = min(min(L));
maxL0 = max(max(L));

minL = minL0*1.05;
maxL = maxL0*1.05;

ha = tight_subplot_dennis(r+1,1,[0 0],[0.08 0.08],[0.1 0.1]);  %function downloaded from online MATLAB repository

for i = 1:r+1
    axes(ha(i));
    if i < r+1
        hhha = fill([-start_time -start_time 0 0],[minL maxL maxL minL],[0.85 0.85 0.85]);  %4 points for this grid: (0,minL) (0,maxL) (start_time,minL) (start_time,maxL)  --> then make these lines disappear
        set(hhha,'LineStyle','none') %make the fill lines invisible
        hold on
        hha = plot(T_time,L_organized(i,:),'k-','LineWidth',1);
        ylabel(channel_order(i))    %how do I get this to SHOW?????
    else
        %plot horizontal and vertical scale line & display units
        y1 = [minL0 minL0]; %horizontal line
        x1 = [0.8*max(T_time) max(T_time)];
        y2 = [minL0 maxL0]; %vertical line
        x2 = [0.8*max(T_time) 0.8*max(T_time)];
        plot(x1,y1,'k-',x2,y2,'k-')
    end
    set(gca,'Visible','off')
    axis([-start_time max(T_time) minL maxL])
end

%Labeling the LFP Plot
hb = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.99,'\bf Voltage Response of Electrodes','FontSize',15,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
text(0.5, 0.00,'Time[s]','FontSize',12,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
a = text(0.04, 0.5,'Relative Depth[um]','FontSize',12,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
set(a, 'rotation', 90);

text(0.78,0.06,[num2str((round(((0.2*(max(T_time)+start_time)*1000)))/1000)) ' ms']); %output(0.25*max(T_time))
text(0.59,0.10,[num2str(round(((maxL0+minL0)*1000))/1000) ' mV']); %output(2*maxL)

if start_time > 0
    text(0.16,0.93,'before stim');
    text(0.61,0.93,'after stim');
end

%%
%Part B: Plotting out the CSDs

s1 = size(H);

rows = s1(1);

figure('Color',[1 1 1])

minH0 = min(min(H));
maxH0 = max(max(H));

minH = minH0*1.05;
maxH = maxH0*1.05;

hc = tight_subplot_dennis(rows+2,1,[0 0],[0.08 0.08],[0.1 0.1]);  %function downloaded from online MATLAB repository

for i = 1:(rows+2)
    axes(hc(i));
    if i <= rows
        hhhc = fill([-start_time -start_time 0 0],[minH maxH maxH minH],[0.85 0.85 0.85]);  %plotting the gray shading: 4 points for this grid: (0,minL) (0,maxL) (start_time,minL) (start_time,maxL)  --> then make these lines disappear
        set(hhhc,'LineStyle','none') %make the fill lines invisible
        hold on
        Hvalue = H(i,:);
        plot(T_time,Hvalue,'k-','LineWidth',1)  %plotting the CSD signal
        hold on
        zeroy = zeros(1,length(H(i,:)));    %plotting the flat line
        plot(T_time,zeroy,'k-')
        hold on
        for j = 1:(length(Hvalue)-1) %loop for plotting the black shading: iterate through all values of H(j) -- approx. 46 iterations
            if (Hvalue(j) <= 0) && (j ~= 1) && (j <= length(Hvalue)-2)
                x = [T_time(j-1) T_time(j)];
                a = [0 0];  %THE JBFILL NEEDS TO BE SHIFTED LEFT EXACTLY 1 UNIT
                b = [Hvalue(j-1) Hvalue(j)];
                color = [0 0 0];    %black color shading; [1 1 1] is white color shading
                edge = [0 0 0];
                add = 0;
                transparency = 1;
                jbfill(x,a,b,color,edge,add,transparency);
                hold on
                if (j == length(Hvalue)-2)
                    x = [T_time(j) T_time(j+1)];
                    a = [0 0];  %THE JBFILL NEEDS TO BE SHIFTED LEFT EXACTLY 1 UNIT
                    b = [Hvalue(j) Hvalue(j+1)];
                    color = [0 0 0];    %black color shading; [1 1 1], the exact opposite, is white color shading
                    edge = [0 0 0];
                    add = 0;
                    transparency = 1;
                    jbfill(x,a,b,color,edge,add,transparency);
                    hold on
                end
            elseif (Hvalue(j) <= 0) && (j > length(Hvalue)-2)
                x = [T_time(j) T_time(j+1)];
                a = [0 0];  %THE JBFILL NEEDS TO BE SHIFTED LEFT EXACTLY 1 UNIT
                b = [Hvalue(j) Hvalue(j+1)];
                color = [0 0 0];    %black color shading; [1 1 1] is white color shading
                edge = [0 0 0];
                add = 0;
                transparency = 1;
                jbfill(x,a,b,color,edge,add,transparency);
                hold on
            end
        end
        ylabel(i*100);
    elseif i == (rows+1)
        plot(T_time,(ones(1,length(T_time)).*(-0.1*minH)),'k-')
    else    %if i == (rows+2) || i == (rows+2)
        y3 = [minH0 minH0]; %horizontal line
        x3 = [0.8*max(T_time) max(T_time)];
        y4 = [minH0 maxH0]; %vertical line
        x4 = [0.8*max(T_time) 0.8*max(T_time)];
        plot(x3,y3,'k-',x4,y4,'k-')
    end
    set(gca,'Visible','off')
    axis([-start_time max(T_time) minH maxH]);
end

%Labeling the CSD Plot
hd = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.99,'\bf CSDs for Channels','FontSize',15,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
%text(0.5, 0.10,'Time[s]','FontSize',12,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
a = text(0.04, 0.5,'Relative Depth[um]','FontSize',12,'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
set(a,'rotation',90);


text(0.78,0.06,[num2str(round(0.2*(max(T_time)+start_time)*1000)/1000) ' ms']); %output(0.25*max(T_time))
text(0.55,0.10,[num2str((round((maxH0+maxH0)))) ' V/m^2']); %the values are too big and might need to change units to V/mm^2

text(0.09,0.11,'sink'); %output(0.25*max(T_time))
text(0.09,0.13,'source'); %output(0.25*max(T_time))

if start_time > 0
    text(0.16,0.93,'before stim');
    text(0.61,0.93,'after stim');
end

%% Part C: Plotting out the 2D Pcolor Heat Map for CSDs

%Work to be done: Need to flip over the y axes...*****

figure('Color',[1 1 1])
size_I = size(I);
rows_I = size_I(1);
columns_I = size_I(2);

Y = [];

for i = 1:rows_I
    Y(i) = (i-1)*delta;
end

X = [];

X(1:length(T_time)) = T_time;
X(length(T_time)+1) = X(length(T_time))+83/25000;   %if fast read frame changes, this needs to change --- might be helpful to implement a function here

pp = pcolor(X,Y,I);

max_diff_from_zero = max(abs(I(:)));
shading interp
set(gca,'ydir','reverse');
mymap = jet(256);
invert_map = mymap(256:-1:1,:);
colormap(invert_map);

box off
shading interp;
set(gca,'ydir','reverse');
caxis(max_diff_from_zero*[-1 1]);

hold on

y = [0 max(Y)];
x = [0 0];

plot(x,y,'k-','LineWidth',2)

cmin = min(min(H));
cmax = max(max(H));

title('3D Heat Map for CSDs')
xlabel('time [s]')
ylabel('relative depth [um]')
zlabel('CSD amplitude')
h = colorbar;
ylabel(h,'V/m^2')

%% Part D: Plotting out the 3D Surf Heat Map for CSDs

%Work to be done: Need to flip over the y axes...*****

figure('Color',[1 1 1])
size_I = size(I);
rows_I = size_I(1);
columns_I = size_I(2);

Y = [];

for i = 1:rows_I
    Y(i) = (i-1)*delta;
end

X = [];

X = T_time;
X(1:length(T_time)) = T_time;
X(length(T_time)+1) = X(length(T_time))+83/25000;  %if fast read frame changes, this needs to change --- might be helpful to implement a function here 

surf(X,Y,I,'EdgeColor','none')
max_diff_from_zero = max(abs(I(:)));
shading interp
set(gca,'ydir','reverse');
mymap = jet(256);
invert_map = mymap(256:-1:1,:);
colormap(invert_map);
caxis(max_diff_from_zero*[-1 1]);
hold on

%plot zero line that does not get blocked by the CSD plots
for i = 1:length(X)    %search for the index of Xvalue that is closest to zero and input it into x_zero
    seta(i) = abs(X(i)-0);
end

zeroval = min(seta);

for i = 1:length(seta)
    if seta(i) == zeroval
        x_zero = i;
    end
end

for i = 1:rows_I-1
    Ibeforerow = I(i,:);
    Iafterrow = I(i+1,:);
    zbefore = Ibeforerow(x_zero);
    zafter = Iafterrow(x_zero);
    x = [X(x_zero) X(x_zero)];   %a slight discrepancy should be unnoticable and insignificant for viewing purposes
    y = [(i-1)*delta (i)*delta];
    plot3(x,y,[zbefore zafter],'k-','LineWidth',2)
    hold on
end

cmin = min(min(H));
cmax = max(max(H));


title('3D Heat Map for CSDs')
xlabel('time [s]')
ylabel('relative depth [um]')
zlabel('CSD amplitude')
h = colorbar;
ylabel(h,'V/m^2')

end

%To Do List:
%4. CONFIRM IF CSDMAPPING IS GOOD WITH PLOTCSD PLOTTING OUT 4 FIGURES
%5. TEST WITH DUMMY SHORT FUNCTION --> TEST THIS ON CSDMAPPING
%6. INTEGRATE RESUME INTO CSDMAPPING

%##labeling the depth on the LFP and CSD graph -- more like getting them to
%show without the axes showing

%##integrate start_time into CSDmapping

%NEED TO MAKE THE 0.150/ceil(25000*0.150/83) portion an input from outputs
%of other functions!!!!!!!!!!!!
