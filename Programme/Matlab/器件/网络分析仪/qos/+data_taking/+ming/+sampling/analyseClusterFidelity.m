function [fidelity,err]=analyseClusterFidelity(path,N)
if nargin<1
    path='E:\data\20180622_12bit\sampling\180809\cluster\12-1 after opt';
end
if nargin<2
    N=2500*100;
end
files=dir([path '\*.mat']);
for ii=1:numel(files)
    if strfind(files(ii).name,'Overall')
        delete([path,'\',files(ii).name]);
    end
end

data_taking.ming.sampling.orgClusterData(path)

% bitnum=4:12;
bitnum=2:12;
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
numQ=numel(qubits);



files=dir([path '\*.mat']);
% fidelity=nan(numel(bitnum),numQ);

for ii=1:numel(bitnum)
%     for kk=1:numQ-bitnum(ii)+1
        for mm=1:numel(files)
            if ~isempty(strfind(files(mm).name,'Overall')) && ~isempty(strfind(files(mm).name,['_' num2str(bitnum(ii)) 'bit']))% && ~isempty(strfind(files(mm).name,['_' qubits{kk} '_'])) && ~isempty(strfind(files(mm).name,['_' qubits{kk+bitnum(ii)-1} '_'])) 
                data= load([path '\' files(mm).name]);   
                if ~isempty(data.Pxzz)
                    [fidelity(ii),fidelity2(ii),err(ii)]=data_taking.ming.sampling.calClusterFidelity2(data.Pxz,data.Pzx,data.Pxzz,data.measureQs,N);
                else
                    [fidelity(ii),err(ii)]=data_taking.ming.sampling.calClusterFidelity(data.Pxz,data.Pzx,data.measureQs,N);
                end
            end
        end
%     end
end

save([path '\analysedDataResult.mat'],'fidelity','err','bitnum','qubits','files','N')

% fidelitynonan=fidelity(~isnan(fidelity));
% qns=find(sum(~isnan(fidelity),2)==1)+1;
% h=figure;plot(qns(end:-1:1),fidelitynonan,'*r')

% errorbar(bitnum,fidelity,err,'*r');
% if ~isempty(data.Pxzz)
% hold on;errorbar(bitnum,fidelity2,err,'ob');legend('3 components','2 components','location','best')
% end

hf=toolbox.data_tool.barcolormap(bitnum,fidelity,err);
xlabel('Linear Cluster State qubit number')
ylabel('Fidelity')
saveas(hf,[path '\ClusterFidelitywithQubitnumber.fig' ])

% figure;plot(fidelity','-o')
% legend({'2bit','3bit','4bit','5bit','6bit','7bit','8bit','9bit','10bit','11bit','12bit'},'location','best')
% xlabel('cluster bit number')
% ylabel('fidelity')

end