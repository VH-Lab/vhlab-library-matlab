function [L,H,I] = csdCalculate(X,gridloc,delta,channel_order,sync_channel_position,above_sync,below_sync)
%super_csd_interp
%To output the CSD array for a specified electrode and grid.
%
%Example:
%[L,H,I] = super_csd(X,coordinates_to_grid(15,7,15),100,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6])
%[L,H,I] = super_csd(X,coordinates_to_grid(1,1,10),25,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1 22 11 21 12 20 13 19 14 18 15 17 16])
%[L,H,I] = super_csd(X,coordinates_to_grid(1,1,10),25,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 1 22 11 21 12 20 13 19 14 18 15 17 16])
%[L,H,I] = super_csd(X,217,100,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6])
%[L,H,I] = super_csd(X,1,100,[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6])
%T = GetSGStimTriggers('/Users/dennisou/Desktop','t00022',179);
%
%
%myheader = readvhlvheaderfile([path filesep tfile filesep header])
%myheader = readvhlvheaderfile(['/Users/dennisou/Desktop/' filesep 't00001' filesep 'vhlvanaloginput.vlh']);
%
%[L,H,I] = super_csd_interp(Xw2b,coordinates_to_grid(9,1,10),25,[23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 1 22 11 21 12 20 13 19 14 18 15 17 16],sync_channel_position,above_sync,below_sync)
%
%NOTE:
%The If Statement on Line 77 has to be eliminated for exceptions.

%% Creating the LFP Array L
%gridloc = coordinates(x,y,rows);

%Isolating the relevant matrix
matrix = X(:,gridloc);  %This should output a 16 by 1 cell. Each element within this cell should be ~620 by 31.

%Converting to suitable format
matrix2 = [];

%NOTE: Could potentially take in num_triggers for all grids so the most
%complete data could be outputted.
s = size(matrix{1});    %[~620 31]
num_triggers = s(1);    %~620

channels = length(matrix);    %16 channels

%Converts matrix1 (16 by 1 cell with ~620 by 31 elements) into matrix2 (16 by 31 by ~620)
for i = 1:num_triggers  %iterates ~620 times
    temp = [];
    for j = 1:channels  %iterates 16 times
        temp(j,:) = matrix{j,1}(i,:);
    end
    matrix2(:,:,i) = temp;  %matrix2 will be a 16 by 31 by ~620 array.
end


%Need to convert columns to rows and rows to columns
s1 = size(matrix2); %[16 31 ~620]
depth = s1(3); %depth = ~620
matrix3 = [];

for i = 1:depth     %iterates ~620 times
    matrix3(:,:,i) = matrix2(:,:,i)';   %matrix3 will be a 31 by 16 by ~620 array.
end

matrix4 = mean(matrix3,3);  %averages matrix3 along the depth axis which results in matrix4 being a 31 by 16 array
L = matrix4';   %L is a 16 by 31 array

size_L = size(L);
rows_L = size_L(1);
columns_L = size_L(2);

%% Taking care of the offset
%L is either 16 or 31 rows
for i = 1:rows_L
    relevant_offset = L(i,1);
    for j = 1:columns_L
        L(i,j) = L(i,j) - relevant_offset;
    end
end

%% Creating the CSD array, H
%Note: The reason why the above was inverted and uninverted was because the
%31 by 16 format of matrix4 was compatible for the CSD code below; however,
%the 16 by 31 format of L has time as the x-axis which makes more sense for
%viewing. L will also be called out via the function superCSD and that is
%why this confusing step is necessary.

%T = GetSGStimTriggers(dirname,tfile,gridloc);   %a 1 by 620 array
%containing all triggers within the ~20min of training session. This is
%already accounted for in matrix X.

F = [];

%Accounting for the offset for all LFP values used in the CSD generating
%code after this
size_matrix3 = size(matrix3);
rows_matrix3 = size_matrix3(1);
cols_matrix3 = size_matrix3(2);
depth_matrix3 = size_matrix3(3);

for i = 1:depth_matrix3
    for j = 1:cols_matrix3
        relevant_offset = matrix3(1,j,i);
        for k = 1:rows_matrix3
            matrix3(k,j,i) = matrix3(k,j,i) - relevant_offset;
        end
    end
end

for i = 1:num_triggers %iterates ~620 times
    deltaX = delta*10^-6;     %Converting the delta[um] to deltaX[m]
    %channel_order = [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6]; % 16 channel order
    %channel_order = [23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 "32" 1 22 11 21 12 20 13 19 14 18 15 17 16]
    %above length = 31
    LFP = matrix3(:,:,i);
    CSD = [];

    %real function:
    for j = 2:(length(channel_order)-1) %2:15 or 2:30
        if (channel_order(j) == above_sync) && (sync_channel_position ~= 0)
            CSD(:,channel_order(j)) = (LFP(:,channel_order(j-2)) + LFP(:,channel_order(j+1)) ...   % CSD equation
             - 2*LFP(:,channel_order(j))) / ((deltaX*2)^2);
        elseif (channel_order(j) == below_sync) && (sync_channel_position ~= 0)
            CSD(:,channel_order(j)) = (LFP(:,channel_order(j-1)) + LFP(:,channel_order(j+2)) ...   % CSD equation
             - 2*LFP(:,channel_order(j))) / ((deltaX*2)^2);
        else
            CSD(:,channel_order(j)) = (LFP(:,channel_order(j-1)) + LFP(:,channel_order(j+1)) ...   % CSD equation
             - 2*LFP(:,channel_order(j))) / ((deltaX)^2);
        end
    end
    F(:,:,i) = CSD;
end

G = mean(F,3);  %Collapsing the array by averaging it.
H = G'; %Inverting the array so that the pcolor graph is easier to interpret

%% Removing (snipping) empty channels --- these empty channels are due to a discrepancy of not taking into account the first
%and last of the channel_order array

bad_rows = [channel_order(1) channel_order(end)];   %[23 16] in the case of the 31-channel electrode
for i = 1:length(bad_rows)
    H(bad_rows(i),:) = [];
end

%% Modifying the array L into a surf-friendly format I
I = pcolordummyrowcolumn(H);
end

%To do list:
%1. How about accounting only for 1 triggers or fewer grids? Might accounting
%for all triggers by averaging the corresponding LFP values lower the
%significance?