clc;
clear;
%Calculating execution time - Start [For ROI]
tic
%% Step 1: Add Path and Read Image
% Add the folder path to the required codes
addpath(genpath('D:\Codes\Isaac'));

% Read the input grayscale image (already provided)
Img = imread('Spleen.png');
%gray = rgb2gray(Img);
gray=Img;

% Save the original grayscale image to a folder
folder = 'D:\Codes\Isaac\Experimental Results\Spleen';
imwrite(gray, fullfile(folder, 'Original image.png'));

% Load ROI image
ROI = imread(fullfile(folder, 'ROI.png'));

% Convert to grayscale if needed
if ndims(ROI) == 3
    ROI = rgb2gray(ROI);
end

% Resize ROI to match gray image
ROI = imresize(ROI, [size(gray, 1), size(gray, 2)]);  % ? CORRECT

% Optional: Binarize if ROI is a mask
ROI = imbinarize(ROI);% % Step 2: Determine Threshold and Segment ROI

% %Use ATD to determine the optimum threshold
% threshold = ATD(gray);
% fprintf('Threshold value = %d\n', threshold);
% 
% %Segment the image using the threshold
% ROI = Isaac_SeperateROI(gray, threshold);
% 
% %Save the segmented ROI`
% imwrite(ROI, fullfile(folder, 'ROI.png'));




%% Step 3: Calculate the Histogram for ROI
% Get the histogram of the ROI area before splitting
grayHisto = Isaac_Histogram(gray, ROI, 1);

%% Step 4: Split Histogram
% Define the overcrowding threshold

% Dynamically calculate the threshold
overcrowding_threshold = ceil(max(grayHisto) / 2);  % Half of the highest bin value
%[modified_histogram] = IsaacSplitHistogram(grayHisto, overcrowding_threshold);
%[ROImax, ROImin] = Isaac_findpeak3(grayHisto, overcrowding_threshold,ROI,gray);
 

%reverse split image
%[histo_restored, image_restored] = Isaac_reversepeak3(grayHisto, k, hk, flag, gray);
    
% Save execution time
execution_time = toc;

fprintf('Execution time: %.2f seconds\n', execution_time);

%Get the histogram of the ROI area before stretching
[StretchedHisto,Lmin,Lmax,Pfn_position,Pln_position]=Isaac_findpeakbin(grayHisto);

%Stretching ROI with new equation before embedding
[grayStretch]=Isaac_GrayStretch(gray,ROI,1,Lmin,Lmax,Pfn_position,Pln_position);

% Writing stretched image and histogram to the Mine folder
folder='D:\Codes\Isaac\Experimental Results\Spleen';
imwrite(grayStretch,fullfile(folder,'ROIGrayStretch.png'));

f=figure('Visible','off');
f,imhist(uint8(grayStretch));
fname = 'D:\Codes\Isaac\Experimental Results\Spleen';
saveas(f, fullfile(fname, 'Strecthed image histogram'), 'png');


%Obtain the histogram of the expanded ROI area
stretchHisto_=Isaac_Histogram(grayStretch,ROI,1);
% Dynamically calculate the threshold


% Calculate execution time - End [For ROI]
elapsedTime = toc;
fprintf('Execution time: %.2f seconds\n', elapsedTime);


%% ROI Embedding process (First phase) - Isaac

%Size of payload
%totalLength=500000;
totalLength= 380000;
secretData=randi([0,1],1,totalLength);

%Embed the ROI area
ROIEmbeded=grayStretch;
ROIEmbedHisto=Isaac_Histogram(ROIEmbeded,ROI,1);
[m,n]=size(ROIEmbeded);

%ROI region first embedding
[Ph,Pl,max_position,min_position,case_]=Isaac_NewFindPeakbin(ROIEmbedHisto);

%% Variables for first round

%For peak bin Ph
maxFirstRound=max_position;

%For min bin Pl
minFirstRound=min_position;

%For case_
case_FirstRound=case_;
count=0;

%% For Case 0
if case_==0
    fprintf('No empty bin in original image ROI to embed\n');
    
    %% For Case 1
elseif case_==1
    numOfBitsFirstRound=0;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                if ROIEmbeded(i,j)==max_position&&numOfBitsFirstRound<totalLength
                    numOfBitsFirstRound=numOfBitsFirstRound+1;
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)-secretData(1,numOfBitsFirstRound);
                    count=count+1;
                    peak=Ph;
                    if numOfBitsFirstRound==totalLength
                        maxFirstRound=max_position;
                        minFirstRound=min_position;
                         case_FirstRound=case_;
                        fprintf('All bits embedded in first round, Ph postion=%d, Pl position==%d, case=%d, embedding capacity=%d \n',maxFirstRound, minFirstRound, caseFirstRound, numOfBitsFirstRound);
                        break;
                    end
                end
            end
        end
    end
    
    %% For Case 2
elseif case_==2
    numOfBitsFirstRound=0;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                if ROIEmbeded(i,j)==max_position&&numOfBitsFirstRound<totalLength
                    numOfBitsFirstRound=numOfBitsFirstRound+1;
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)+secretData(1,numOfBitsFirstRound);
                    count=count+1;
                    peak=Ph;
                    if numOfBitsFirstRound==totalLength
                        maxFirstRound=max_position;
                        minFirstRound=min_position;
                        case_FirstRound=case_;
                        fprintf('All bits embedded in first round, Ph postion=%d, Pl position==%d, case=%d, embedding capacity=%d \n',maxFirstRound, minFirstRound, caseFirstRound, numOfBitsFirstRound);
                        break;
                    end
                end
            end
        end
    end
    
    
    %% For Case 3
elseif case_==3
    numOfBitsFirstRound=0;
    %Shifting Procedure
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                %Shifting pixels to the left
                if ROIEmbeded(i,j)<max_position&&ROIEmbeded(i,j)>=min_position
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)-1; %Performing the left shift of pixels
                end
            end
        end
    end
    
        %Embedding Procedure
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                if ROIEmbeded(i,j)==max_position&&numOfBitsFirstRound<totalLength
                    numOfBitsFirstRound=numOfBitsFirstRound+1;
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)-secretData(1,numOfBitsFirstRound);
                    count=count+1;
                    peak=Ph;
                    if numOfBitsFirstRound==totalLength
                        maxFirstRound=max_position;
                        minFirstRound=min_position;
                        case_FirstRound=case_;
                        fprintf('All bits embedded in first round, Ph postion=%d, Pl position==%d, case=%d, embedding capacity=%d \n',maxFirstRound, minFirstRound, case_FirstRound, numOfBitsFirstRound);
                        break;
                    end
                end
            end
        end
    end
    
    
    %% For Case 4
elseif case_==4
    numOfBitsFirstRound=0;
    %Shifting Procedure
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                %Shifting pixels to the left
                if ROIEmbeded(i,j)>max_position&&ROIEmbeded(i,j)<=min_position
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)+1; %Performing the left shift of pixels
                end
            end
        end
    end
    
    %Embedding Procedure
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                if ROIEmbeded(i,j)==max_position&&numOfBitsFirstRound<totalLength
                    numOfBitsFirstRound=numOfBitsFirstRound+1;
                    ROIEmbeded(i,j)=ROIEmbeded(i,j)+secretData(1,numOfBitsFirstRound);
                    count=count+1;
                    peak=Ph;
                    if numOfBitsFirstRound==totalLength
                        maxFirstRound=max_position;
                        minFirstRound=min_position;
                        case_FirstRound=case_;
                        fprintf('All bits embedded in first round, Ph postion=%d, Pl position==%d, case=%d, embedding capacity=%d \n',maxFirstRound, minFirstRound, caseFirstRound, numOfBitsFirstRound);
                        break;
                    end
                end
            end
        end
    end
end

%Displaying results for first round
fprintf('After first round of embedding in ROI, maxFirstRound=%d, minFirstRound=%d, case_FirstRound=%d, embedding capacity in ROI=%d \n',maxFirstRound, minFirstRound, case_FirstRound, numOfBitsFirstRound);

%% Embedding into rest of ROI

%Total embedded bits in ROI
numOfBitsROI=numOfBitsFirstRound;

%Size of last embedded bits
numOfBitsLastRound=0;

%% Variables for the remaining rounds

%For peak bin Ph
maxLastRound=maxFirstRound;

%For min bin Pl
minLastRound=minFirstRound;

%For case_
case_LastRound=case_FirstRound;
count=0;

%Declaring and Initiating Variables for last but one values
max_positionn=0; min_positionn=0; casee=0;

%Binary of max_position, min_postion, and case_ embedded in subsequent peak bins
eightBitsOfmax_postion=dec2base(maxLastRound,2,8);
eightBitsOfmin_postion=dec2base(minLastRound,2,8);
fourBitsOfcase_=dec2base(case_LastRound,2,4);

%Initializing while loop
while 1
    %ROI Histogram Definition
    ROIEmbedHisto=Isaac_Histogram(ROIEmbeded,ROI,1);
    
    %Finding peak bin and other variables in ROI
    [Ph,Pl,max_position,min_position,case_]=Isaac_NewFindPeakbin(ROIEmbedHisto);
    
    %     %Taking the last value of case instead of the zero
    %     if case_~=0
    %
    %         %Declaring and Initiating Variables for last but one values
    %         max_positionn=0; min_positionn=0; casee=0;
    %
    %         %Assigning values to variables
    %         max_positionn=max_position;
    %         min_positionn=min_position;
    %         casee=case_;
    %     end
    
    
    %% For Case 1
    if case_==-12
        
        %Determine to embed previous Ph or payload
        max_isReachEight=0;
        min_isReachEight=0;
        case_isReachFour=0;
        
        %Embedding Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    if max_isReachEight<8&&min_isReachEight==0&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            max_isReachEight=max_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(eightBitsOfmax_postion(1,max_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmax_postion(1,max_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight<8&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            min_isReachEight=min_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(eightBitsOfmin_postion(1,min_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmin_postion(1,min_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour<4
                        if ROIEmbeded(i,j)==max_position
                            case_isReachFour=case_isReachFour+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(fourBitsOfcase_(1,case_isReachFour));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',fourBitsOfcase_(1,case_isReachFour));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour==4
                        if ROIEmbeded(i,j)==max_position&&numOfBitsROI<totalLength
                            numOfBitsROI=numOfBitsROI+1;
                            numOfBitsLastRound=numOfBitsLastRound+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-secretData(1,numOfBitsROI);
                            count=count+1;
                        end
                    end
                end
            end
        end
        
        maxLastRound=max_position;
        minLastRound=min_position;
        case_LastRound=case_;
        
        %Assigning values to variables
        % NB - Last iteration values stays
        max_positionn=max_position;
        min_positionn=min_position;
        casee=case_;
        
        % Eight bits variables
        eightBitsOfmax_postion=dec2base(maxLastRound,2,8);
        eightBitsOfmin_postion=dec2base(minLastRound,2,8);
        fourBitsOfcase_=dec2base(case_LastRound,2,4);
        
        %Concluding and showing results
        numOfBitsLastRoundRecord=numOfBitsLastRound;
        numOfBitsLastRound=0;
        fprintf('\nEmbed maxLastRound=%d, minLastRound=%d, case_LastRound=%d, bits=%d, Ph=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsLastRoundRecord,Ph);
        if numOfBitsROI==totalLength
            fprintf('Full payload embedded into ROI, maxLastRound=%d, minLastRound=%d, case_LastRound=%d, embedding capacity in ROI=%d, last round payload=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsROI,numOfBitsLastRoundRecord);
            break;
        end
        
        
        %% For Case 2
    elseif case_==2
        
        %Determine to embed previous Ph or payload
        max_isReachEight=0;
        min_isReachEight=0;
        case_isReachFour=0;
        
        %Embedding Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    if max_isReachEight<8&&min_isReachEight==0&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            max_isReachEight=max_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(eightBitsOfmax_postion(1,max_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmax_postion(1,max_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight<8&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            min_isReachEight=min_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(eightBitsOfmin_postion(1,min_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmin_postion(1,min_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour<4
                        if ROIEmbeded(i,j)==max_position
                            case_isReachFour=case_isReachFour+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(fourBitsOfcase_(1,case_isReachFour));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',fourBitsOfcase_(1,case_isReachFour));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour==4
                        if ROIEmbeded(i,j)==max_position&&numOfBitsROI<totalLength
                            numOfBitsROI=numOfBitsROI+1;
                            numOfBitsLastRound=numOfBitsLastRound+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+secretData(1,numOfBitsROI);
                            count=count+1;
                        end
                    end
                end
            end
        end
        
        maxLastRound=max_position;
        minLastRound=min_position;
        case_LastRound=case_;
        
        %Assigning values to variables
        % NB - Last iteration values stays
        max_positionn=max_position;
        min_positionn=min_position;
        casee=case_;
        
        % Eight bits variables
        eightBitsOfmax_postion=dec2base(maxLastRound,2,8);
        eightBitsOfmin_postion=dec2base(minLastRound,2,8);
        fourBitsOfcase_=dec2base(case_LastRound,2,4);
        
        %Concluding and showing results
        numOfBitsLastRoundRecord=numOfBitsLastRound;
        numOfBitsLastRound=0;
        fprintf('\nEmbed maxLastRound=%d, minLastRound=%d, case_LastRound=%d, bits=%d, Ph=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsLastRoundRecord,Ph);
        if numOfBitsROI==totalLength
            fprintf('Full payload embedded into ROI, maxLastRound=%d, minLastRound=%d, case_LastRound=%d, embedding capacity in ROI=%d, last round payload=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsROI,numOfBitsLastRoundRecord);
            break;
        end
        
        
        %% For Case 3
    elseif case_==3
        
        %Determine to embed previous Ph or payload
        max_isReachEight=0;
        min_isReachEight=0;
        case_isReachFour=0;
        
        %Shifting Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    %Shifting pixels to the left
                    if ROIEmbeded(i,j)<max_position&&ROIEmbeded(i,j)>=min_position
                        ROIEmbeded(i,j)=ROIEmbeded(i,j)-1; %Performing the left shift of pixels
                    end
                end
            end
        end
        
        
        %Embedding Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    if max_isReachEight<8&&min_isReachEight==0&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            max_isReachEight=max_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(eightBitsOfmax_postion(1,max_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmax_postion(1,max_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight<8&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            min_isReachEight=min_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(eightBitsOfmin_postion(1,min_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmin_postion(1,min_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour<4
                        if ROIEmbeded(i,j)==max_position
                            case_isReachFour=case_isReachFour+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-str2double(fourBitsOfcase_(1,case_isReachFour));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',fourBitsOfcase_(1,case_isReachFour));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour==4
                        if ROIEmbeded(i,j)==max_position&&numOfBitsROI<totalLength
                            numOfBitsROI=numOfBitsROI+1;
                            numOfBitsLastRound=numOfBitsLastRound+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)-secretData(1,numOfBitsROI);
                            count=count+1;
                        end
                    end
                end
            end
        end
        
        maxLastRound=max_position;
        minLastRound=min_position;
        case_LastRound=case_;
        
        %Assigning values to variables
        % NB - Last iteration values stays
        max_positionn=max_position;
        min_positionn=min_position;
        casee=case_;
        
        % Eight bits variables
        eightBitsOfmax_postion=dec2base(maxLastRound,2,8);
        eightBitsOfmin_postion=dec2base(minLastRound,2,8);
        fourBitsOfcase_=dec2base(case_LastRound,2,4);
        
        %Concluding and showing results
        numOfBitsLastRoundRecord=numOfBitsLastRound;
        numOfBitsLastRound=0;
        fprintf('\nEmbed maxLastRound=%d, minLastRound=%d, case_LastRound=%d, bits=%d, Ph=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsLastRoundRecord,Ph);
        if numOfBitsROI==totalLength
            fprintf('Full payload embedded into ROI, maxLastRound=%d, minLastRound=%d, case_LastRound=%d, embedding capacity in ROI=%d, last round payload=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsROI,numOfBitsLastRoundRecord);
            break;
        end
        
        
        %% For Case 4
    elseif case_==4
        
        %Determine to embed previous Ph or payload
        max_isReachEight=0;
        min_isReachEight=0;
        case_isReachFour=0;
        
        %Shifting Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    %Shifting pixels to the right
                    if ROIEmbeded(i,j)>max_position&&ROIEmbeded(i,j)<=min_position
                        ROIEmbeded(i,j)=ROIEmbeded(i,j)+1; %Performing the left shift of pixels
                    end
                end
            end
        end
        
        
        %Embedding Procedure
        for i=1:m
            for j=1:n
                if ROI(i,j)==0
                    if max_isReachEight<8&&min_isReachEight==0&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            max_isReachEight=max_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(eightBitsOfmax_postion(1,max_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmax_postion(1,max_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight<8&&case_isReachFour==0
                        if ROIEmbeded(i,j)==max_position
                            min_isReachEight=min_isReachEight+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(eightBitsOfmin_postion(1,min_isReachEight));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',eightBitsOfmin_postion(1,min_isReachEight));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour<4
                        if ROIEmbeded(i,j)==max_position
                            case_isReachFour=case_isReachFour+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+str2double(fourBitsOfcase_(1,case_isReachFour));
                            count=count+1;
                            
                            %Embedded Ph binary value
                            fprintf('%c ',fourBitsOfcase_(1,case_isReachFour));
                        end
                    elseif max_isReachEight==8&&min_isReachEight==8&&case_isReachFour==4
                        if ROIEmbeded(i,j)==max_position&&numOfBitsROI<totalLength
                            numOfBitsROI=numOfBitsROI+1;
                            numOfBitsLastRound=numOfBitsLastRound+1;
                            ROIEmbeded(i,j)=ROIEmbeded(i,j)+secretData(1,numOfBitsROI);
                            count=count+1;
                        end
                    end
                end
            end
        end
        
        maxLastRound=max_position;
        minLastRound=min_position;
        case_LastRound=case_;
        
        %Assigning values to variables
        % NB - Last iteration values stays
        max_positionn=max_position;
        min_positionn=min_position;
        casee=case_;
        
        % Eight bits variables
        eightBitsOfmax_postion=dec2base(maxLastRound,2,8);
        eightBitsOfmin_postion=dec2base(minLastRound,2,8);
        fourBitsOfcase_=dec2base(case_LastRound,2,4);
        
        %Concluding and showing results
        numOfBitsLastRoundRecord=numOfBitsLastRound;
        numOfBitsLastRound=0;
        fprintf('\nEmbed maxLastRound=%d, minLastRound=%d, case_LastRound=%d, bits=%d, Ph=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsLastRoundRecord,Ph);
        if numOfBitsROI==totalLength
            fprintf('Full payload embedded into ROI, maxLastRound=%d, minLastRound=%d, case_LastRound=%d, embedding capacity in ROI=%d, last round payload=%d\n',maxLastRound,minLastRound,case_LastRound,numOfBitsROI,numOfBitsLastRoundRecord);
            break;
        end
        
        
    else
        %% For Case 0
        fprintf('No more empty bins in the original image ROI to embed, maxLastRound=%d, embedding capacity in ROI=%d, last round payload=%d\n',maxLastRound,numOfBitsROI,numOfBitsLastRoundRecord);
        %         case_=casee;
        break;
    end
end

%Finding the histogram of the new ROI
ROIEmbedHisto=Isaac_Histogram(ROIEmbeded,ROI,1);

%Writing image to the Mine folder
folder='D:\Codes\Isaac\Experimental Results\slice_0';
imwrite(ROIEmbeded,fullfile(folder,'ROI_embedded.jpg'));

%Calculating number of iterations
fprintf('Number of iterations=%d\n',count);

% %Calculating execution time - Stop [For ROI]
% toc

%% NROI Section

% %Calculating execution time - Start [For NROI]
% tic

%Obtain the grayscale histogram of the NROI area
NROIHisto=Isaac_Histogram(ROIEmbeded,ROI,2);

%Preprocessing the NROI area
NROIPreprocess=ROIEmbeded;
[NROIPreprocess,NROIminPixel]=Isaac_NROIPreprocessing(NROIPreprocess,ROI);

%Obtain the gray histogram of the preprocessed NROI area
NROIPreprocessHisto=Isaac_Histogram(NROIPreprocess,ROI,2);
folder='D:\Codes\Isaac\Experimental Results\slice_0';
imwrite(NROIPreprocess,fullfile(folder,'NROIPreprocess.jpg'));

%%
%Total number of bits embedded in side information
%LocationMap(2*log2m*n),Dshift(8),klast(8),ROImax(8),ROImin(8),Lmax(8),Lmin(8),PsROI(18),PsNROI(19)
[m,n]=size(NROIPreprocess);
numOfBitsSideInfo=2*log2(n)*m+48+37;

%%
%NROI region embedding
NROIEmbeded=NROIPreprocess;
[m,n]=size(ROIEmbeded);

%Remaining embedding capacity after ROI embedding
numOfBitsNROI=totalLength-numOfBitsROI;
fprintf('Total payload size=%d\n',totalLength);
fprintf('ROI embedded bits=%d\n',numOfBitsROI);
fprintf('Bits to be embedded into NROI=%d\n',numOfBitsNROI);

%Number of pixels in NROI area
numOfNROIPixels=0;
for i=1:m
    for j=1:n
        if ROI(i,j)~=0
            numOfNROIPixels=numOfNROIPixels+1;
        end
    end
end

%Number of LSBs to be embedded per pixel
LSBbits=ceil((numOfBitsNROI+numOfBitsSideInfo)/(numOfNROIPixels-2));
fprintf('LSB bits to be modified for NROI pixels=%d\n',LSBbits);


%First modify the LSB of the first two pixels of the NROI area, 01, 10, 11 to mark the number of modified
%   LSBs for each pixel, and then embed the LBPbits of the remaining pixels.

%Determine whether the LSB modification of the first two pixels is completed
isReachTwo=0;
numOfBitsNROI=0;
if LSBbits==1
    for i=1:m
        for j=1:n
            if ROI(i,j)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='0';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==2&&numOfBitsROI+numOfBitsNROI<totalLength
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded in NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                end
            end
        end
    end
elseif LSBbits==2
    for i=1:m
        for j=1:n
            if ROI(i,j)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='0';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==2&&numOfBitsROI+numOfBitsNROI<totalLength
                    %Embed the last digit
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded in NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                    %Embed the second last bit
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,7)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded in NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                end
            end
        end
    end
elseif LSBbits==3
    for i=1:m
        for j=1:n
            if ROI(i,j)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marked pixel %d\n',NROIEmbeded(i,j));
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(i,j));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==2&&numOfBitsROI+numOfBitsNROI<totalLength
                    %Embed the last digit
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,8)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded into NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                    %Embed the second last bit
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,7)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded in NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                    %Embed the third-to-last
                    numOfBitsNROI=numOfBitsNROI+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(i,j),2,8);
                    eightBitsOfPixel(1,6)=num2str(secretData(1,numOfBitsROI+numOfBitsNROI));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(i,j)=pixelModified;
                    if numOfBitsROI+numOfBitsNROI==totalLength
                        %Secret information has all been embedded in NROI
                        fprintf('Secret data fully embedded into NROI, embedding capacity = %d\n',numOfBitsNROI);
                        break;
                    end
                end
            end
        end
    end
else
    fprintf('The number of bits to be modified for each pixel is greater than 3, which does not meet the requirements\n');
end
% NROIEmbedHisto=Histogram(NROIEmbeded,ROI,2);
% imwrite(NROIEmbeded,'NROIEmbeded.png');

%%
%Embed secondary information
[m,n]=size(NROIEmbeded);
LocationMapRecord=zeros(m,2);
for i=1:m
    for j=1:n
        if ROI(i,j)==0
            LocationMapRecord(i,1)=j;
        end
    end
end
for i=1:m
    for j=1:n
        if ROI(i,n-j+1)==0
            LocationMapRecord(i,2)=n-j+1;
        end
    end
end

LocationMap=zeros(1,round(2*log2(n)*m));%Genrate locationmap to mark ROI and NROI
record=0;
for j=1:n
    y1x=dec2base(LocationMapRecord(j,2),2,round(log2(n)));
    y2x=dec2base(LocationMapRecord(j,1),2,round(log2(n)));
    for k=1:log2(n)
        record=record+1;
        LocationMap(1,record)=str2double(y1x(1,k));
    end
    for k=1:log2(n)
        record=record+1;
        LocationMap(1,record)=str2double(y2x(1,k));
    end
end

% For case_(8)
%Storing casee instead of case_ to store the previous case_
case_=casee;
sideinfo_case_=zeros(1,8);
bi_case_=dec2base(case_,2,8);
for k=1:4
    sideinfo_case_(1,k)=str2double(bi_case_(1,k));
end

% For max_position(8)
%Storing max_positionn instead of max_position to store the previous max_position
max_position=max_positionn;
sideinfo_max_position=zeros(1,8);
bi_max_position=dec2base(max_position,2,8);
for k=1:8
    sideinfo_max_position(1,k)=str2double(bi_max_position(1,k));
end

% For min_position(8)
%Storing min_positionn instead of min_position to store the previous min_position
min_position=min_positionn;
sideinfo_min_position=zeros(1,8);
bi_min_position=dec2base(min_position,2,8);
for k=1:8
    sideinfo_min_position(1,k)=str2double(bi_min_position(1,k));
end

% For ROIps(19)
sideinfo_ROIps=zeros(1,19);%Build payloadsizeROI side information
binROIps=dec2base(numOfBitsROI,2,19);
for k=1:19
    sideinfo_ROIps(1,k)=str2double(binROIps(1,k));
end

sideinfo_PSNROI=zeros(1,19);%Build payloadsizeNROI side information
binPSNROI=dec2base(numOfBitsNROI,2,19);
for k=1:19
    sideinfo_PSNROI(1,k)=str2double(binPSNROI(1,k));
end



sideinfo=[LocationMap,sideinfo_ROIps,sideinfo_PSNROI,sideinfo_max_position,sideinfo_min_position,sideinfo_case_];
sideinfo_siLength=zeros(1,18);%Length of generated side information
binsiLength=dec2base(length(sideinfo),2,18);

%%Embed from the last pixel forward
numOfBitsSideinfo=0;
isReachTwo=0;
if LSBbits==1
    for i=1:m
        for j=1:n
            if ROI(m-i+1,n-j+1)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='0';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marker pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo>1&&isReachTwo<20 %Mark the length of the side information
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=binsiLength(1,isReachTwo-1);
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==20&&numOfBitsSideinfo<length(sideinfo)
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                end
            end
        end
    end
elseif LSBbits==2
    for i=1:m
        for j=1:n
            if ROI(m-i+1,n-j+1)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marker pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='0';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo>1&&isReachTwo<20 %Mark the length of the side information
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=binsiLength(1,isReachTwo-1);
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==20&&numOfBitsSideinfo<length(sideinfo)
                    %Embed the last digit
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                    %Embed the second last bit
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,7)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                end
            end
        end
    end
elseif LSBbits==3
    for i=1:m
        for j=1:n
            if ROI(m-i+1,n-j+1)~=0
                if isReachTwo==0
                    fprintf('First marked pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==1
                    fprintf('Second marker pixel %d\n',NROIEmbeded(m-i+1,n-j+1));
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)='1';
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    fprintf('After the mark is %d\n',NROIEmbeded(m-i+1,n-j+1));
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo>1&&isReachTwo<20%Mark the length of the side information
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=binsiLength(1,isReachTwo-1);
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    isReachTwo=isReachTwo+1;
                elseif isReachTwo==20&&numOfBitsSideinfo<length(sideinfo)
                    %Embed the last digit
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,8)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                    %Embed the second last bit
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,7)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                    %Embed the third-to-last
                    numOfBitsSideinfo=numOfBitsSideinfo+1;
                    eightBitsOfPixel=dec2base(NROIEmbeded(m-i+1,n-j+1),2,8);
                    eightBitsOfPixel(1,6)=num2str(sideinfo(1,numOfBitsSideinfo));
                    pixelModified=Isaac_Binary2Dec(eightBitsOfPixel);
                    NROIEmbeded(m-i+1,n-j+1)=pixelModified;
                    if numOfBitsSideinfo==length(sideinfo)
                        %All information has been embedded into NROI
                        fprintf('Side information embedded into NROI, size of side information = %d\n',numOfBitsSideinfo);
                        break;
                    end
                end
            end
        end
    end
else
    fprintf('The number of bits to be modified for each pixel is greater than 3, which does not meet the requirements! \n');
end
NROIEmbedHisto=Isaac_Histogram(NROIEmbeded,ROI,2);
folder='D:\Codes\Isaac\Experimental Results\slice_0';
imwrite(NROIEmbeded,fullfile(folder,'NROIEmbeded.png'));

f=figure('Visible','off');
f,imhist(uint8(NROIEmbeded));
fname = 'D:\Codes\Isaac\Experimental Results\slice_0';
saveas(f, fullfile(fname, 'NROIEmbeded histogram'), 'png');

%Calculating execution time - Stop
% toc



% %% Extraction and Recovery - NROI
toc

%%
%Quality Assessment Metrics
PSNR=Isaac_PSNR(gray,NROIEmbeded);
SSIM=Isaac_SSIM(gray,NROIEmbeded);
[REE,RCE,RMBE,RSS]=Isaac_ComprehensiveEvaluation(gray,NROIEmbeded);
VIF = vifvec(gray, NROIEmbeded);
fprintf('PSNR=%f\nSSIM=%f\nREE=%f\nRCE=%f\nRMBE=%f\nRSS=%f\nVIF=%f\n',PSNR,SSIM,REE,RCE,RMBE,RSS,VIF);

