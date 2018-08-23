function [ res ] = PostProcessP( P )
%对实验测得的Pxx,Pzz处理，将<0的分布置为0。可以避免fdl虚高，甚至>1。
% P: Pzz or Pxx
res=P;
[i,j]=size(P);
for ii=1:i
    for jj=1:j
        if P(ii,jj)<0
            res(ii,jj)=0;
        end
    end
end

end

