function Phase=optClusterPhase(measureQs,Phase,optqs)
% Phase=data_taking.ming.sampling.optClusterPhase({'q1','q2'},[Phase31,Phase32,Phase33,Phase34,Phase35,Phase36,Phase37,Phase38,Phase39,Phase310,Phase311,Phase312])

if nargin<3
    optqs=[];
end

qubits={'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
numRunsPerTake=4;
ms=[1 2];
if isempty(optqs)
    optqs=measureQs;
end
numQs=numel(optqs);

qdInd = nan(1,numel(optqs));
for ii = 1:numel(optqs)
    qdInd_ = qes.util.find(optqs{ii}, qubits);
    if isempty(qdInd_)
        error([dynamicPhaseQs{ii}.name ,' not one of the qubits.']);
    end
    qdInd(ii)=qdInd_;
end

    function fidelity=clusterfid(params)
        Phase(qdInd)=params;
        [Pxz,Pzx]=data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(measureQs,Phase,numRunsPerTake,ms,false,false,1);
        fidelity=data_taking.ming.sampling.calClusterFidelity(Pxz,Pzx,measureQs)
%         for kk=1:numQs-1
%             measureQ={measureQs{[kk,kk+1]}};
%             [Pxz,Pzx]=data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(measureQ,Phase,numRunsPerTake,ms,false);
%             fidelity=fidelity*data_taking.ming.sampling.calClusterFidelity(Pxz,Pzx,measureQ);
%         end
        fidelity=-fidelity;
    end

orgPhase=Phase(qdInd);

h = qes.ui.qosFigure(sprintf('ClusterPhase Optimizer'),false);
axs(1) = subplot(4,4,1,'Parent',h);
for jj=2:numQs
    axs(jj) = subplot(4,4,jj);
end
axs(numQs+1) = subplot(4,4,[13,16]);
x0=[orgPhase;diag(0.1*ones(1,numQs))+orgPhase];

tolX = 0.005*ones(1,numQs);
tolY = [0.001];

maxFEval = 120;

maxRepeat=20;
repeatid=1;
F=0;
while F<0.995 && repeatid<maxRepeat
    disp(['check readout No.' num2str(repeatid)])
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
    repeatid=repeatid+1;
end

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@clusterfid, x0, tolX, tolY, maxFEval, axs);

Phase(qdInd)=optParams;

path=['E:\data\20180216_12bit\sampling\' datestr(now,'yymmdd') '\Tomo'];
if ~exist(path)
    mkdir(path)
end
datafile = [path,'\optPhase_',measureQs{1},'_',measureQs{end},'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
save(datafile,'Phase','x_trace','y_trace','optParams','orgPhase','measureQs');
try
saveas(h,replace(datafile,'.mat','.fig'))
end

end