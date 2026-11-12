function re = PSNR(X,Y)
%PSNR 求两幅图像之间的PSNR
%   X表示原图，Y表示对比度增强后的
[m,n]=size(X);
sum=0;
for i=1:m
    for j=1:n
        sum=sum+double((X(i,j)-Y(i,j))^2);
    end
end
MSE=sum/(m*n);
re=10*log10(255^2/MSE);
end

