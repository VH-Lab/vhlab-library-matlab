function csdGUI
% csdGUI    Plots out CSD via graphic user interface.
%   This function allows the user to operate the interface without any requirement of
%   coding knowledge. The current limitations of this GUI is that only one
%   type of transition can be run in one trial and the resume function is
%   not incorporated yet. In future releases, we expect these additional
%   functions to be incorporated.

%% Clear everything
clear all;
close all;
clear mex;
clc;

%% Setting up the GUI space
window = figure(1);
set(window,'Position',[0 0 1400 750]);
window_positioned = get(window,'Position');
w = window_positioned(3);
h = window_positioned(4);

%% GUI entry boxes setup
%path, tbefore, num_channels, channels
uicontrol('Style','Text','Position',[(1150/1400)*w (525/750)*h (100/1400)*w (25/750)*h],'String','Parameter Entry','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

path_entry = uicontrol('Style','Edit','Position',[(1100/1400)*w (500/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1],'string','/Users/dennisou/Desktop/');
uicontrol('Style','Text','Position',[(1050/1400)*w (500/750)*h (50/1400)*w (25/750)*h],'String','path','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

tfile_entry = uicontrol('Style','Edit','Position',[(1250/1400)*w (500/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1],'string','t00001');
uicontrol('Style','Text','Position',[(1200/1400)*w (500/750)*h (50/1400)*w (25/750)*h],'String','tfile','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

tbefore_entry = uicontrol('Style','Edit','Position',[(1100/1400)*w (450/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1],'string','0');
uicontrol('Style','Text','Position',[(1050/1400)*w (450/750)*h (50/1400)*w (25/750)*h],'String','tbefore[s]','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

tafter_entry = uicontrol('Style','Edit','Position',[(1250/1400)*w (450/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1],'string','0.100');
uicontrol('Style','Text','Position',[(1200/1400)*w (450/750)*h (50/1400)*w (25/750)*h],'String','tafter[s]','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

num_channels_entry = uicontrol('Style','Edit','Position',[(1100/1400)*w (400/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1]);
uicontrol('Style','Text','Position',[(1050/1400)*w (400/750)*h (50/1400)*w (25/750)*h],'String','num_channels','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

channel_order_entry = uicontrol('Style','Edit','Position',[(1250/1400)*w (400/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1]);
uicontrol('Style','Text','Position',[(1200/1400)*w (400/750)*h (50/1400)*w (25/750)*h],'String','channel_order','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

channels_entry = uicontrol('Style','Edit','Position',[(1100/1400)*w (350/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1]);
uicontrol('Style','Text','Position',[(1050/1400)*w (350/750)*h (50/1400)*w (25/750)*h],'String','channels','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

delta_entry = uicontrol('Style','Edit','Position',[(1250/1400)*w (350/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 1 1]);
uicontrol('Style','Text','Position',[(1200/1400)*w (350/750)*h (50/1400)*w (25/750)*h],'String','delta[um]','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

%% setting up the subfigures template
%For csdAllGrids_GUI function output
csdAllGrids_template = uicontrol('Style','Text','Position',[(25/1400)*w (325/750)*h (400/1400)*w (400/750)*h],'String','CSD for all grids','FontSize',12,'BackgroundColor',[1 1 1]);

%For csdPlot_GUI function output
LFP_template = uicontrol('Style','Text','Position',[(25/1400)*w (25/750)*h (150/1400)*w (275/750)*h],'String','LFP for selected grid','FontSize',12,'BackgroundColor',[1 1 1]);
CSD_template = uicontrol('Style','Text','Position',[(250/1400)*w (25/750)*h (150/1400)*w (275/750)*h],'String','CSD for selected grid','FontSize',12,'BackgroundColor',[1 1 1]);
pcolor_template = uicontrol('Style','Text','Position',[(500/1400)*w (35/750)*h (350/1400)*w (340/750)*h],'String','CSD Pcolor for selected grid','FontSize',12,'BackgroundColor',[1 1 1]);
surf_template = uicontrol('Style','Text','Position',[(500/1400)*w (390/750)*h (350/1400)*w (350/750)*h],'String','CSD Surf for selected grid','FontSize',12,'BackgroundColor',[1 1 1]);

%% Setting up the loading and additional options
uicontrol('Style','popup','Position',[(910/1400)*w (510/750)*h (120/1400)*w (1/750)*h],'String','----------|32 Channel','Callback',{@selection,num_channels_entry,channel_order_entry,channels_entry,delta_entry});
uicontrol('Style','Text','Position',[(910/1400)*w (510/750)*h (120/1400)*w (20/750)*h],'String','Electrode selection','BackgroundColor',[0.8 0.8 0.8]);

w2bb2w_checkbox_w2b = uicontrol('Style','checkbox','Position',[(1125/1400)*w (300/750)*h (50/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);
uicontrol('Style','Text','Position',[(1075/1400)*w (300/750)*h (50/1400)*w (25/750)*h],'String','w2b','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

w2bb2w_checkbox_b2w = uicontrol('Style','checkbox','Position',[(1200/1400)*w (300/750)*h (50/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);
uicontrol('Style','Text','Position',[(1150/1400)*w (300/750)*h (50/1400)*w (25/750)*h],'String','b2w','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

uicontrol('Style','text','Position',[(1175/1400)*w (250/750)*h (100/1400)*w (25/750)*h],'String','CSD Analysis','FontSize',12,'BackgroundColor',[0.8 0.8 0.8])

file_exist_light_w2b = uicontrol('Style','text','Position',[(1100/1400)*w (200/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 0 0]);   %lights up green if there is already a present file
file_exist_light_w2b_text = uicontrol('Style','Text','String','txxxxxw2b exists','Position',[(1100/1400)*w (225/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);

file_exist_light_b2w = uicontrol('Style','text','Position',[(1250/1400)*w (200/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 0 0]);
file_exist_light_b2w_text = uicontrol('Style','Text','String','txxxxxb2w exists','Position',[(1250/1400)*w (225/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);

load_file_light_w2b = uicontrol('Style','text','Position',[(1100/1400)*w (125/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 0 0]);    %checks if t00001w2b or t00001b2w has been loaded
load_file_light_w2b_text = uicontrol('Style','Text','String','txxxxxw2b loaded','Position',[(1100/1400)*w (150/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);

load_file_light_b2w = uicontrol('Style','text','Position',[(1250/1400)*w (125/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[1 0 0]);
load_file_light_b2w_text = uicontrol('Style','Text','String','txxxxxb2w loaded','Position',[(1250/1400)*w (150/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8]);

%% Data Information Display
info = uicontrol('Style','Text','Position',[(1150/1400)*w (700/750)*h (100/1400)*w (25/750)*h],'String','Data Information','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

line1 = uicontrol('Style','Text','Position',[(1025/1400)*w (680/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line2 = uicontrol('Style','Text','Position',[(1025/1400)*w (660/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line3 = uicontrol('Style','Text','Position',[(1025/1400)*w (640/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line4 = uicontrol('Style','Text','Position',[(1025/1400)*w (620/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line5 = uicontrol('Style','Text','Position',[(1025/1400)*w (600/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line6 = uicontrol('Style','Text','Position',[(1025/1400)*w (580/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);
line7 = uicontrol('Style','Text','Position',[(1025/1400)*w (560/750)*h (325/1400)*w (20/750)*h],'BackgroundColor',[1 1 1]);

%% Notification Displays
%status title
uicontrol('Style','Text','String','Status','Position',[(900/1400)*w (700/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8],'FontSize',11);

%display that outputs whether b2w or w2b is the proper transition
display1 = uicontrol('Style','Text','Position',[(900/1400)*w (660/750)*h (100/1400)*w (40/750)*h],'BackgroundColor',[1 1 1],'String','Transition of interest','FontSize',11);

%display that outpus status of data processing
display2 = uicontrol('Style','Text','String','The data processing has not yet begun.','Position',[(900/1400)*w (610/750)*h (100/1400)*w (40/750)*h],'BackgroundColor',[1 1 1],'FontSize',11);

%display that outputs the status of CSD analysis
display3 = uicontrol('Style','Text','String','The CSD analysis has not yet begun.','Position',[(900/1400)*w (560/750)*h (100/1400)*w (40/750)*h],'BackgroundColor',[1 1 1],'FontSize',11);

%layer 4 information title
uicontrol('Style','Text','String','CSD Results','Position',[(925/1400)*w (450/750)*h (100/1400)*w (25/750)*h],'BackgroundColor',[0.8 0.8 0.8],'FontSize',11)

%display that outputs the depth of layer 4
display4 = uicontrol('Style','Text','String','Layer 4 Information','Position',[(875/1400)*w (390/750)*h (170/1400)*w (65/750)*h],'BackgroundColor',[1 1 1]);

%display that outputs the actual depth of each channel
display5 = uicontrol('Style','Text','String','Actual depth of all channels','Position',[(875/1400)*w (25/750)*h (170/1400)*w (360/750)*h],'BackgroundColor',[1 1 1]);

%% Process data push button
uicontrol('Style','pushbutton','Position',[(1250/1400)*w (285/750)*h (100/1400)*w (25/750)*h],'String','Process Data','Callback',{@run_csdDataProcessing,path_entry,tfile_entry,...
    tbefore_entry,tafter_entry,num_channels_entry,channel_order_entry,channels_entry,delta_entry,w2bb2w_checkbox_w2b,w2bb2w_checkbox_b2w,display2,file_exist_light_w2b,file_exist_light_b2w});

%% Display Information Button
uicontrol('Style','pushbutton','Position',[(1250/1400)*w (315/750)*h (100/1400)*w (25/750)*h],'String','Display Information','Callback',{@display_data_information,line1,line2,line3,line4,line5,line6,line7,path_entry,tfile_entry,display1,file_exist_light_w2b,file_exist_light_b2w,file_exist_light_w2b_text,file_exist_light_b2w_text,...
    load_file_light_w2b_text,load_file_light_b2w_text})

%% Done push button
done_button = uicontrol('Style','pushbutton','Position',[(1250/1400)*w (25/750)*h (125/1400)*w (25/750)*h],'String','Analysis Done','Callback',{@done});

%% Load existing file push button
uicontrol('Style','pushbutton','Position',[(1100/1400)*w (75/750)*h (125/1400)*w (25/750)*h],'String','Load existing w2b data','Callback',{@load_w2b_file,load_file_light_w2b,load_file_light_b2w,path_entry,tfile_entry,LFP_template,CSD_template,pcolor_template,surf_template,csdAllGrids_template,display3,info,display4,display5,done_button});
uicontrol('Style','pushbutton','Position',[(1250/1400)*w (75/750)*h (125/1400)*w (25/750)*h],'String','Load existing b2w data','Callback',{@load_b2w_file,load_file_light_b2w,load_file_light_w2b,path_entry,tfile_entry,LFP_template,CSD_template,pcolor_template,surf_template,csdAllGrids_template,display3,info,display4,display5,done_button});

%% Run loaded push button
uicontrol('Style','pushbutton','Position',[(1100/1400)*w (25/750)*h (125/1400)*w (25/750)*h],'String','CSD Analysis','Callback',{@run_loaded,load_file_light_w2b,load_file_light_b2w,path_entry,tfile_entry,...
    tbefore_entry,tafter_entry,num_channels_entry,channel_order_entry,channels_entry,delta_entry,csdAllGrids_template,window,LFP_template,CSD_template,pcolor_template,surf_template,window_positioned,done_button,display3,display4,display5,info});

%% Help Button
uicontrol('Style','pushbutton','Position',[(1300/1400)*w (715/750)*h (100/1400)*w (25/750)*h],'String','Help','Callback',{@help});

end

%% Callback Functions
function help(object_handle,event)
web('https://sites.google.com/site/vhlabtools/data-analysis/zspecific-studies/csd-analysis/csd-gui')
end

function selection(object_handle,event,num_channels_entry,channel_order_entry,channels_entry,delta_entry)
    switch get(object_handle,'Value')  %we are dealing with 32 channel electrode
        case 1 %default
            set(num_channels_entry,'String','')
            set(channel_order_entry,'String','')
            set(channels_entry,'String','')
            set(delta_entry,'String','')
        case 2 %32 channel electrode
            set(num_channels_entry,'String','32')
            set(channel_order_entry,'String','[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16]')
            set(channels_entry,'String','2:32')
            set(delta_entry,'String','25')
    end
end

function display_data_information(object_handle,event,line1,line2,line3,line4,line5,line6,line7,path_entry,tfile_entry,display1,file_exist_light_w2b,file_exist_light_b2w,file_exist_light_w2b_text,file_exist_light_b2w_text,...
    load_file_light_w2b_text,load_file_light_b2w_text)
    path = get(path_entry,'string');
    tfile = get(tfile_entry,'string');
    location = [path tfile];
    current = pwd;
    cd(location)
    
    textcell = {};
    fid = fopen('vhlvanaloginput.vlh');
    tline = fgetl(fid);
    textcell{1} = tline;
    linecount = 2;
    while ischar(tline)
        tline = fgetl(fid);
        textcell{linecount} = tline;
        linecount = linecount + 1;
    end
    fclose(fid);
    cd(current);
    
    set(line1,'string',textcell{1})
    set(line2,'string',textcell{2})
    set(line3,'string',textcell{3})
    set(line4,'string',textcell{4})
    set(line5,'string',textcell{5})
    set(line6,'string',textcell{6})
    set(line7,'string',textcell{7})
    
    checkw2bb2w(path,tfile,display1)
    
    set(file_exist_light_w2b_text,'string',[get(tfile_entry,'string') 'w2b exists'])
    set(file_exist_light_b2w_text,'string',[get(tfile_entry,'string') 'b2w exists'])
    
    set(load_file_light_w2b_text,'string',[get(tfile_entry,'string') 'w2b loaded'])
    set(load_file_light_b2w_text,'string',[get(tfile_entry,'string') 'b2w loaded'])
    
    cd(location)
    if (exist([tfile 'w2b.mat']) == 2)
        set(file_exist_light_w2b,'BackgroundColor',[0 1 0])
    end
    if (exist([tfile 'b2w.mat']) == 2)
    set(file_exist_light_b2w,'BackgroundColor',[0 1 0])
    end
    cd(current);
end

function done(object_handle,event)
% done
%  Terminates the CSD Analysis 
set(object_handle,'UserData',1)

end

function run_csdDataProcessing(object_handle,event,path_entry,tfile_entry,...
    tbefore_entry,tafter_entry,num_channels_entry,channel_order_entry,channels_entry,delta_entry,w2bb2w_checkbox_w2b,w2bb2w_checkbox_b2w,display2,file_exist_light_w2b,file_exist_light_b2w)
%% Assigning the values from the edit boxes on the GUI to the relevant variables
path = get(path_entry,'string');
tfile = get(tfile_entry,'string');
tbefore = str2double(get(tbefore_entry,'string'));    %we use str2double here because it works the fastest
tafter = str2double(get(tafter_entry,'string'));
num_channels = str2double(get(num_channels_entry,'string'));
channel_order = str2num(get(channel_order_entry,'string'));   %we use str2num here because str2double doesn't work on arrays
channels = str2num(get(channels_entry,'string'));   %we use str2num here because str2double doesn't work on arrays
delta = str2double(get(delta_entry,'string'));

%Update display status
set(display2,'String','The data analysis is running...')

%% Checking the vhlv_sync2spike2 function and fixing it if there is a problem
fprintf('\nrunning vhlv_sync2spike2 check...\n')    %alerts user that the vhlv_sync2spike2 will commence
%Potential creation of vhlv_syncchannel.txt file if sync channel is the
%first channel. There is no need to create a text file if the sync channel
%is the last channel as that is assumed by default.
location = [path tfile];
text = fileread([location '/vhlvanaloginput.vlh']);
space_array = isspace(text);
for i = 1:length(space_array)
    if space_array(i) == 1
        start_index = i+1;
        break;
    end
end
if strcmp(text(start_index:24),'Dev1/ai31') %could perfect this portion by parsing and determining individual channel
    copyfile('vhlv_syncchannel.txt',location)
end
%Quick double check on vhlv_sync2spike2()
vhlv_sync2spike2(location); %can eventually eliminate running this function again in the csdDataProcessing function.
fprintf('\nvhlv_sync2spike2 check successful!\n') %alerts the user that the vhlv_sync2spike2 is successful

%% Extracting the number of rows and columns straight from the data
current = pwd;
cd(location);
%extracting the rows and columns parameters directly from the data
g = load('stims.mat');
p = getparameters(get(g.saveScript,1));
rows = (p.rect(4))/(p.pixSize(2));
columns = (p.rect(3))/(p.pixSize(1));
cd(current);

%% Running csdDataProcessing
if (get(w2bb2w_checkbox_w2b,'Value') == 1) && (get(w2bb2w_checkbox_b2w,'Value') == 1)
    csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,0,1,rows,columns);
    csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,1,1,rows,columns);
elseif (get(w2bb2w_checkbox_w2b,'Value') == 1) && (get(w2bb2w_checkbox_b2w,'Value') == 0)
    csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,0,1,rows,columns);
elseif (get(w2bb2w_checkbox_w2b,'Value') == 0) && (get(w2bb2w_checkbox_b2w,'Value') == 1)
    csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,1,1,rows,columns);
else
    error('You need to check either w2b or b2w or both')
end

%Update display status
set(display2,'String','The data analysis is complete!')

%Update the exists lights again
cd(location);
if (exist([tfile 'w2b.mat']) == 2)
    set(file_exist_light_w2b,'BackgroundColor',[0 1 0])
end
if (exist([tfile 'b2w.mat']) == 2)
    set(file_exist_light_b2w,'BackgroundColor',[0 1 0])
end
cd(current);

end

function load_w2b_file(object_handle,event,load_file_light_w2b,load_file_light_b2w,path_entry,tfile_entry,LFP_template,CSD_template,pcolor_template,surf_template,csdAllGrids_template,display3,info,display4,display5,done_button)
    path = get(path_entry,'string');
    tfile = get(tfile_entry,'string');
    current = pwd;
    location = [path tfile];
    cd(location)
    load([tfile 'w2b.mat'])
    
    cd(current)
    set(load_file_light_w2b,'BackgroundColor',[0 1 0])
    set(load_file_light_b2w,'BackgroundColor',[1 0 0])

    %delete preset handles
    userdata = get(load_file_light_w2b,'UserData');
    if length(userdata) > 1
        delete(userdata);
    end
    
    csdAllGrids_handleS = get(info,'UserData');
    if length(csdAllGrids_handleS) > 0
        delete(csdAllGrids_handleS)
    end
    
    set(display4,'String','Layer 4 Information');
    set(display5,'String','Actual depth of all channels');
    
    set(csdAllGrids_template,'Visible','on');
    set(LFP_template,'Visible','on');
    set(CSD_template,'Visible','on');
    set(pcolor_template,'Visible','on');
    set(surf_template,'Visible','on');
    
    set(display3,'String','The analysis has not yet begun.')
    set(done_button,'UserData',0);   %so that another iteration could be performed
end

function load_b2w_file(object_handle,event,load_file_light_b2w,load_file_light_w2b,path_entry,tfile_entry,LFP_template,CSD_template,pcolor_template,surf_template,csdAllGrids_template,display3,info,display4,display5,done_button)
    path = get(path_entry,'string');
    tfile = get(tfile_entry,'string');
    current = pwd;
    location = [path tfile];
    cd(location)
    load([tfile 'b2w.mat'])
    cd(current)
    set(load_file_light_b2w,'BackgroundColor',[0 1 0])
    set(load_file_light_w2b,'BackgroundColor',[1 0 0])
    
    %delete preset handles
    userdata = get(load_file_light_b2w,'UserData');
    if length(userdata) > 1
        delete(userdata);
    end

    csdAllGrids_handleS = get(info,'UserData');
    if length(csdAllGrids_handleS) > 0
        delete(csdAllGrids_handleS)
    end
    
    set(display4,'String','Layer 4 Information');
    set(display5,'String','Actual depth of all channels');
    
    set(csdAllGrids_template,'Visible','on')
    set(LFP_template,'Visible','on');
    set(CSD_template,'Visible','on');
    set(pcolor_template,'Visible','on');
    set(surf_template,'Visible','on');
    
    set(display3,'String','The analysis has not yet begun.')
    set(done_button,'UserData',0);   %so that another iteration could be performed
end

function run_loaded(object_handle,event,load_file_light_w2b,load_file_light_b2w,path_entry,tfile_entry,...
    tbefore_entry,tafter_entry,num_channels_entry,channel_order_entry,channels_entry,delta_entry,csdAllGrids_template,window,LFP_template,CSD_template,pcolor_template,surf_template,window_positioned,done_button,display3,display4,display5,info)
    path = get(path_entry,'string');
    tfile = get(tfile_entry,'string');
    tbefore = str2double(get(tbefore_entry,'string'));    %we use str2double here because it works the fastest
    tafter = str2double(get(tafter_entry,'string'));
    num_channels = str2double(get(num_channels_entry,'string'));
    channel_order = str2num(get(channel_order_entry,'string'));   %we use str2num here because str2double doesn't work on arrays
    channels = str2double(get(channels_entry,'string'));
    delta = str2double(get(delta_entry,'string'));
    
    %display that the analysis is being run
    set(display3,'String','The CSD analysis is running...')
    
    %extracting the rows and columns parameters directly from the data
    location = [path tfile];
    current = pwd;
    cd(location);
    g = load('stims.mat');
    p = getparameters(get(g.saveScript,1));
    rows = (p.rect(4))/(p.pixSize(2));
    columns = (p.rect(3))/(p.pixSize(1));
    
    space_size = get(csdAllGrids_template,'Position');
    pcolor_size = get(pcolor_template,'Position');
    dimensions = get(window,'Position');
    window_dimensions = [dimensions(3) dimensions(4)];
    start_time = tbefore;
    
    %setting parameters for CSD calculations and channel_order:
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
    
    %loading the existing file and performing csdAllGrids_GUI on it
    if get(load_file_light_w2b,'BackgroundColor') == [0 1 0]    %if dealing with Xw2b
        load([tfile 'w2b.mat']);
        cd(current);
        csdAllGrids_GUI(Xw2b,rows,columns,delta,channel_order,start_time,space_size,[tfile 'w2b.mat'],location,window_dimensions,sync_channel_position,above_sync,below_sync,info);
        X = Xw2b;
    elseif get(load_file_light_b2w,'BackgroundColor') == [0 1 0]    %if dealing with Xb2w
        load([tfile 'b2w.mat']);
        cd(current);
        csdAllGrids_GUI(Xb2w,rows,columns,delta,channel_order,start_time,space_size,[tfile 'b2w.mat'],location,window_dimensions,sync_channel_position,above_sync,below_sync,info);
        X = Xb2w;
    end
    
    csdAllGrids_handles = get(info,'UserData');
    
    set(csdAllGrids_template,'Visible','off');  %turn the csdAllGrids_template off to show the real data
    hold off
    drawnow;
    %SUPER IMPORTANT WARNING: The user must NEVER move the window after this because the positions
    %are calibrated to the relative position to the dimensions of the
    %screen.
    a = 0;
    dotted1 = 0;
    dotted2 = 0;
    dotted3 = 0;
    surf_dimensions = get(surf_template,'Position');
    right_bound = surf_dimensions(1) + surf_dimensions(3);
    pcolor_handle = 0;
    surf_handle = 0;
    LFP_handles = 0;
    clicked = 0;
    while true
        set(window,'Position',window_positioned);
        waitforbuttonpress;
        %instant cursor tracking feature would be useful**********
        if get(done_button,'UserData') == 1
            set(display3,'String','The CSD analysis is complete!')
            break;
        end
        clicked_location = get(gcf,'currentpoint');
        click_location = [clicked_location(1)/window_dimensions(1) clicked_location(2)/window_dimensions(2)];
        if (space_size(1) < clicked_location(1)) && (clicked_location(1) < (space_size(1) + space_size(3))) && (space_size(2) < clicked_location(2)) && (clicked_location(2) < (space_size(2) + space_size(4)))
            if (pcolor_handle ~= 0) && (surf_handle ~= 0)
                delete(pcolor_handle);
                delete(surf_handle);
                delete(LFP_handles);
                delete(CSD_handles);
            end
            if clicked ~= 0
                set(temp_handle,'xcolor','k')
                set(temp_handle,'ycolor','k')
                set(temp_handle,'LineWidth',1)
            end
            gridloc = click_locate_grid(click_location,rows,columns,window_dimensions,space_size);
            temp_handle = csdAllGrids_handles(gridloc);
            axes(temp_handle);
            set(temp_handle,'xcolor','r');
            set(temp_handle,'ycolor','r');
            set(temp_handle,'LineWidth',2);
            uistack(temp_handle,'top');
            clicked = 1;
            [L,H,I] = csdCalculate(X,gridloc,delta,channel_order,sync_channel_position,above_sync,below_sync);
            [LFP_handles,CSD_handles,pcolor_handle,surf_handle,pcolor_axis] = csdPlot_GUI(L,H,I,channel_order,start_time,LFP_template,CSD_template,pcolor_template,surf_template,window_dimensions,delta);
            set(load_file_light_w2b,'UserData',[pcolor_handle,surf_handle,LFP_handles,CSD_handles]);
            set(load_file_light_b2w,'UserData',[pcolor_handle,surf_handle,LFP_handles,CSD_handles]);
            if a == 1
                close('name','2')
                close('name','3')
                close('name','4')
                close('name','5')
            end
            dotted1 = 0;
            dotted2 = 0;
            dotted3 = 0;
        elseif ((clicked_location(2) > (space_size(2)+space_size(4))) && (clicked_location(1) <= right_bound)) || ...
                ((clicked_location(2) < space_size(2)) && (clicked_location(2) > (pcolor_size(2)+pcolor_size(4))) && (clicked_location(1) <= right_bound)) || ...  %%CHANGE
                ((clicked_location(2) < (pcolor_size(2)+pcolor_size(4))) && (clicked_location(1) < pcolor_size(1))) || ...
                (clicked_location(1) < space_size(1)) || ...
                ((clicked_location(1) > (space_size(1)+space_size(3))) && (clicked_location(1) <= right_bound) && (clicked_location(2) > (pcolor_size(2)+pcolor_size(4))))
            [L,H,I] = csdCalculate(X,gridloc,delta,channel_order,sync_channel_position,above_sync,below_sync);
            csdPlot(L,H,I,channel_order,tbefore,delta)
            a = 1;
            dotted1 = 0;
            dotted2 = 0;
            dotted3 = 0;
        elseif (pcolor_size(1) < clicked_location(1)) && (clicked_location(1) < (pcolor_size(1) + pcolor_size(3))) && (pcolor_size(2) < clicked_location(2)) && (clicked_location(2) < (pcolor_size(2) + pcolor_size(4)))
            if (dotted1 ~= 0) || (dotted2 ~= 0) || (dotted3~= 0)
                delete(dotted1)
                delete(dotted2)
                delete(dotted3)
            end
            pt1 = ginput(1);   %points for middle of layer 4, top of layer 4, and bottom of layer 4
            dotted1 = plot([min(get(pcolor_axis,'Xdata')) max(get(pcolor_axis,'Xdata'))],[pt1(2) pt1(2)],'k--');
            hold on
            pt2 = ginput(1);
            dotted2 = plot([min(get(pcolor_axis,'Xdata')) max(get(pcolor_axis,'Xdata'))],[pt2(2) pt2(2)],'k--');
            hold on
            pt3 = ginput(1);
            dotted3 = plot([min(get(pcolor_axis,'Xdata')) max(get(pcolor_axis,'Xdata'))],[pt3(2) pt3(2)],'k--');
            hold on
            pts = [];
            pts(1,:) = pt1;
            pts(2,:) = pt2;
            pts(3,:) = pt3;
            %automatic sorting function implementation for 'pts, so that mess-up
            %chance is minimized
            determine_depth(pts,display4,display5,pcolor_handle,channel_order,location,current)
        end
    end
end

%% Internal functions
function checkw2bb2w(path,tfile,display1)
    location = [path tfile];
    current = pwd;
    cd(location)
    load('stims.mat');
    mystim = get(saveScript,1);
    a = getparameters(mystim);
    if max((a.BG == [0 0 0])) && max((a.value == [255 255 255]))    %black to white
        set(display1,'String','The transition of interest is b2w.')
    elseif max((a.BG == [255 255 255])) && max((a.value == [0 0 0]))    %white to black
        set(display1,'String','The transition of interest is w2b.')
    else    %unknown transition
        set(display1,'String','The data is not of blinking stim type.')
    end
    cd(current)
end

function csdAllGrids_GUI(X,rows,columns,delta,channel_order,start_time,space_size,load_file,location,window_dimensions,sync_channel_position,above_sync,below_sync,info)
current = pwd;
cd(location);
load(load_file);
cd(current);

S = [];
minCSD = zeros(1,rows*columns);
maxCSD = zeros(1,rows*columns);

wbar = waitbar(0,'Calculating out CSDs for grids (Cycle 1/2)...');
set(0, 'CurrentFigure', 1);
for i = 1:rows*columns  %iterates 300 times and i = grid numbers which also equates to columns in the X cell
    [L,H,I] = csdCalculate(X,i,delta,channel_order,sync_channel_position,above_sync,below_sync);   %need to output all three outputs of super_csd since what we need is the output I which is the last one
    S(:,:,i) = I;  %S is a 14 by 31 by 300 array
    display(i);  %should end at 300
    minCSD(i) = min(H(:));
    maxCSD(i) = max(H(:));
    waitbar((i)/(rows*columns),wbar,'Calculating out CSDs for grids (Cycle 1/2)...')
end
waitbar((i)/(rows*columns),wbar,'Complete!')
close(wbar)

trueminCSD = min(minCSD);
truemaxCSD = max(maxCSD);
truescale = max([abs(trueminCSD) abs(truemaxCSD)]);

%The following block creates the time axis for each of the grid CSD plots
size_L = size(L);   %the L here would of course be the L for the last grid, be it 300 or 100.
columns_L = size_L(2);
xaxis = 1:columns_L;   %if this were to be used as a testing function, use 1:10; otherwise, ignore the 1:10.
Ttime = xaxis * 83/25000;  %To convert the data points 1:31 to 1 to 100ms or 0.1s. The 83 comes from the fastread downsampling function which is called on by csdDataProcessing.
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

width = space_size(3)/columns;
height = space_size(4)/rows;

count = 1;
ycount = 1;
wbar = waitbar(0,'Plotting out CSDs for grids(Cycle 2/2)...');
set(0, 'CurrentFigure', 1);
csdAllGrids_handle = [];
for i = 1:rows  %iterates 15 times
    xcount = 0;
    for j = 1:columns   %iterates 20 times
        gridloc = csd_coordinates_to_grid(j,i,rows);    %gridloc = grid# increases from top to bottom then left to right
        csdAllGrids_handle(gridloc) = axes('units','normalized','position',[(space_size(1)+xcount*width+1)/window_dimensions(1),((space_size(2)+space_size(4))-ycount*height-1)/window_dimensions(2),width/window_dimensions(1),height/window_dimensions(2)]);
        pcolor(XX,Y,S(:,:,gridloc)); %used pcolor rather than surf here because the 3D functionality is not needed
        %hide x and y tickers
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on
        y = [0 max(Y)];
        x = [0 0];
        %invert and equally scale the color scale on both sides
        plot(x,y,'k-','LineWidth',1)
        set(gca,'ydir','reverse');
        rel_I = S(:,:,gridloc);
        mymap = jet(256);
        invert_map = mymap(256:-1:1,:);
        colormap(invert_map);
        caxis(truescale*[-1 1]);
        shading interp    %can be changed to other types of shading for potentially better viewing
        hold on
        display(i)  %should end at 15
        display(j)  %should end at 20        
        set(0, 'CurrentFigure', 1);
        waitbar(((i-1)*columns+j)/(rows*columns),wbar,'Plotting out CSDs for grids(Cycle 2/2)...')
        count = count + 1;
        xcount = xcount + 1;    %could just substitute with j-1
    end
    ycount = ycount + 1;    %could just substitute with i
end
set(info,'UserData',csdAllGrids_handle);
waitbar(((i-1)*columns+j)/(rows*columns),wbar,'Complete!')
close(wbar)

end

function grid = csd_coordinates_to_grid(x,y,rows)
%csd_coordinates_to_grid
%This function resolves the discrepancy between the convention that grids
%are ordered and also how subplots are ordered.
%
%Example:
%grid = csd_coordinates_to_grid(15,20,15)

grid = (x-1)*rows+y;

end

function gridloc = click_locate_grid(position,rows,columns,window_dimensions,space_size)
    width = space_size(3)/columns;
    height = space_size(4)/rows;
    x = linspace(((space_size(1)+1)/window_dimensions(1)),((space_size(1)+columns*width+1)/window_dimensions(1)),11);
    y = linspace((((space_size(2)+space_size(4))-1)/window_dimensions(2)),(((space_size(2)+space_size(4))-(rows)*height-1)/window_dimensions(2)),(11));
    
    for i = 1:length(x)-1
        if (x(i) < position(1)) && (position(1) < x(i+1))
            xval = i;
            break;
        end
    end

    for j = 1:length(y)-1
        if (position(2) > y(j+1)) && (position(2) < y(j))
            yval = j;
            break;
        end
    end
    
    gridloc = csd_coordinates_to_grid(xval,yval,rows);
    
end

function [LFP_handles,CSD_handles,pcolor_handle,surf_handle,pcolor_axis] = csdPlot_GUI(L,H,I,channel_order,start_time,LFP_template,CSD_template,pcolor_template,surf_template,window_dimensions,delta)
%csdPlot_GUI.m
%%To plot the LFPs, CSDs, and a 3D Surf Plot from top to bottom for a specific grid. This
%function is used following super_csd.m and after identifying the optimal grid from csdAllGrids_GUI.
%It takes in the output arrays 'L','H','I' from super_csd.m.
%
%After identifying the optimal grid in csdAllGrids_GUI, you will need to define
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
%csdPlot_GUI(L,H,I,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6],0.050)
%csdPlot_GUI(L,H,I,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16],0.050)
%csdPlot_GUI(L,H,I,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 1 22 11 21 12 20 13 19 14 18 15 17 16],0)
%csdPlot_GUI(L,H,I,[10 9 8 7 6 5 4 3 2 1 11 12 13 14 15 16],0)

%% Part A: Plotting out the LFPs
size_L = size(L);
rows_L = size_L(1);
columns_L = size_L(2);
xaxis = 1:columns_L;   %if this were to be used as a testing function, use 1:10; otherwise, ignore the 1:10.
Ttime = xaxis * 83/25000;  %To convert the data points 1:31 to 1 to 100ms or 0.1s. The 83 comes from the fastread downsampling function which is called on by csdDataProcessing.
TTtime(1) = 0;
TTtime(2:length(Ttime)+1) = Ttime;
T_time = [];    %an optimization step would be to preallocate initally with zeros
for i = 1:length(TTtime)
    T_time(i) = TTtime(i) - start_time;
end
T_time = T_time(1:end-1);

%IS THIS ABOVE PART AN ACCURATE CONVERSION? DOUBLE-ROUNDING ERROR?

%Reordering the LFPs. Note that the csd calculation loop in super_csd takes
%into account the order already, so H and I do not need to be reordered.
%channel_order = [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6]; % NeuroNexus probe channel order

L_organized = [];

for i = 1:rows_L    %to organize the channels
    L_organized(i,:) = L(channel_order(i),:);
end

s = size(L_organized);
r = s(1);
c = s(2);

minL0 = min(min(L));
maxL0 = max(max(L));

minL = minL0*1.05;
maxL = maxL0*1.05;

LFP_template_position = get(LFP_template,'Position');
height = LFP_template_position(4)/(r);

LFP_handles = [];

for i = 1:r
    LFP_handles(i) = axes('units','normalized','position',[LFP_template_position(1)/window_dimensions(1) ((LFP_template_position(2)+LFP_template_position(4))-height*i)/window_dimensions(2) LFP_template_position(3)/window_dimensions(1) height/window_dimensions(2)]);
    if i < r+1
        hhha = fill([-start_time -start_time 0 0],[minL maxL maxL minL],[0.85 0.85 0.85]);  %4 points for this grid: (0,minL) (0,maxL) (start_time,minL) (start_time,maxL)  --> then make these lines disappear
        set(hhha,'LineStyle','none') %make the fill lines invisible
        hold on
        plot(T_time,L_organized(i,:),'k-','LineWidth',1);
    end
    axis([-start_time max(T_time) minL maxL])
    set(gca,'Color',[1 1 1])
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    box off
    hold on
end
drawnow;

%tightfig;  %This is a function I downloaded from the MATLAB database. It
%basically makes the subplot more compact so the curves are easier to view;
%however, it messes up my labels so I commented it out.

LFP_current_index = length(LFP_handles) + 1;

%Labeling the LFP Plot
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
LFP_handles(LFP_current_index) = text(0.085, 0.43,'Figure 1: Voltage Response of Electrodes','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
LFP_current_index = length(LFP_handles) + 1;
LFP_handles(LFP_current_index) = text(0.14, 0.05,'Time','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
LFP_current_index = length(LFP_handles) + 1;
a = text(0.005, 0.23,'Relative Depth','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
LFP_handles(LFP_current_index) = a;
LFP_current_index = length(LFP_handles) + 1;
set(a, 'rotation', 90);

if start_time > 0
    LFP_handles(LFP_current_index) = text(0.025,0.025,'before stim');
    LFP_current_index = length(LFP_handles) + 1;
    LFP_handles(LFP_current_index) = text(0.08,0.025,'after stim');
end


%% Part B: Plotting out the CSDs
s1 = size(H);

rows = s1(1);

minH0 = min(min(H));
maxH0 = max(max(H));

minH = minH0*1.05;
maxH = maxH0*1.05;

CSD_template_position = get(CSD_template,'Position');
height = CSD_template_position(4)/(rows);

CSD_handles = [];

for i = 1:(rows)
    CSD_handles(i) = axes('units','normalized','position',[CSD_template_position(1)/window_dimensions(1) ((CSD_template_position(2)+CSD_template_position(4))-i*height)/window_dimensions(2) CSD_template_position(3)/window_dimensions(1) height/window_dimensions(2)]);
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
    end
    axis([-start_time max(T_time) minH maxH]);
    set(gca,'Color',[1 1 1])
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    box off
    hold on
end
drawnow;

CSD_current_index = length(CSD_handles) + 1;

%Labeling the CSD Plot
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
CSD_handles(CSD_current_index) = text(0.24, 0.43,'Figure 2: CSDs for Channels','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
CSD_current_index = length(CSD_handles) + 1;
CSD_handles(CSD_current_index) = text(0.30, 0.05,'Time','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
CSD_current_index = length(CSD_handles) + 1;
a = text(0.16, 0.23,'Relative Depth','HorizontalAlignment' ,'center','VerticalAlignment', 'top');
CSD_handles(CSD_current_index) = a;
CSD_current_index = length(CSD_handles) + 1;
set(a,'rotation',90);

if start_time > 0
    CSD_handles(CSD_current_index) = text(0.18,0.025,'before stim');
    CSD_current_index = length(CSD_handles) + 1;
    CSD_handles(CSD_current_index) = text(0.25,0.025,'after stim');
end

%% Part C: Plotting out the 2D Pcolor Heat Map for CSDs
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

pcolor_template_position = get(pcolor_template,'Position');

axes('units','normalized','position',[pcolor_template_position(1)/window_dimensions(1) pcolor_template_position(2)/window_dimensions(2)*1.1 pcolor_template_position(3)/window_dimensions(1)*0.9 pcolor_template_position(4)/window_dimensions(2)*0.9])
pcolor_axis = pcolor(X,Y,I);

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

title('Figure 4: 2D Heat Map for CSDs')
xlabel('time [s]')
ylabel('relative depth [um]')
zlabel('CSD amplitude')
h = colorbar;
ylabel(h,'V/m^2')
hold on
drawnow;
pcolor_handle = gca;
set(pcolor_handle,'Userdata',Y)

%% Part D: Plotting out the 3D Surf Heat Map for CSDs
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

surf_template_position = get(surf_template,'Position');

axes('units','normalized','position',[surf_template_position(1)/window_dimensions(1) surf_template_position(2)/window_dimensions(2) surf_template_position(3)/window_dimensions(1)*0.9 surf_template_position(4)/window_dimensions(2)*0.9])

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


title('Figure 3: 3D Heat Map for CSDs')
xlabel('time [s]')
ylabel('relative depth [um]')
zlabel('CSD amplitude')
h = colorbar;
ylabel(h,'V/m^2')
hold off
drawnow;
surf_handle = gca;


%turn off all  the white template-placeholders and reveal the final result
set(LFP_template,'Visible','off');
set(CSD_template,'Visible','off');
set(pcolor_template,'Visible','off');
set(surf_template,'Visible','off');

end

function [fillhandle,msg] = jbfill(xpoints,upper,lower,color,edge,add,transparency)
%USAGE: [fillhandle,msg]=jbfill(xpoints,upper,lower,color,edge,add,transparency)
%This function will fill a region with a color between the two vectors provided
%using the Matlab fill command.
%
%fillhandle is the returned handle to the filled region in the plot.
%xpoints= The horizontal data points (ie frequencies). Note length(Upper)
%         must equal Length(lower)and must equal length(xpoints)!
%upper = the upper curve values (data can be less than lower)
%lower = the lower curve values (data can be more than upper)
%color = the color of the filled area 
%edge  = the color around the edge of the filled area
%add   = a flag to add to the current plot or make a new one.
%transparency is a value ranging from 1 for opaque to 0 for invisible for
%the filled color only.
%
%John A. Bockstege November 2006;
%Example:
%     a=rand(1,20);%Vector of random data
%     b=a+2*rand(1,20);%2nd vector of data points;
%     x=1:20;%horizontal vector
%     [ph,msg]=jbfill(x,a,b,rand(1,3),rand(1,3),0,rand(1,1))
%     grid on
%     legend('Datr')
if nargin<7;transparency=.5;end %default is to have a transparency of .5
if nargin<6;add=1;end     %default is to add to current plot
if nargin<5;edge='k';end  %dfault edge color is black
if nargin<4;color='b';end %default color is blue

if length(upper)==length(lower) && length(lower)==length(xpoints)
    msg='';
    filled=[upper,fliplr(lower)];
    xpoints=[xpoints,fliplr(xpoints)];
    if add
        hold on
    end
    fillhandle=fill(xpoints,filled,color);%plot the data
    set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color
    if add
        hold off
    end
else
    msg='Error: Must use the same number of points in each vector';
end
end

function sync_channel_number = determine_sync_channel(path,tfile)
%determine_sync_channel
%This function takes in the path and tfile and outputs the sync channel
%number based on the channel ID shown in the NeuroNexus SiteMaps Data Sheet
%Example:
%determine_sync_channel('/Users/dennisou/Desktop/','t00001/')

location = [path tfile];
text = fileread([location 'vhlvanaloginput.vlh']);   %might need to implement "start after space"
space_array = isspace(text);
for i = 1:length(space_array)
    if space_array(i) == 1
        start_index = i+1;
        break;
    end
end
for i = 1:length(text)
    if strcmp(text(i),'N')
        second_line_index = i-1;
        break;
    end
end
for i = linspace(second_line_index,start_index,(second_line_index-start_index+1))
    if space_array(i) == 0
        end_index = i;
        break;
    end
end

processed_string = remove_spaces(text(start_index:end_index));
string_cell = {};

index = 1;
begin = 1;
for i = 1:length(processed_string)
    if strcmp(processed_string(i),',')
        string_cell{index} = processed_string(begin:i-1);
        index = index+1;
        begin = i+1;
    end
end
if ~strcmp(processed_string(end),',')
    string_cell{index} = processed_string(begin:end);
end

yes_no = zeros(1,length(string_cell));
for i = 1:length(string_cell)
    for j = 1:length(string_cell{i})
        if strcmp(string_cell{i}(j),':')
            yes_no(i) = 1;  %1 means that there is semicolon existing
            break;
        end
    end
end

for i = 1:length(yes_no)
    if yes_no(i) == 0
        cell_index = i;
        break;
    end
end

relevant_string = string_cell{cell_index};
for i = 1:length(relevant_string)
    if strcmp(relevant_string(i),'/')
        sync_channel_number = str2double(relevant_string(i+3:end))+1;
    end
end

end

function processed_string = remove_spaces(string)
%remove_spaces
%This function removes all spaces within a string and outputs the
%processed_string

space_array = isspace(string);
processed_string = '';
start = 1;
for i = 1:length(string)
    if space_array(i) == 1
        processed_string = [processed_string string(start:i-1)];
        start = i+1;
    end
end
if space_array(end) == 0
    processed_string = [processed_string string(start:end)];
end
end

function determine_depth(pts,display4,display5,pcolor_handle,channel_order,location,current)
%actual_depth
%For each channel, outputs the actual depth estimated for each channel.

identified_layer4 = pts(1,2);
deltaDepth = 500 - identified_layer4;

A = {'Layer 4 Information' ['Layer4 Top:' num2str(pts(2,2)+deltaDepth) 'um'] ['Layer4 Center:' num2str(pts(1,2)+deltaDepth) 'um']...
    ['Layer4 Bottom:' num2str(pts(3,2)+deltaDepth) 'um'] ['Layer 4 Thickness:' num2str((pts(3,2)+deltaDepth)-(pts(2,2)+deltaDepth)) 'um']};
mls = sprintf('%s\n%s\n%s\n%s\n%s',A{1,1},A{1,2},A{1,3},A{1,4},A{1,5});

Y = get(pcolor_handle,'Userdata');

Y(length(Y)+1) = Y(end)+(Y(end) - Y(length(Y)-1));
for i = 1:length(Y)
    Y(i) = Y(i) + deltaDepth;
end

mydepthstring = [];
for i = 1:length(Y)
    mydepthstring = cat(2,mydepthstring,['Channel ' int2str(channel_order(i)) ' depth is ' num2str(Y(i)) 'um.' sprintf('\n')]);
end

set(display4,'String',mls)
set(display5,'String',mydepthstring)

cd(location);
fid = fopen('csd_data_table.txt','w');
for i = 1:length(Y)
    fprintf(fid,'Channel %s: %s um\n',num2str(channel_order(i)),num2str(Y(i)));
end
fclose(fid);
cd(current);

end


%TDL:
%1. CSD Documentation --- still improving.

%2. Does csdDataProcessing run successfully?

%3. Real-time scaling.

%4. Work with Neil to work with 3-4 or more experiments.

%5. See Notepad notes.
