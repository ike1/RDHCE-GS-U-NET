function [flag,f,hf] = findEmptyBinNROI(histo)
%FINDEMPTYBINNROI 寻找灰度图NROI区域中能够嵌入信息的bin
%   histo是NROI区域的灰度直方图
f=-1;hf=-1;NROImaxPixel=-1;
%寻找NROI区域的最大灰度值
for index=1:256
    if histo(1,index)~=0
        NROImaxPixel=index-1;
    end
end
if NROImaxPixel==255
    flag=0;
elseif NROImaxPixel~=-1&&NROImaxPixel<255
    flag=1;
    for index=1:256
        if histo(1,index)>=8&&histo(1,index)>hf
            f=index;
            hf=histo(1,index);
        end
    end
    f=f-1;
end
end

