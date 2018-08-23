function [ fdl ] = calGhzFidelity( Pzz,Pxx ,N,coeffs)
%CALGHZFIDELITY �˴���ʾ�йش˺�����ժҪ
%   N: GHZ state qubit number:n=[2,3,5,7,9,11,12]


load('E:\data\20180622_12bit\sampling\180707\toFidelityGHZ.mat')
[i,~]=size(Pzz);
fdl=zeros(1,i);
for i=1:i
    fdl(i)=Pzz(i,:)*coeffs{1,N-1}{1,2}'+Pxx(i,:)*coeffs{1,N-1}{1,3}'-1;
end

end

