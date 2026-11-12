function [REE,RCE,RMBE,RSS]=ComprehensiveEvaluation(X,Y)
%ComprehensiveEvaluation 求增强后图像与原图像的REE,RCE,RMBE,RSS
%   X是原图 Y是增强对比后的图象
[m,n]=size(X);
X=double(X);
Y=double(Y);
EOriginal=entropy(X);
ENew=entropy(Y);
MOriginal=mean(mean(X));
MNew=mean(mean(Y));
StdOriginal=std2(X);
StdNew=std2(Y);
REE=(ENew-EOriginal)/16+0.5;
RCE=(StdNew-StdOriginal)/255+0.5;
RMBE=1-abs(MNew-MOriginal)/255;
sum=0;
for i=1:m
    for j=1:n
        sum=sum+(X(i,j)-Y(i,j))^2;
    end
end
RMSE=sqrt(sum/(m*n));
RSS=1-RMSE/255;
end

