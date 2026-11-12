function [Peak,Peak_position,Peak_2,Peak_2_position,Lowest,Lowest_position,Lowest_2,Lowest_2_position,check_1] = Isaac_FindVariables(histo)

%Initializing variables
%Finding the Highest bin and its position
Peak=max(histo); Peak_position=-1;

%Finding the Second Highest bin and its position
Peak_2=-1; Peak_2_position=-1;

%Finding the Lowest bin and its position
Lowest=-1; Lowest_position=-1;

%Finding the Second Lowest bin and its position
Lowest_2=-1; Lowest_2_position=-1;

%Variable for new histogram
New_Histo=histo;
check_1 = 0;
% space_ = 0;
% space_2 = 0;
%% Main Codes

% Sort the array in descending order
NewHisto_ = sort(histo, 'descend');

% Access the element at the second index of the sorted array
Peak_2 = NewHisto_(2);

%Finding the Highest bin and its position
for index_Peak=1:256
    if (index_Peak>1)&&(index_Peak<=256)&&(New_Histo(1,index_Peak)==Peak)
        Peak_position=index_Peak;
        Peak=New_Histo(1,index_Peak);
        index_Peak=0;
        break;
    end
end

%Finding the Second Highest bin and its position
for index_Peak_2=1:256
    if index_Peak_2>1&&index_Peak_2<=256&&New_Histo(1,index_Peak_2)==Peak_2
        Peak_2_position=index_Peak_2;
        Peak_2=New_Histo(1,index_Peak_2);
        index_Peak_2=0;
        break;
    end
end

%Comparing Peak and Peak_2 
if (Peak_position < Peak_2_position)
    check_1 = 1;
elseif (Peak_position > Peak_2_position)
    check_1 = 2;
end

%Checking if there are an empty bins before and after Peak
%Check_1 equals 1 means pair peak and lowest, pair peak_2 and lowest_2
if (check_1 == 1)
    for index_Lowest=1:Peak_position
        if ((Peak_position-index_Lowest)>=0) && ((Peak_position-index_Lowest)<=256) && New_Histo(1,(Peak_position-index_Lowest))==0
            Lowest_position=(Peak_position-index_Lowest);
            Lowest=New_Histo(1,(Peak_position-index_Lowest));
            index_Lowest=0;
            break;
        end
    end
    
    for index_Lowest_2=Peak_2_position:256
        if (index_Lowest_2<=256) && New_Histo(1,index_Lowest_2)==0
            Lowest_2_position=index_Lowest_2;
            Lowest_2=New_Histo(1,index_Lowest_2);
            index_Lowest_2=0;
            break;
        end
    end
    
%     if (Lowest_position+1)==Peak_position
%         space_=1;
%     else
%         space_=0;
%     end
%     
%     if (Lowest_2_position-1)==Peak_2_position
%         space_2=1;
%     else
%         space_2=0;
%     end
%  
    
%Check_1 equals 2 means pair peak_2 and lowest, pair peak and lowest_2
elseif (check_1 == 2)
    for index_Lowest=1:Peak_2_position
        if ((Peak_2_position-index_Lowest)>=0) && ((Peak_2_position-index_Lowest)<=256) && New_Histo(1,(Peak_2_position-index_Lowest))==0
            Lowest_position=(Peak_2_position-index_Lowest);
            Lowest=New_Histo(1,(Peak_2_position-index_Lowest));
            index_Lowest=0;
            break;
        end
    end
    
    for index_Lowest_2=Peak_position:256
        if (index_Lowest_2<=256) && New_Histo(1,index_Lowest_2)==0
            Lowest_2_position=index_Lowest_2;
            Lowest_2=New_Histo(1,index_Lowest_2);
            index_Lowest_2=0;
            break;
        end
    end
    
%     if (Lowest_position+1)==Peak_2_position
%         if (check_1 == 1)
%             space_=2;
%         elseif (check_1 == 2)
%             space_=3;
%         end
%         
%     else
%         space_=0;
%     end
    
%     if (Lowest_2_position-1)==Peak_position
%         if (check_1 == 1)
%             space_2=2;
%         elseif (check_1 == 2)
%             space_2=3;
%         end
%     else
%         space_2=0;
%     end
end
end