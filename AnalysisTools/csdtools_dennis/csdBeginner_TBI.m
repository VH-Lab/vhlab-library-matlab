function [path,tfile,tbefore,tafter,channel_order,channels,delta] = csdBeginner_TBI
%csdBeginner_TBI
%
%Purpose:
%This function contains the prompts for the beginner user. It is called on
%by the overall function CSDmapping().
%
%Test:
%[path,tfile,rows,columns,tbefore,tafter,channel_order,channels,delta] = CSDvalidate()

fprintf('\nThe first section of this function takes approx. 48-72 hours to run. \n')
fprintf('You will be asked to manually locate the correct grid afterwards. \n')
fprintf('This code will then ask you for the x and y values of this grid. \n')
fprintf('Afterwards, the code will run another 15-30 minutes. \n\n')
fprintf('Note: When the code is running, you will see i and j values being \n')
fprintf('printed out. The only reason for this is to track the progress of \n')
fprintf('the function and also for future optimization for developmental purposes. \n')
fprintf('Also, please note that the run times will vary for different sized data. \n')

fprintf('\nTo start off, you will need to input some information.\n')
prompt_aa = '\nWhat is the directory the data folder is contained in? \nPlease enter directly (not as string) and make sure the \nlast character is a "/".\n'; %prompt for path
path = input(prompt_aa,'s');
if ~(ischar(path))
    error('The path entry must be a string.')
elseif (path(1) ~= '/')
    error('The first element of the path entry must be a "/".') %takes into account the potential error that the user entered this entry as a string.
elseif (path(end) ~= '/')
    error('The last element of the path entry must be a "/".')
end

prompt_bb = '\nWhat is the name of the data folder? Please enter directly (not as string).\n'; %prompt for tfile
tfile = input(prompt_bb,'s');

%check that path is a legitimate string such that if the second character
%is a "'", then we output an error.

fprintf('Here is some basic information regarding the data being analyzed: \n\n');
myheader = readvhlvheaderfile([path filesep tfile filesep 'vhlvanaloginput.vlh']);
display(myheader);

fprintf('We will now run a short test on a sub-function. The reason for this \n')
fprintf('is because this sub-function can often crash and we wouldnt want this function \n')
fprintf('to crash after 24 hours of running would we? If the function crashes you will \n')
fprintf('need to check the displayed information above and look into the vhlv_syncchannel.txt \n')
fprintf('file (located in data folder) and input the correct sync channel into it. If there is no such file, \n')
fprintf('please create a new file with the name and file type and input the sync channel number. \n')
fprintf('Make sure that the new file is in .txt format. \n\n')

%Potential creation of vhlv_syncchannel.txt file if sync channel is the
%first channel. There is no need to create a text file if the sync channel
%is the last channel as that is assumed by default.
location = [path tfile];
text = fileread([location '/vhlvanaloginput.vlh']);
if strcmp(text(16:24),'Dev1/ai31')
    copyfile('vhlv_syncchannel.txt',location)
end

%Quick double check on vhlv_sync2spike2()
location = [path tfile];
[shift,scale] = vhlv_sync2spike2(location); %can eventually eliminate running this function again in the super2 function.

fprintf('You will now be asked to enter some more information about the data. \n');
fprintf('Some of this can be found in the displayed information above. \n\n')

while true   
    prompta = '\nWhat is the number of channels? \n'; %prompt for number of channels
    num_channels = input(prompta);
    promptb = '\nWhat is the channel order from top to bottom (shallow to deep)? \nEnter it as an array (eg. [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6]) \nwith the number of elements equal to the number of channels. \n';  %prompt for channel order
    channel_order = input(promptb); %prompt for the channel order array
    
    if (isnumeric(channel_order) == 0)
        error('Please enter numeric integer values into the array. Please try again by re-running the function.')
    elseif (length(channel_order) < (num_channels-1))
        error('There are too few values inside the array. Please try again by re-running the function.')
    elseif (length(channel_order) > (num_channels-1))
        error('There are too many values inside the array. Please try again by re-running the function.')
    elseif ((num_channels-1) ~= length(channel_order))
        error('The number of channels does not equal to number of elements in channel order array. Please try again by re-running the function.')
    end
    
    %optimization step: could shorten the above function into a single converse statement.
    
    promptc = '\nWhat is the spacing between two channels of the electrode in microns[um]? \n';   %prompt for spacing between channels in microns
    delta = input(promptc);
    
    if (isnumeric(delta) == 0)
        error('The value must be numeric.')
    end
        
    promptd = '\nWhat is the number of seconds before all stim trigggers you wish to capture?\n';   %prompt for number of miliseconds before all stim triggers to be captured
    tbefore = input(promptd);
    
    if (isnumeric(tbefore) == 0)
        error('The value must be numeric.')
    end
    
    prompte = '\nWhat is the number of seconds after all stim triggers you wish to capture?\n';   %prompt for number of miliseconds after all stim triggers to be caputured
    tafter = input(prompte);
    
    if (isnumeric(tafter) == 0)
        error('The value must be numeric.')
    end
    
    promptf = '\nWhat is the channel range? Please refer to the displayed information above. \nIf it were Dev1/ai0:15, you would input 1:16. There are exceptions though. \nIf the sync channel (usually Dev1/ai31) appears before Dev1/ai0:15, \nthen you need to input 2:17 instead. \n';   %prompt for the channel range in Steve's language where ai 0:31 means channels 1 to 32.
    channels = input(promptf);
    if (isnumeric(channels) == 0)
        error('The value must be numeric.')
    elseif (length(channels) ~= length(channel_order))
        errors('The number of elements in the array you just entered must match the number of elements in the channel array you entered earlier.')
    end
    %MAKE THE ABOVE INPUT AUTOMATED -- might be tough because the spacing
    %might be different between header files.
    %implement a function that searches for the next non-blank character
    %and start from there.
    
    %COULD ALSO OPTIMIZE --- by taking away all promptX's as that is
    %repetitive
    
    %promptg = '\nPlease enter 0 for only white to black transitions.\nPlease enter 1 for only black to white transitions.\nPlease enter 2 for both black to white and white to black transitions.';
    %w2bb2w = input(promptg);
    %if (isnumeric(w2bb2w) == 0)
    %    error('w2bb2w value must be numeric.')
    %elseif ((w2bb2w ~= 0) || (w2bb2w ~= 1) || (w2bb2w ~= 2))
    %    error('w2bb2w must be either 0 or 1 or 2.')
    %end
    
    while true;
        promptg = '\nPlease double check to see if you have entered the correct values. \nIf this is correct, type yes (lowercase). If it is not correct, press any key and you will be given another chance. Feel free to press Control+C to quit anytime. \n';
        str = input(promptg,'s');
        
        if strcmp(str,'yes')
            break;
        else
            fprintf('\nPlease double check and enter yes.\n')
        end
    end
    break;
end

end


%TDL:
%1. make all non-string entries.
%2. could refine the error possibilities so that code is more efficient and
%more types of errors can be captured.