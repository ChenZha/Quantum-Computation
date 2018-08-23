function Phase_best=optGhzPhase(N,Phase)

% Phase=data_taking.ming.sampling.optClusterPhase({'q1','q2'},[Phase31,Phase32,Phase33,Phase34,Phase35,Phase36,Phase37,Phase38,Phase39,Phase310,Phase311,Phase312])
coeff=load('E:\data\20180622_12bit\sampling\180707\toFidelityGHZ.mat');
coeffs=coeff.coeffs;
qubits={'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};

numQs=N;

% qdInd = nan(1,numel(optqs));
% for ii = 1:numel(optqs)
%     qdInd_ = qes.util.find(optqs{ii}, qubits);
%     if isempty(qdInd_)
%         error([dynamicPhaseQs{ii}.name ,' not one of the qubits.']);
%     end
%     qdInd(ii)=qdInd_;
% end

    function fidelity=Ghzfdl(params)
        [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(numQs,params,1,4);
        fdl=data_taking.fusheng.calGhzFidelity(Pzz,Pxx,numQs,coeffs);
        fidelity=mean(fdl);
        Delta=max(fdl)-min(fdl);
        id=1;
%         while fidelity>1 || Delta>0.15
%             if id<10
%                 [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(numQs,params,1,4);
%                 fdl=data_taking.fusheng.calGhzFidelity(Pzz,Pxx,numQs,coeffs);
%                 fidelity=mean(fdl);
%                 Delta=max(fdl)-min(fdl);             
%                 id=id+1;
%             else
%                 error('std(fidelity) is too high! please check readout!!! ')
%             end
%         end
        disp(['repeat ',num2str(id),' times,get credible fidelity:',num2str(fidelity)])
        fidelity=-fidelity;
    end

% orgPhase=Phase(qdInd);
orgPhase=Phase;
h = qes.ui.qosFigure(sprintf('GhzPhase Optimizer| %d-qubit',N),false);
axs(1) = subplot(4,4,1,'Parent',h);
for jj=2:length(Phase)
    axs(jj) = subplot(4,4,jj);
end

axs(length(Phase)+1) = subplot(4,4,[13,16]);
% x0=[orgPhase;diag(0.1*ones(1,numQs))+orgPhase];
x0=[orgPhase;diag(0.6*ones(1,length(Phase)))+orgPhase];

% tolX = 0.005*ones(1,numQs);
tolX = 0.017*ones(1,numel(Phase));

tolY = [0.001];

maxFEval = max(50,(N)*25);

% maxRepeat=10;
% repeatid=1;
% F=0;
% while F<0.99 && repeatid<maxRepeat
%     disp(['check readout No.' num2str(repeatid)])
%     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%     F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
%     repeatid=repeatid+1;
% end

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@Ghzfdl, x0, tolX, tolY, maxFEval, axs);

Phase_best=optParams;

path=['E:\data\20180622_12bit\sampling\' datestr(now,'yymmdd') '\Tomo'];
if ~exist(path)
    mkdir(path)
end
datafile = [path,'\optGhzPhase_','N=',num2str(N),'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
save(datafile,'Phase_best','x_trace','y_trace','N');
try
saveas(h,replace(datafile,'.mat','.fig'))
end
datestr(now, 'yyyymmddHHMMSS')

if N==2
    qc='q7';
    qt='q6';
    mQi=[6 7];
elseif N==3
    qc='q7';
    qt='q8';
    mQi=6:8;
elseif N==5
    qc='q5';
    qt='q6';
    mQi=5:9;
    qc2='q9';
    qt2='q8';
elseif N==7
    qc='q5';
    qt='q4';
    mQi=4:10;
    qc2='q9';
    qt2='q10';
elseif N==9
    qc='q3';
    qt='q4';
    mQi=3:11;
    qc2='q11';
    qt2='q10';
elseif N==11
    qc='q3';
    qt='q2';
    mQi=2:12;
    qc2='q11';
    qt2='q12';
elseif N==12
    qc='q1';
    qt='q2';
    mQi=1:12;
end

aczSettingsKey = sprintf('%s_%s',qc,qt);
QS = qes.qSettings.GetInstance();
scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
if N>=5 && N<=11
    aczSettingsKey2 = sprintf('%s_%s',qc2,qt2);
    scz2 = QS.loadSSettings({'shared','g_cz',aczSettingsKey2});
end

if N>=5 && N<=11
    for ii = 1:numel(mQi)-2
        qdInd_ = qes.util.find(qubits{mQi(ii)}, scz.qubits);
        if isempty(qdInd_)
            error([' not one of the qubits.']);
        end
        scz.dynamicPhases(qdInd_) = mod(scz.dynamicPhases(qdInd_) + Phase_best(ii), 2*pi);
    end
    QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhases'},...
    scz.dynamicPhases);
    for ii = (numel(mQi)-1):numel(mQi)
        qdInd_ = qes.util.find(qubits{mQi(ii)}, scz2.qubits);
        if isempty(qdInd_)
            error([' not one of the qubits.']);
        end
        scz2.dynamicPhases(qdInd_) = mod(scz2.dynamicPhases(qdInd_) + Phase_best(ii), 2*pi);
    end
    QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhases'},...
    scz.dynamicPhases);
else
    for ii = 1:numel(mQi)
        qdInd_ = qes.util.find(qubits{mQi(ii)}, scz.qubits);
        if isempty(qdInd_)
            error([' not one of the qubits.']);
        end
        scz.dynamicPhases(qdInd_) = mod(scz.dynamicPhases(qdInd_) + Phase_best(ii), 2*pi);
    end
    QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhases'},...
    scz.dynamicPhases);
end

        
end