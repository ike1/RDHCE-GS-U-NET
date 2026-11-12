function [NROIPreprocess,NROIminPixel] = Isaac_NROIPreprocessing(src,ROI)
%NROIPREPROCESSING ????NROI??????
%   src????????ROI?ROI?????

%Finding the histogram of NROI
xx=Isaac_Histogram(src,ROI,2);

%My variables
xl=-1; %For finding the peak
count=0; %For checking the number of empty bins before NROIMin
xp=999999; %NROI Pl
min_position=-1; %NROI Pl position

[m,n]=size(src);
NROIminPixel=255;
NROIPreprocess=src;
for i=1:m
    for j=1:n
        if ROI(i,j)~=0
            if NROIPreprocess(i,j)<NROIminPixel
                %count=count+1;
                NROIminPixel=NROIPreprocess(i,j);
            end
        end
    end
end

%% Mine - Checking if the NROImin uses the histogram format

for i=1:m
    for j=1:n
        if ROI(i,j)~=0
            if NROIPreprocess(i,j)>xl
                %count=count+1;
                pp=NROIPreprocess(i,j);
            end
        end
    end
end

%% Checking for my Min
for index=1:256    
    count=count+1;
    if index>=1&&index<=256&&xx(1,index)>0
        count=count+1;
        xp=xx(1,index);
        break;
    end
end


%%
for i=1:m
    for j=1:n
        if ROI(i,j)~=0
            NROIPreprocess(i,j)=NROIPreprocess(i,j)-NROIminPixel;
        end
    end
end

folder='D:\Codes\Isaac';
imwrite(NROIPreprocess,fullfile(folder,'P_687_BR_.png'));

end

