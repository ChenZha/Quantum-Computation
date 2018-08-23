function analyseMultiClusterData(path)
if nargin<1
    path='D:\Data\20180216_12bit\sampling\180526\cluster\q12-q1 No2';
end
N=2500*10;
bitnum=12;

data_taking.ming.sampling.orgMultiClusterData(path)

mkdir([path '\_AllinOne'])

folders=dir(path);
totalfid=[];
totalerr=[];
for ii=3:numel(folders)
    if folders(ii).isdir && ~ismember('_',folders(ii).name)
    [fidelity,err]=data_taking.ming.sampling.analyseClusterFidelity([path,'\',folders(ii).name],N);
    totalfid=[totalfid;fidelity];
    totalerr=[totalerr;err];
    
    
        dfiles=dir([path,'\',folders(ii).name]);
        for jj=3:numel(dfiles)
            copyfile([dfiles(jj).folder '\' dfiles(jj).name],[path '\_AllinOne\' dfiles(jj).name]);
        end
    end
end

save([path '\AllinoneDataanalyse.mat' ],'totalfid','totalerr','N','bitnum')

h1=figure;
hold on;
for ii=1:size(totalfid,1)
    errorbar(bitnum-numel(err)+1:bitnum,totalfid(ii,:),totalerr(ii,:))
end
title('10 Individutal Measurements')
xlabel('Cluster State Qubit Number');ylabel('Average Fidelity Lower Limit');
box on;
saveas(h1,[path '\10 Individutal Measurements.fig' ])

h2=figure;errorbar(bitnum-numel(err)+1:bitnum,mean(totalfid,1),2*std(totalfid,1),'or');xlabel('Cluster State Qubit Number');ylabel('Average Fidelity Lower Limit');title('10 Measurements Statistics')
box on;
saveas(h2,[path '\10 Measurements Statistics.fig' ])

[fidelity,err]=data_taking.ming.sampling.analyseClusterFidelity([path,'\_AllinOne'],N*size(totalfid,1));
title('AllinOne data')
saveas(gcf,[path '\AllinOne data.fig' ])
end