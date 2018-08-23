% plot sequence
load('E:\data\20180216_12bit\sampling\180526\cluster\q12-q1 No2\_AllinOne\clusterState_q2_q12_L1_180526T165717.mat')
% load('E:\data\20180216_12bit\sampling\180614\cluster\clusterState_q2_q12_L2_180614T162723.mat')
units=44000;
for ii=1:11
    temp=sequenceSamples(((ii-1)*3+1):ii*3-1,:);
    temp(find(abs(temp)<50))=NaN;
    sequenceSamples(((ii-1)*3+1):ii*3-1,:)=temp;
%     temp=sequenceSamples(((ii-1)*3+3),:);
%     temp([1:45 289:340]*2)=NaN;
%     sequenceSamples(((ii-1)*3+3),:)=temp;
    sequenceSamples(((ii-1)*3+1):ii*3,:)=sequenceSamples(((ii-1)*3+1):ii*3,:)+units*(ii-1);
end
figure;plot((1:numel(sequenceSamples(1,:)))/2,sequenceSamples(3:3:33,:)');hold on;
plot((1:numel(sequenceSamples(1,:)))/2,sequenceSamples(1:3:33,:)');
plot((1:numel(sequenceSamples(1,:)))/2,sequenceSamples(2:3:33,:)');
set(gcf,'OuterPosition',[627 66 576 992])
box on
axis tight
set(gca,'XLim',[0,330])
set(gca,'YDir','normal')
set(gca,'YTick',+units*(0:10))
set(gca,'YTicklabel',{'q11','q10','q9','q8','q7','q6','q5','q4','q3','q2','q1'})
set(gca,'FontSize',14)
xlabel('Time (ns)')
