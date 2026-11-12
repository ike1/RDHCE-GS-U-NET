function [dec] = Binary2Dec(binary)
%BINARY2DEC 将8位二进制转换成10进制数
sum=0;
for i=1:8
    sum=sum+str2double(binary(1,8-i+1))*(2^(i-1));
end
dec=sum;
end

