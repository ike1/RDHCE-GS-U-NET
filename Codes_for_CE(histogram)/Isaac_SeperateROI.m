function [ROIArea] = Isaac_SeperateROI(gray,threshold)
    % Function to separate the region of interest (ROI) in a grayscale image.
    % Inputs:
    %   gray: 2D matrix representing the grayscale image.
    %   threshold: Intensity threshold to separate the ROI.
    % Outputs:
    %   ROIArea: A binary image where the ROI is highlighted.
    % Initialize the ROIEdge as a copy of the grayscale image
 ROIEdge=gray;
[m,n]=size(gray);
for i=1:m
    for j=1:n
        if gray(i,j)>=threshold
            ROIEdge(i,j)=0;
        else
            ROIEdge(i,j)=255;
        end
    end
end
ROIArea=ROIEdge;
record=zeros(m,2);
for i=1:m
    for j=1:n
        if ROIArea(i,j)==0
            record(i,1)=j;
        end
    end
end
for i=1:m
    for j=1:n
        if ROIArea(i,n-j+1)==0
            record(i,2)=n-j+1;
        end
    end
end
for i=1:m
    for j=1:n
        if j>=record(i,2)&&j<=record(i,1)
            ROIArea(i,j)=0;
        end
    end
end
end


