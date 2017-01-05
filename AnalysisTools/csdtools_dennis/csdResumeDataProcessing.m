function output = csdResumeDataProcessing(path,tfile,header,data,tbefore,tafter,channels,transition,option)    %same inputs at Super2 with the exception of i_initial
%resume
%This function allows the user to resume the super2 process from a
%partially completed "X" cell.

%Criteria of this function
%ONLY CALL THIS FUNCTION IF (ROWS OF X ~= NUM_CHANNELS) && (THE FILE
%EXISTS INITIALLY) && (HAVE USER'S PERMISSION)
%implement the above line in CSDmapping

%Future Work
%To integrate this into CSDmapping. The integration will involve CSD
%mapping searching for the existence of the desired "X" cell and finding
%out the level of completion of the cell.

%Integration Steps
%1. Make CSDmapping have a selection for the user to select preference to
%resume the function.
%2. Integrate resume into the super2 lines of CSDmapping.

%option input = specifies which X file the user wants to 
%option = 1 --- only resumes for w2b
%option = 2 --- only resumes for b2w
%option = 3 --- resumes for both w2b and b2w

%Chances for option 3 are very low because usually one run has to
%completely finish before the other run has a chance to even crash. The
%only scenario I could imagine is if the user decides to run the alternate
%transition and it crashes too. In this case, we end up with two incomplete
%X data cells.

current = pwd;
location = [path tfile];

if option == 1
    cd(location)
    load([tfile 'w2b.mat'])
    cd(current)
    sizeXw2b = size(Xw2b);
    rowXw2b = sizeXw2b(1);
    Xaddw2b = super2(path,tfile,header,data,tbefore,tafter,channels,transition,rowXw2b+1);
    sizeXaddw2b = size(Xaddw2b);
    rowXaddw2b = sizeXaddw2b(1);
    Xw2b(rowXw2b+1:((rowXw2b+1)+rowXaddw2b),:) = Xaddw2b;  %must test if the syntax and convention works out here
    %could even write a function row add to append newly run data onto old data
    output = Xw2b;
elseif option == 2
    cd(location)
    load([tfile 'w2b.mat'])
    cd(current)
    sizeXb2w = size(Xb2w);
    rowXb2w = sizeXb2w(1);
    Xaddb2w = super2(path,tfile,header,data,tbefore,tafter,channels,transition,rowXb2w+1);
    sizeXaddb2w = size(Xaddb2w);
    rowXaddb2w = sizeXaddb2w(1);
    Xb2w(rowXb2w+1:((rowXb2w+1)+rowXaddb2w),:) = Xaddb2w;
    output = Xb2w;
elseif option == 3
    cd(location)
    load([tfile 'w2b.mat'])
    load([tfile 'b2w.mat'])
    cd(current)
    sizeXw2b = size(Xw2b);
    sizeXb2w = size(Xb2w);
    rowXw2b = sizeXw2b(1);
    rowXb2w = sizeXb2w(1);
    Xaddw2b = super2(path,tfile,header,data,tbefore,tafter,channels,0,rowXw2b+1);
    Xaddb2w = super2(path,tfile,header,data,tbefore,tafter,channels,1,rowXb2w+1);
    sizeXaddw2b = size(Xaddw2b);
    rowXaddw2b = sizeXaddw2b(1);
    Xw2b(rowXw2b+1:((rowXw2b+1)+rowXaddw2b),:) = Xaddw2b;
    sizeXaddb2w = size(Xaddb2w);
    rowXaddb2w = sizeXaddb2w(1);
    Xb2w(rowXb2w+1:((rowXb2w+1)+rowXaddb2w),:) = Xaddb2w;
    output = {Xw2b Xb2w};
else
    error('The input "option" must be a value between 1-3 inclusive')
end

end

