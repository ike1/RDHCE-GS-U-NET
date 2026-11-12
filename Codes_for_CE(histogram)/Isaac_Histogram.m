function [grayHisto] = Isaac_Histogram(gray,ROI,flag)
%HISTOGRAM 获得图像ROI或NROI区域的灰度直方图
%   src为灰度图像,ROI为划分ROI的图像
%   flag为1代表取ROI区域的灰度直方图，flag为2代表取NROI区域的灰度直方图
grayHisto=zeros(1,256);
[m,n]=size(gray);
if flag==1
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                for index=1:256
                    if gray(i,j)==index-1
                        grayHisto(1,index)=grayHisto(1,index)+1;
                    end
                end
            end
        end
    end
elseif flag==2
    for i=1:m
        for j=1:n
            if ROI(i,j)~=0
                for index=1:256
                    if gray(i,j)==index-1
                        grayHisto(1,index)=grayHisto(1,index)+1;
                    end
                end
            end
        end
    end
end
end

