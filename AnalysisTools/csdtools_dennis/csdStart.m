function X = csdStart()
% csdStart
%
%Purpose:
%To avoid the calling of multiple functions manually. This is done to
%accomodate the non-coding user. This allows for a more user-friendly
%interface.
%
%Test Cases:
%X = CSDmapping();
%{'/Users/dennisou/Desktop/','t00002',0.050,0.100,17,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6],2:17,100}
%{'/Users/dennisou/Desktop/','t00001',0.050,0.100,32,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16],2:32,25}
%myheader = readvhlvheaderfile(['/Users/dennisou/Desktop' filesep 't00001' filesep 'vhlvanaloginput.vlh']);

%% Data Input Step
clear;clc;  %start off on a clean slate

while true;
    prompt1 = '\nWould you like to use the GUI (Graphical User Interface) \nor the TBI (Text Based Interface)?\nIf you want to use the GUI, type GUI.\nIf you want to use the TBI, type TBI.\n';
    state = input(prompt1,'s');
    if strcmp(state,'GUI')
        csdGUI();   %how to get CSDGUI to output X?
        return;
    elseif strcmp(state,'TBI')
        break;
    else
        fprintf('\nPlease input GUI or TBI.\n')
    end
end

while true;
    prompt11 = '\nAre you a first-time user? Please type "yes" or "no" directly in\nlowercase and non-string format. If you want to quit,\njust press control+C.\n';
    state = input(prompt11,'s');

    if strcmp(state,'yes')   %for new users
        [path,tfile,tbefore,tafter,channel_order,channels,delta] = CSDvalidate();
        break;
        
    elseif strcmp(state,'no') %for verteran users
        prompt22 = '\nPlease enter your preferences in a cell.\nThe format is as follows: {path,tfile,tbefore,tafter,...\nnum_channels,channel_order,channels,delta}.\nPlease make sure to double check your values also.\n\n';
        cell = input(prompt22);
        %Will only discuss the "confusing" inputs here:
        %tbefore = time before each stim you want collect data starting from in seconds
        %tafter = time after each stim that you want to collect data up to in seconds
        %num_channels = number of channels including syncchannel
        %channel_order = order of channels in an array. can be found on electrode data sheet
        %channels = the range of channels that correspond to input channels. This is basically the Dev1/ai terms plus 1.
        %delta = the spacing between channels in microns.
        %w2bb2w = 0 means white to black and 1 means black to white and 2
        %         means do BOTH white to black AND black to white
        
        %associating the elements of the 'input' array into variables
        path = cell{1};
        if ~(ischar(path))
            error('The path entry must be a string.')
        elseif (path(1) ~= '/')
            error('The first element of the path entry must be a "/".') %takes into account the potential error that the user entered this entry as a string.
        elseif (path(end) ~= '/')
            error('The last element of the path entry must be a "/".')
        end
        tfile = cell{2};
        if ~(ischar(tfile))
            error('The tfile must be a string.')
        elseif (length(tfile) ~= 6)   %if the length does not equal the length of 't00001' which is 6, then output error
            error('You might have included additional zeros or missed out zeros.')
        elseif (tfile(1) == '/')
            error('You cannot have a "/" at the beginning of the tfile entry.')
        end         
        %*****write code to handle the "/" in the last position of tfile and delete it.
        tbefore = cell{3};
        if (isnumeric(tbefore) == 0)
          error('tbefore must be numeric.')
        end
        tafter = cell{4};
        if (isnumeric(tafter) == 0)
          error('tafter must be numeric.')
        end
        num_channels = cell{5};  
        channel_order = cell{6};    %note that some cells elements use {} rather than (). not a big deal but sometimes using {} rather than () could make a difference in how data is outputted.
        
        %NOTE: The elements in this array has to exclude the sync channel!
        
        if (isnumeric(channel_order) == 0)
            error('Please enter numeric integer values into the channel_order array. Please try again by re-running the function.')
        elseif (length(channel_order) < (num_channels))
            error('There are too few values inside the channel_order array. Please try again by re-running the function.')
        elseif (length(channel_order) > (num_channels))
            error('There are too many values inside the channel_order array. Please try again by re-running the function.')
        elseif ((num_channels) ~= length(channel_order))
            error('The number of channels in channel_order does not equal to number of elements in channel order array. Please try again by re-running the function.')
        end
        channels = cell{7};
        if (isnumeric(channels) == 0)
            error('channels must be numeric.')
        end
        delta = cell{8};
        if (isnumeric(delta) == 0)
            error('delta must be numeric.')
        end
        break;
    end  
end

%% Checking the vhlv_sync2spike2 function and fixing it if there is a problem

fprintf('\nrunning vhlv_sync2spike2 check...\n')    %alerts user that the vhlv_sync2spike2 will commence

%Potential creation of vhlv_syncchannel.txt file if sync channel is the
%first channel. There is no need to create a text file if the sync channel
%is the last channel as that is assumed by default.
location = [path tfile];
text = fileread([location '/vhlvanaloginput.vlh']);
if strcmp(text(16:24),'Dev1/ai31')
    copyfile('vhlv_syncchannel.txt',location)
end

%Quick double check on vhlv_sync2spike2()
[shift,scale] = vhlv_sync2spike2(location); %can eventually eliminate running this function again in the csdDataProcessing function.

fprintf('\nvhlv_sync2spike2 check successful!\n') %alerts the user that the vhlv_sync2spike2 is successful

%% Specifying what type of files (none, w2b, b2w, or both) should be created & Extracts rows and columns parameters

%If there is a ".mat" file already, prompt user if he wants to create a
%new one that will overwrite the orignal one.
current = pwd;
cd(location);

%extracting the rows and columns parameters directly from the data
g = load('stims.mat');
p = getparameters(get(g.saveScript,1));
rows = (p.rect(4))/(p.pixSize(2));
columns = (p.rect(3))/(p.pixSize(1));

%does what the subtitle says
if (exist([tfile 'w2b.mat']) == 2)   %if tfile w2b exists, then fileexist = 1. if it is incomplete, completionw2b = 0. If it is complete, completionw2b = 1.
    fileexist = 1;
    load([tfile 'w2b.mat'])
    size_Xw2b = size(Xw2b);
    rows_Xw2b = size_Xw2b(1);
    if rows_Xw2b ~= (num_channels - 1)   %num_channels includes the sync channel which is irrelevant
        completionXw2b = 0;
    else
        completionXw2b = 1;
    end
elseif (exist([tfile 'b2w.mat']) == 2)  %if tfile b2w, then fileexist = 2. if it is incomplete, completionw2b = 0. If it is complete, completionw2b = 1.
    fileexist = 2;
    load([tfile 'b2w.mat'])
    size_Xb2w = size(Xb2w);
    rows_Xb2w = size_Xb2w(1);
    if rows_Xb2w ~= (num_channels - 1)
        completionXb2w = 0;
    else
        completionXb2w = 1;
    end
elseif ((exist([tfile 'b2w.mat']) == 2) && (exist([tfile 'w2b.mat']) == 2)) %if both types of file exists, then fileexist = 3
    fileexist = 3;
    load([tfile 'w2b.mat'])
    size_Xw2b = size(Xw2b);
    rows_Xw2b = size_Xw2b(1);
    if rows_Xw2b ~= (num_channels - 1)   %num_channels includes the sync channel which is irrelevant
        completionXw2b = 0;
    else
        completionXw2b = 1;
    end
    load([tfile 'b2w.mat'])
    size_Xb2w = size(Xb2w);
    rows_Xb2w = size_Xb2w(1);
    if rows_Xb2w ~= (num_channels - 1)
        completionXb2w = 0;
    else
        completionXb2w = 1;
    end
else    %otherwise, no tfile of either of both types exist
    fileexist = 0;
end

cd(current)

%% Final Modifications --- Implementing csdResumeDataProcessing Function --- COMPLETE BUT INCLUDED HERE FOR REFERENCE
%Pseudocode
%only prompt for this code if csdResumeDataProcessing is selected...
%if there is already a w2b file existing (fileexist == 1), csdResumeDataProcessingopt = 1
%elseif there is already a b2w file existing (fileexist ==2), csdResumeDataProcessingopt = 2
%elseif there are already both files existing (fileexist == 3), csdResumeDataProcessingopt = 3
%integrate the csdResumeDataProcessingopt variable into another set of actuating functions
%these actuating functions being...
%if csdResumeDataProcessingopt = 1, csdResumeDataProcessing then run LOOP 1
%if csdResumeDataProcessingopt = 2, csdResumeDataProcessing then run LOOP 1
%if csdResumeDataProcessingopt = 3, csdResumeDataProcessing then run LOOP 2

%ONLY CALL THIS FUNCTION IF (ROWS OF X ~= NUM_CHANNELS) && (THE FILE
%EXISTS INITIALLY) && (HAVE USER'S PERMISSION)

%Question: Where do I implement this additional code within CSDmapping?

%Also, be sure to fix the problem following getSGstimtriggers i=16 first

%X = csdDataProcessing(path,tfile,header,data,tbefore,tafter,channels,transition,i_initial,rows,columns);

%%
%*****Could optimize below by cutting down repetition in fprintf, prompt, and input functions*****
%could also move this into CSDvalidate and incorporate a short hand input
%in the coding audience cell.

if ((fileexist == 1) && (completionXw2b == 1))   %if w2b file exists AND it is complete; could potentially simplify this to just completionXw2b == 1 since completionXw2b takes into account of fileexist already (according to the last set of if/else statements)
    fprintf('\nIt appears that a white to black (w2b) transition file already exists.\n')
    prompt001 = 'To not create any file, type 0.\nTo create a new w2b file, type 1.\nTo create a new b2w file, type 2.\nTo create both w2b and b2w files, type 3.\nWarning: Any action will overwrite previous data.\n';
    newfile = input(prompt001); %could eliminate the newfile variable completely as it is just an extra step
    if ((newfile == 0)||(newfile == 1)||(newfile == 2)||(newfile == 3))
        createnew = newfile;
    else
        error('The entry must be a value between 0 and 3 inclusive')
    end
elseif ((fileexist == 1) && (completionXw2b == 0))    %if w2b file exists AND is incomplete; could potentially simplify this to just copmletionXw2b == 0. This applies for the other if/else statements in this series
    %Perhaps placing a prompt in here would help smoothen up the
    %process**********
    csdResumeDataProcessingopt = 1; 
elseif (fileexist == 2 && (completionXb2w == 1))   %if b2w file exists AND it is complete
    fprintf('\nIt appears that a black to white (b2w) transition file already exists.\n')
    prompt002 = 'To not create any file, type 0.\nTo create a new w2b file, type 1.\nTo create a new b2w file, type 2.\nTo create both w2b and b2w files, type 3.\nWarning: Any action will overwrite previous data.\n';
    newfile = input(prompt002);
    if ((newfile == 0)||(newfile == 1)||(newfile == 2)||(newfile == 3))
        createnew = newfile;
    else
        error('The entry must be a value between 0 and 3 inclusive')
    end
elseif ((fileexist == 2) && (completionXb2w == 0))  %if b2w file exists AND is incomplete
    csdResumeDataProcessingopt = 2; 
elseif ((fileexist == 3) && (completionXw2b == 1) && (completionXb2w == 1))   %if both w2b and b2w files exist and they are BOTH complete
    fprintf('\nIt appears that both white to black (w2b) and black to white (b2w) transition files already exist.\n')
    prompt003 = 'To not create any file, type 0.\nTo create a new w2b file, type 1.\nTo create a new b2w file, type 2.\nTo create both w2b and b2w files, type 3.\nWarning: Any action will overwrite previous data.\n';
    newfile = input(prompt003);
    if ((newfile == 0)||(newfile == 1)||(newfile == 2)||(newfile == 3))
        createnew = newfile;
    else
        error('The entry must be a value between 0 and 3 inclusive')
    end   
elseif ((fileexist == 3) && (completionXw2b == 0) && (completionXb2w == 1)) %if both files exist and ONLY w2b is incomplete
    csdResumeDataProcessingopt = 3;
elseif ((fileexist == 3) && (completionXw2b == 1) && (completionXb2w == 0)) %if both files exist and ONLY b2w is incomplete
    csdResumeDataProcessingopt = 4;
elseif ((fileexist == 3) && (completionXw2b == 0) && (completionXb2w == 0)) %if both files exist and BOTH files are incomplete. The probability for this to happen is pretty much zero.
    csdResumeDataProcessingopt = 5;
else    %if file does not exist
    fprintf('\nIt appears that no files exist.\n')
    prompt004 = 'To not create any file, type 0.\nTo create a new w2b file, type 1.\nTo create a new b2w file, type 2.\nTo create both w2b and b2w files, type 3.\nWarning: Any action will overwrite previous data.\n';
    newfile = input(prompt004);
    if ((newfile == 0)||(newfile == 1)||(newfile == 2)||(newfile == 3))
        createnew = newfile;
    else
        error('The entry must be a value between 0 and 3 inclusive')
    end
end

cd(current);

%w2bb2w is not going to be a straight-up input for now...
%w2bb2w = 0 --- run w2b
%w2bb2w = 1 --- run b2w
%w2bb2w = 2 --- run both w2b and b2w
%--------------------------------------------------------------------------
%Note:
%fileexist = 0 --- no .mat file exists
%fileexist = 1 --- w2b exists
%fileexist = 2 --- b2w exists
%fileexist = 3 --- both w2b and b2w exist

%createnew = 0 --- don't want to create any files
%createnew = 1 --- create w2b file
%createnew = 2 --- create b2w file
%createnew = 3 --- create both w2b and b2w files

%completionXw2b = 0 --- the w2b file exists and is not complete
%completionXb2w = 1 --- the b2w file exists and is complete

%if csdResumeDataProcessingopt = 1, csdResumeDataProcessing then run LOOP 1
%if csdResumeDataProcessingopt = 2, csdResumeDataProcessing then run LOOP 1
%if csdResumeDataProcessingopt = 3 or 4 or 5, csdResumeDataProcessing then run LOOP 2


%% Running the Actual Code

%Runs csdDataProcessing or loads the data. Pretty sure these statements cover all possibilities
if createnew == 1
    Xw2b = csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,createnew-1,1,rows,columns);  %transition is 0 while createnew in this case is 1
elseif createnew == 2 
    Xb2w = csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,createnew-1,1,rows,columns);  %transition is 1 while createnew in this case is 2
elseif createnew == 3
    Xw2b = csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,createnew-3,1,rows,columns);
    Xb2w = csdDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,createnew-2,1,rows,columns);
elseif csdResumeDataProcessingopt == 1   %if w2b file exists AND is incomplete
    option = 1;
    output = csdResumeDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,0,option);
    Xw2b = output;
elseif csdResumeDataProcessingopt == 2   %if b2w file exists AND is incomplete
    option = 2;
    output = csdResumeDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,1,option);
    Xb2w = output;
elseif csdResumeDataProcessingopt == 3   %if both files exist and ONLY w2b is incomplete
    option = 1;
    output = csdResumeDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,0,option);
    Xw2b = output;
    cd(location);
    load([tfile 'b2w.mat'])
    cd(current);
elseif csdResumeDataProcessingopt == 4   %if both files exist and ONLY b2w is incomplete
    option = 2;
    output = csdResumeDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,1,option);
    Xb2w = output;
    cd(location);
    load([tfile 'w2b.mat'])
    cd(current);
elseif csdResumeDataProcessingopt == 5   %if both files exist and BOTH files are incomplete
    option = 3;
    output = csdResumeDataProcessing(path,tfile,'vhlvanaloginput.vlh','vhlvanaloginput.vld',tbefore,tafter,channels,0,option);   %the transition value here is 0 but it is essentially meaningless. look at the csdResumeDataProcessing code and you'll see what I mean
    Xw2b = output{1};
    Xb2w = output{2};
elseif ((fileexist == 1) && (createnew == 0))   %If a w2b file exists and you don't want to do anything, only the w2b file loads
    cd(location);
    load([tfile 'w2b.mat'])
    cd(current);
elseif ((fileexist == 2) && (createnew == 0))   %If a b2w file exists and you don't want to do anything, only the b2w file loads
    cd(location);
    load([tfile 'b2w.mat'])
    cd(current);    
elseif ((fileexist == 3) && (createnew == 0))   %If both files exist and you don't want to do anything, both existing files load
    cd(location);
    load([tfile 'w2b.mat'])
    load([tfile 'b2w.mat'])
    cd(current)    
elseif ((fileexists == 0) && (createnew == 0))
    error('Invalid choice: You cannot choose to not create a file when there are no files in the first place')    
end


%Call on csdAllGrids
if ((createnew == 1) || ((fileexist == 1) && (createnew == 0)) || (csdResumeDataProcessingopt == 1)) %dealing with w2b
    csdAllGrids(Xw2b,rows,columns,delta,channel_order,tbefore,path,tfile);
elseif ((createnew == 2) || ((fileexist == 2) && (createnew == 0)) || (csdResumeDataProcessingopt == 2)) %dealing with b2w
    csdAllGrids(Xb2w,rows,columns,delta,channel_order,tbefore,path,tfile);
elseif ((createnew == 3) || ((fileexist == 3) && (createnew == 0)) || (csdResumeDataProcessingopt == 3) || (csdResumeDataProcessingopt == 4) || (csdResumeDataProcessingopt == 5)) %dealing with both w2b and b2w
    csdAllGrids(Xb2w,rows,columns,delta,channel_order,tbefore,path,tfile);
    csdAllGrids(Xw2b,rows,columns,delta,channel_order,tbefore,path,tfile);
    fprintf('\nFigure 1 represents the black to white transition while Figure 2 represents the white to black transition.\n')
end


%If there is only one set of data (either w2b or b2w) we are dealing with,
%run super_csd and csdPlot once.
%LOOP 1 *****
if (((createnew == 1) || ((fileexist == 1) && (createnew == 0))) || ((createnew == 2) || ((fileexist == 2) && (createnew == 0))) || (csdResumeDataProcessingopt == 1) || (csdResumeDataProcessingopt == 2))   
    fprintf('\nYou will be asked to enter the x and y value of the grid. The \n')
    fprintf('top left corner is the origin with all x and y values positive \n')
    fprintf('and growing larger when moving to the bottom right corner. \n')
    fprintf('Dont be worried if you enter the incorrect value as you will have \n')
    fprintf('to confirm it later. \n\n')
    
    if ((createnew == 1) || ((fileexist == 1) && (createnew == 0)))
        X = Xw2b;
    elseif ((createnew == 2) || ((fileexist == 2) && (createnew == 0)))
        X = Xb2w;
    end
    
    condition0 = true;

    while condition0 == true;
        condition = true;

        while condition == true
            prompt1 = 'What is the x value? \n';
            x = input(prompt1);
            prompt2 = '\nWhat is the y value? \n';
            y = input(prompt2);

            prompt3 = '\nPlease double check to see if you have entered the correct x and y values. \nIf this is correct, type yes (lowercase). If it is not correct, type no \n(lowercase) and you will be given another chance. \n';
            str = input(prompt3,'s');
            if strcmp(str,'yes')
                condition = false;
            elseif strcmp(str,'no')
                fprintf('\n')
            else
                fprintf('\nPlease enter yes or no\n')
            end
        end

        fprintf('\nPlease wait for approx. 15-30 more minutes until completion. \n\n')
        
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
        
        %call on super_csd
        [L,H,I] = csdCalculate(X,csd_coordinates_to_grid(x,y,rows),delta,channel_order,sync_channel_position,above_sync,below_sync);

        %call on csdPlot
        csdPlot(L,H,I,channel_order,tbefore,delta);
        
        %This portion works with the outer while loop where condition0 ==
        %true. This ensures that super_csd and csdPlot can be continuously
        %run until the correct plot is chosen. This is an iterative process
        %after all.
        prompt4 = '\nHave you selected the correct grid and taken a screenshot? \nIf yes type yes and if no type no in non-string format.\n';
        str = input(prompt4,'s');
        if strcmp(str,'yes')
            condition0 = false;
        elseif strcmp(str,'no')
            fprintf('\n')
        else
            fprintf('\nPlease enter yes or no\n')
        end
    end
end

%LOOP2 *****
%If there are two sets of data we are dealing with, run the function twice 
if ((createnew == 3) || ((fileexist == 3) && (createnew == 0)) || (csdResumeDataProcessingopt == 3) || (csdResumeDataProcessingopt == 4) || (csdResumeDataProcessingopt == 5))
    for i = 1:2
        if i == 1
            X = Xw2b;
            fprintf('\nThe following is for the white to black transition data\n')
        else
            X = Xb2w;
            fprintf('\nThe following is for the black to white transition data\n')
        end
    
        fprintf('\nYou will be asked to enter the x and y value of the grid. The \n')
        fprintf('top left corner is the origin with all x and y values positive \n')
        fprintf('and growing larger when moving to the bottom right corner. \n')
        fprintf('Dont be worried if you enter the incorrect value as you will have \n')
        fprintf('to confirm it later. \n\n')

        condition0 = true;

        while condition0 == true
        condition = true;
            while condition == true
                prompt1 = 'What is the x value? \n';
                x = input(prompt1);
                prompt2 = '\nWhat is the y value? \n';
                y = input(prompt2);

                prompt3 = '\nPlease double check to see if you have entered the correct x and y values. \nIf this is correct, type yes (lowercase). If it is not correct, type no \n(lowercase) and you will be given another chance. \n';
                str = input(prompt3,'s');
                if strcmp(str,'yes')
                    condition = false;
                elseif strcmp(str,'no')
                    fprintf('\n')
                else
                    fprintf('\nPlease enter yes or no\n')
                end
            end

            fprintf('\nPlease wait for approx. 15-30 more minutes until completion. \n\n')

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

            %call on super_csd
            [L,H,I] = csdCalculate(X,csd_coordinates_to_grid(x,y,rows),delta,channel_order,sync_channel_position,above_sync,below_sync);

            %call on csdPlot
            csdPlot(L,H,I,channel_order,tbefore,delta);

            %This portion works with the outer while loop where condition0 ==
            %true. This ensures that super_csd and csdPlot can be continuously
            %run until the correct plot is chosen. This is an iterative process
            %after all.
            prompt4 = '\nHave you selected the correct grid and taken a screenshot? \nIf yes type yes and if no type no in non-string format.\n';
            str = input(prompt4,'s');
            if strcmp(str,'yes')
                condition0 = false;
            elseif strcmp(str,'no')
                fprintf('\n')
            else
                fprintf('\nPlease enter yes or no\n')
            end
        end
        
        if i == 2
            fprintf('\nThe upcoming selection will be for Figure 2 or the \nblack to white transitions.\n')
        end
    end
end

end 



%To do list:
%1. electrode library - asks if it is one of the electrodes. if not, custom
%selection.

%integrate a function that only takes in part of the time
