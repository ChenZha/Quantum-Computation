function [ res ] = PostProcessP( P )
%��ʵ���õ�Pxx,Pzz������<0�ķֲ���Ϊ0�����Ա���fdl��ߣ�����>1��
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

