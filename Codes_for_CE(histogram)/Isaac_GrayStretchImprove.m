function [beyond128orbelow127,shiftPixel,LminPixel,LmaxPixel,ROImaxPixel,ROIminPixel,GrayStretch] = GrayStretchImprove(gray,ROI,ratio)
%GrayStretchImprove Get the gray scale expansion map of the ROI area
%   Gray is a grayscale image, ROI is an ROI divided image, ratio is a ratio of less than 127 or greater than 128 pixels
ROIminPixel=255;ROImaxPixel=0;
LmaxPixel=255;LminPixel=0;
[m,n]=size(gray);
%Calculate the maximum and minimum pixels of the ROI area
for i=1:m
    for j=1:n
        if ROI(i,j)==0
            if gray(i,j)<ROIminPixel
                ROIminPixel=gray(i,j);
            end
            if gray(i,j)>ROImaxPixel
                ROImaxPixel=gray(i,j);
            end
        end
    end
end
%Calculate the total number of pixels between ROIminPixel and ROImaxPixel
sum=0;
for i=1:m
    for j=1:n
        if ROI(i,j)==0
            sum=sum+1;
        end
    end
end
%Calculate the total number of pixels between ROIminPixel and ROImaxPixel
sumBelow127=0;
for i=1:m
    for j=1:n
        if ROI(i,j)==0&&gray(i,j)<=127
            sumBelow127=sumBelow127+1;
        end
    end
end
% Calculate how many pixels are there between 128 and ROImaxPixel
sumBeyound128=0;
for i=1:m
    for j=1:n
        if ROI(i,j)==0&&gray(i,j)>=128
            sumBeyound128=sumBeyound128+1;
        end
    end
end
shift=gray;%If the ratio of pixels <127 or >128 exceeds ratio, then first translate the histogram
if (sumBelow127/sum)>ratio
    beyond128orbelow127=1;
    shiftPixel=255-ROImaxPixel;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && shift(i,j)>=128 
                shift(i,j)=shift(i,j)+shiftPixel;
            end
        end
    end
    LmaxPixel=128+shiftPixel-1;
    ROImaxPixel=127;
    GrayStretch=shift;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && GrayStretch(i,j)<=127
                tmp1=double(gray(i,j)-ROIminPixel);
                tmp2=double(ROImaxPixel-ROIminPixel);
                tmp3=double(LmaxPixel-LminPixel);
                GrayStretch(i,j)=round(tmp3*tmp1/tmp2+LminPixel);
            end
        end
    end
elseif (sumBeyound128/sum)>ratio
    beyond128orbelow127=2;
    shiftPixel=ROIminPixel;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && shift(i,j)<=127
                shift(i,j)=shift(i,j)-shiftPixel;
            end
        end
    end
    LminPixel=127-shiftPixel+1;
    ROIminPixel=128;
    GrayStretch=shift;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && GrayStretch(i,j)>=128
                tmp1=double(gray(i,j)-ROIminPixel);
                tmp2=double(ROImaxPixel-ROIminPixel);
                tmp3=double(LmaxPixel-LminPixel);
                GrayStretch(i,j)=round(tmp3*tmp1/tmp2+LminPixel);
            end
        end
    end
else
    beyond128orbelow127=3;
    shiftPixel=0;
    GrayStretch=shift;
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                tmp1=double(gray(i,j)-ROIminPixel);
                tmp2=double(ROImaxPixel-ROIminPixel);
                GrayStretch(i,j)=round(255.0*tmp1/tmp2);
            end
        end
    end
    return;
end
end

