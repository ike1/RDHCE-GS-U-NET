function [Pfn_2,Pfn_position_2,Before_Pfn_2,After_Pfn_2,Psn_2,Psn_position_2,Before_Psn_2,After_Psn_2,check_1,countL,countR,direction] = Isaac_findpeakbin_2(histo)
% Find peak bin Ph and the first non-zero bin Pf
% histo is the grayscale histogram of the ROI area

%Note: Maintain the shift to show the condition that was used

%Initializing variables
%Finding the Highest bin and its position
Ph_2=max(histo); Ph_position_2=-1;

%Finding the First Non-Zero bin and its position
Pfn_2=-1; Pfn_position_2=-1; Before_Pfn_2=0; After_Pfn_2=0;

%Finding the Second Non-Zero bin and its position
Psn_2=-1; Psn_position_2=-1; Before_Psn_2=0; After_Psn_2=0;

%Variable to find the highest
check_1=0;

%Variables to count number of empty bins for left and right
countL=0; countR=0;

%Variable for direction
direction=0;


%Variable for new histogram
New_Histo=histo;



%% Conditions to shift pixels
%Finding the Highest bin and its position
for index_Ph=1:256
    if index_Ph>1&&index_Ph<=256&&New_Histo(1,index_Ph)==Ph_2
        Ph_position_2=index_Ph;
        Ph_2=New_Histo(1,index_Ph);
        index_Ph=0;
        break;
    end
end


%% Finding the fist non-zero bin and its position
for index_Pfn=1:256
    if New_Histo(1,index_Pfn)>0
        Pfn_position_2=index_Pfn;
        Pfn_2=New_Histo(1,index_Pfn);
        index_Pfn=0;
        break;
    end
end

%Checking if there are an empty bins before and after Pfn
%Before
if New_Histo(1,Pfn_position_2-1)== 0
    Before_Pfn_2=1;
end

%After
if New_Histo(1,Pfn_position_2+1)== 0
    After_Pfn_2=1;
end


%% Finding the second non-zero bin and its position
for index_Psn=Pfn_position_2+1:256
    if New_Histo(1,index_Psn)>0
        Psn_position_2=index_Psn;
        Psn_2=New_Histo(1,index_Psn);
        index_Psn=0;
        break;
    end
end

%Checking if there are an empty bins before and after Pfn
%Before
if New_Histo(1,Psn_position_2-1)== 0
    Before_Psn_2=1;
end

%After
if New_Histo(1,Psn_position_2+1)== 0
    After_Psn_2=1;
end


%% Comparing both methods
%NB: check_1 equal to 1 means Pfn_2 is the highest
if (Pfn_2 > Psn_2)
    check_1 = 1;
end


if (check_1 == 1)
    for index_Pfn_L=1:Pfn_position_2
        if ((Pfn_position_2-index_Pfn_L)>=0) && New_Histo(1,(Pfn_position_2-index_Pfn_L))==0
            countL= countL + 1;
        else
            break;
        end
        
%         if ((Pfn_position_2-index_Pfn_L-1)>=0) && (New_Histo(1,(Pfn_position_2-index_Pfn_L-1))>=0) 
%             break;
%         end
    end
    
    index_Pfn_L=0;
    
    for index_Pfn_R=Pfn_position_2+1:256
        if New_Histo(1,index_Pfn_R)==0
            countR= countR + 1;
        else
            break;
        end
        
%         if ((index_Pfn_R+1)<256) && New_Histo(1,index_Pfn_R+1)>0
%             break;
%         end
    end
    index_Pfn_R=0;
    
elseif (check_1 == 0)
    
    for index_Psn_L=1:Psn_position_2
        if ((Psn_position_2-index_Psn_L)>=0) && New_Histo(1,(Psn_position_2-index_Psn_L))==0
            countL= countL + 1;
        else
            break;
        end
        
%         if ((Psn_position_2-index_Psn_L-1)>=0) && New_Histo(1,(Psn_position_2-index_Psn_L-1))>0
%             break;
%         end
    end
    
    index_Psn_L=0;
    
    for index_Psn_R=Psn_position_2+1:256
        if New_Histo(1,index_Psn_R)==0
            countR= countR + 1;
        else
            break;
        end
        
%         if ((index_Psn_R+1)<256) && New_Histo(1,index_Psn_R+1)>0
%             break;
%         end
    end
    index_Psn_R=0;    
end

% Finding direction to embed
%NB:No empty bin on bothsides
if (countL <- 0) && (countR <= 0) && (countL == countR)
    direction = 0;

%NB: Both equal empty bin on bothsides, embed left
elseif (countL > 0) && (countR > 0) && (countL == countR)
    direction = 1;

%NB:Number of empty bin on left greater than number of empty bin on right, embed left
elseif (countL > countR)
    direction = 2;
    
%NB:Number of empty bin on the right greater than number of empty bin on the left, embed right   
elseif (countL < countR)
    direction = 3;
end

end
