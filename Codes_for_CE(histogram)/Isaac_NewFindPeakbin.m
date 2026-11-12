function [Ph,Pl,max_position,min_position,case_] = Isaac_findpeakbin(histo)
% Find peak bin Ph and lowest bin Pl is needed
% histo is the grayscale histogram of the ROI area

%Note: Maintain the shift to show the condition that was used

%Initializing variables
%Highest bin
Ph=max(histo);

%Lowest bin
Pl=9999999;

%Position of pixel in original image
max_position=-1; min_position=-1;

%Direction of shift
case_=0;

%Case conditions
condition_1=0; condition_2=0;



for index=1:256
    %Case 1
    if index>1&&index<=256&&histo(1,index)==Ph&&histo(1,index)>=8&&histo(1,index-1)==0
        max_position=index;
        case_=1;
        condition_1=1;
        Ph=histo(1,index);
        min_position=index-1;
        Pl=histo(1,index-1);
        
        %Case 2
    elseif index>=1&&index<256&&histo(1,index)==Ph&&histo(1,index)>=8&&histo(1,index+1)==0
        max_position=index;
        case_=2;
        condition_1=1;
        condition_2=1;
        Ph=histo(1,index); 
        min_position=index+1;
        Pl=histo(1,index+1);
    end
end

%Case based on conditions
if condition_1==0||max_position>255
    for max_index=1:256
        %Case 3
        if max_index>=1&&max_index<=256&&histo(1,max_index)==Ph&&histo(1,max_index)>=8
            max_position=max_index;
            Ph=histo(1,max_index);
        end
    end
    
    for min_index=1:256 %We start to search from 2 to avoid underflow
        if min_index>=2&&min_index<max_position&&histo(1,min_index)<Ph&&histo(1,min_index-1)==0
            case_=3;
            min_position=min_index;
            Pl=histo(1,min_index);
        end
    end
end
    
if min_position<2
    for max_index=1:256
        %Case 4
        if max_index>=1&&max_index<=256&&histo(1,max_index)==Ph&&histo(1,max_index)>=8
            max_position=max_index;
            Ph=histo(1,max_index);
        end
    end
    
    for min_index=1:256 %We start to search from 3 to avoid underflow
        if min_index>max_position&&min_index<=255&&histo(1,min_index)<Ph&&histo(1,min_index+1)==0
            case_=4;
            min_position=min_index;
            Pl=histo(1,index);
        end
    end
end

%Substracting 1 from index because of range
max_position=max_position-1;
min_position=min_position-1;