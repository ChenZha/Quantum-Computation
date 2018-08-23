% path='D:\Data\20180216_12bit\sampling\180617\Tomo\50 cluster state tomo q10-q12';
path='D:\Data\20180216_12bit\sampling\180617\Tomo\cluster state tomo q5-q11';

files=dir(path);
ii=1;
F=[];
theta=[];
for jj=1:numel(files)
    if ~isempty(strfind(files(jj).name,'clusterStateTomo'))
        [F0]=data_taking.ming.sampling.clusterStateTomoFit([path '\' files(jj).name]);
        F(ii)=F0
%         theta(ii,:)=theta0;
        ii=ii+1;
    end
end

figure;plot(2:8,F([4,3,9 8 7 6 5]),'o')