function [stretchRecover] = GrayStretchRecoverImprove(src,ROI,ROIminPixel,ROImaxPixel,LminPixel,LmaxPixel,beyond128orbelow127,shiftPixel)
%GRAYSTRETCHRECOVERIMPROVE 此处显示有关此函数的摘要
%   src是输入图像，ROI是ROI区域划分图像，ROIminPixel是ROI区域的最小灰度值，ROImaxPixel是ROI区域的最大灰度值,LminPixel是拓展到的最小灰度值，LmaxPixel是拓展到的最大灰度值
stretchRecover=src;
[m,n]=size(stretchRecover);
if beyond128orbelow127==1
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && stretchRecover(i,j)<=LmaxPixel
                tmp1=double(ROImaxPixel-ROIminPixel);
                tmp2=double(stretchRecover(i,j)-LminPixel);
                tmp3=double(LmaxPixel-LminPixel);
                stretchRecover(i,j)=round(tmp1*tmp2/tmp3+ROIminPixel);
            end
        end
    end
    for i=1:m
        for j=1:n
            if ROI(i,j)==0&&stretchRecover(i,j)>=128
                stretchRecover(i,j)=stretchRecover(i,j)-shiftPixel;
            end
        end
    end
elseif beyond128orbelow127==2
    for i=1:m
        for j=1:n
            if ROI(i,j)==0 && stretchRecover(i,j)>=LminPixel
                tmp1=double(ROImaxPixel-ROIminPixel);
                tmp2=double(stretchRecover(i,j)-LminPixel);
                tmp3=double(LmaxPixel-LminPixel);
                stretchRecover(i,j)=round(tmp1*tmp2/tmp3+ROIminPixel);
            end
        end
    end
    for i=1:m
        for j=1:n
            if ROI(i,j)==0&&stretchRecover(i,j)<=127
                stretchRecover(i,j)=stretchRecover(i,j)+shiftPixel;
            end
        end
    end
elseif beyond128orbelow127==3
    for i=1:m
        for j=1:n
            if ROI(i,j)==0
                tmp1=double(ROImaxPixel-ROIminPixel);
                tmp2=double(stretchRecover(i,j)-0);
                stretchRecover(i,j)=round(tmp1*tmp2/255.0+ROIminPixel);
            end
        end
    end
end
end

