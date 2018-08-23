function Phase=optClusterParams(measureQs,Phase,optqs)
% Phase=data_taking.ming.sampling.optClusterParams(qubits,Phase)

if nargin<3
    optqs=[];
end

QS = qes.qSettings.GetInstance();

qubits={'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
czQSets = {{'q1','q2'},...
    {'q3','q2'},...
    {'q3','q4'},...
    {'q5','q4'},...
    {'q5','q6'},...
    {'q7','q6'},...
    {'q7','q8'},...
    {'q9','q8'},...
    {'q9','q10'},...
    {'q11','q10'},...
    {'q11','q12'},...
    };

for ii=1:numel(czQSets)
    aczSettingsKey{ii}=[czQSets{ii}{1} '_' czQSets{ii}{2}];
    scz{ii} = QS.loadSSettings({'shared','g_cz',aczSettingsKey{ii}});
end


numRunsPerTake=4;
ms=[1 2];
% if isempty(optqs)
%     optqs=measureQs;
% end
numQs=numel(measureQs);
numoptQs=numel(optqs);

qdInd = nan(1,numQs);
for ii = 1:numQs
    qdInd_ = qes.util.find(measureQs{ii}, qubits);
    if isempty(qdInd_)
        error([dynamicPhaseQs{ii}.name ,' not one of the qubits.']);
    end
    qdInd(ii)=qdInd_;
end

idn=0;

    function fidelity=clusterfid(params)
        idn=idn+1;
        if idn==10
            data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
            idn=0;
        end
        Phase(qdInd)=params(1:numQs);
        setczamps(params(numQs+1:numQs*2-1));
        
        [Pxz,Pzx]=data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(measureQs,Phase,numRunsPerTake,ms,false,false,1);
        fidelity=data_taking.ming.sampling.calClusterFidelity(Pxz,Pzx,measureQs)
        fidelity=-fidelity;
    end

orgPhase=Phase(qdInd);

h = qes.ui.qosFigure(sprintf('ClusterParams Optimizer'),false);
axs(1) = subplot(4,6,1,'Parent',h);
for jj=2:numQs*2-1
    axs(jj) = subplot(4,6,jj);
end
axs(2*numQs) = subplot(4,6,[24]);
x0=[[orgPhase zeros(1,numQs-1)];diag([0.1*ones(1,numQs) 3e6*[ones(1,numoptQs) zeros(1,numQs-1-numoptQs)]])+[orgPhase zeros(1,numQs-1)]];

tolX = [0.005*ones(1,numQs) 10e3*ones(1,numQs-1)];
tolY = [0.001];

maxFEval = 600;

% maxRepeat=20;
% repeatid=1;
% F=0;
% while F<0.994 && repeatid<maxRepeat
%     disp(['check readout No.' num2str(repeatid)])
%     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%     F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
%     repeatid=repeatid+1;
% end

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@clusterfid, x0, tolX, tolY, maxFEval, axs);

Phase(qdInd)=optParams(1:numQs);
setczamps(optParams(numQs+1:numQs*2-1))

path=['E:\data\20180622_12bit\sampling\' datestr(now,'yymmdd') '\Tomo'];
if ~exist(path)
    mkdir(path)
end
datafile = [path,'\optClusterParams_',measureQs{1},'_',measureQs{end},'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
save(datafile,'Phase','x_trace','y_trace','optParams','orgPhase','measureQs','scz','czQSets','x0');
try
saveas(h,replace(datafile,'.mat','.fig'))
end



function setczamps(amps)
    if ~isempty(amps)
        for kk=1:numel(amps)
            QS.saveSSettings({'shared','g_cz',aczSettingsKey{kk},'amp'},scz{kk}.amp+amps(kk));
        end
    end
end

end