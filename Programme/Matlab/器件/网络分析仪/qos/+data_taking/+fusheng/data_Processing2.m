N=3;
coeff=load('E:\data\20180622_12bit\sampling\180707\toFidelityGHZ.mat');
coeffs=coeff.coeffs;

fileFolder=fullfile(['E:\data\20180622_12bit\sampling\usefuldata\N=',num2str(N)]);%�ļ�����plane
cd(fileFolder);
dirOutput=dir(fullfile(fileFolder,'*.mat'));%������ڲ�ͬ���͵��ļ����á�*����ȡ���У������ȡ�ض������ļ���'.'�����ļ����ͣ������á�.jpg��
fileNames={dirOutput.name}';

n=length(fileNames);
Pxx=[];
Pzz=[];
for i=1:n
    if i<11
        data=load(fileNames{i,1});
        Pzz=[Pzz;data.P];
    else
        data=load(fileNames{i,1});
        Pxx=[Pxx;data.P];
    end
end
h=figure();
subplot(1,2,1)
bar(1:2^N,mean(Pzz));
xlabel('state');
ylabel('P');
subplot(1,2,2)
bar(1:2^N,mean(Pxx));
xlabel('state');
ylabel('P');
saveas(h,['E:\data\20180622_12bit\sampling\usefuldata\nice\N=',num2str(N),'.fig']);
close(h);
save(['E:\data\20180622_12bit\sampling\usefuldata\nice\N=',num2str(N),'.mat']);
% saveas(h,['E:\data\20180622_12bit\sampling\usefuldata\nice\N=',num2str(N),'.fig']);

fdl=data_taking.fusheng.calGhzFidelity(mean(Pzz),mean(Pxx),N,coeffs);
disp(['fdl:',num2str(fdl),',totally 150000 shots'])
