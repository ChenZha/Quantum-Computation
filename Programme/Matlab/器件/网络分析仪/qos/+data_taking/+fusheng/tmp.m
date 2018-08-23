
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.xmon.tuneup.*
import data_taking.public.jpa.*
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
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
%%
% x=-0.0384-1:0.2: -0.0384+1;
% fdl=zeros(length(x),5);
%
% for i=1:length(x)
%    [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(3,[x(i)],1,5,1);
%    fdl(i,:)=data_taking.fusheng.calGhzFidelity(Pzz,Pxx,3,coeffs);
%
% end
%
% fidelity=mean(fdl');
% figure()
% plot(x,fdl)
% Delta=max(fdl)-min(fdl);

%% single qubit correction

data_taking.public.xmon.tuneup.autoCalibration(qubits,0,4)
% data_taking.public.xmon.tuneup.autoCalibration({'q6','q7','q8'},1,4)
% phase_best=data_taking.fusheng.optGhzPhase(9,[0.2926   -1.2984   -0.2549    0.0554    0.3036])
clc
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
close all
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)
close all
%%
for ii=1:12
    try
        setQSettings('r_avg',1000);
        spectroscopy1_zpa_auto('qubit',qubits{ii},'biasAmp',-15e3:500:15e3,...
            'swpInitf01',[],'swpInitBias',[0],...
            'swpBandWdth',25e6,'swpBandStep',1e6,...
            'dataTyp','P','r_avg',700,'gui',true);
    end
end
%%
for ii=1:12
    try
        q=qubits{ii};
        f01=sqc.util.getQSettings('f01',q);
        %     zp=sqc.util.f012zpa(q,f01-700e6:10e6:f01e6);
        if mod(ii,2)
            zp=sqc.util.f012zpa(q,4.3e9:5e6:5.15e9);
        else
            zp=sqc.util.f012zpa(q,3.8e9:5e6:4.5e9);
        end
        % zp=0;
        setQSettings('r_avg',1000);
        T1_1('qubit',q,'biasAmp',zp,'biasDelay',0,'time',[100:2000:60e3],... % [20:200:2.8e4]
            'gui',true,'save',true,'fit',true);
    end
end
%%
for jj=1
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',1000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            %         data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-20:2:20],'gui',true,'save',true);
        end
    end
end
%%
for ii=[6 7 8 5 9 4 10 3 11 2 1]
    try
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
        czQSet = czQSets{ii};
        setQSettings('r_avg',2000);
        data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,...
            'paramsinput',[],'withaczLn',true,'withtailCZ',false,'innerdelay',80,'checkread',false,'isinitfirst',false);
    end
end
clc
%%
Fczall=[];
Fppall=[];
for ii=[6 7 8 5 9 4 10 3 11 2 1]
    try
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
        czQSet = czQSets{ii};
        setQSettings('r_avg',2500);
        innerdelayorg=[80 160 160 160 160 160];
        CZTomoData = Tomo_2QProcess_incircuit('qubit1',czQSet{1},'qubit2',czQSet{2},'innerdelay',innerdelayorg([1:(abs(ii-6)+1)]),...
            'process','CZ','notes','','gui',true,'save',true);
        
        [PhaseA,PhaseB,Fcz,Fpp] = toolbox.data_tool.fitting.fitCZQPhase(CZTomoData)
        Fczall(ii)=Fcz;
        Fppall(ii)=Fpp;
        
        aczSettingsKey = sprintf('%s_%s',czQSet{1},czQSet{2});
        QS = qes.qSettings.GetInstance();
        scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
        scz.dynamicPhases(1) = mod(scz.dynamicPhases(1) + PhaseA, 2*pi);
        scz.dynamicPhases(2) = mod(scz.dynamicPhases(2) + PhaseB, 2*pi);
        QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhases'},...
            scz.dynamicPhases);
    end
end
%%
% for Nqubit=[3 5 7 9 11]
%     try
%         data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
%         Phase=data_taking.fusheng.MeasureInitialPhase(Nqubit);
%         for ii=1
%             data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%             setQSettings('r_avg',2000);
%             Phase=data_taking.fusheng.optGhzPhase(Nqubit,Phase);
%             
%             [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(Nqubit,Phase,10,10,1,0);
%             fdl=data_taking.fusheng.calGhzFidelity(Pzz,Pxx,Nqubit);
%             
%             avg_fdl=mean(fdl)
%             std_fdl=std(fdl)
%         end
%     catch me
%         disp(me)
%     end
% end
%%
for Nqubit=[2 3 5 7 9 11]%
if Nqubit>2
    Phase=data_taking.fusheng.MeasureInitialPhase(Nqubit)
else
    Phase=[];
end
for ii=1
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    setQSettings('r_avg',2000);
    if Nqubit<=3
        Phase=[Phase,0,0];
    elseif Nqubit>=5
        Phase=[0,0,Phase,0,0];
    end
    Phase=data_taking.fusheng.optGhzPhase(Nqubit,Phase)
    
    [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(Nqubit,zeros(1,Nqubit),10,4,1,0);
%     [Pzz,Pxx]=data_taking.fusheng.GhzState_withCal(Nqubit,Phase,10,4,1,0);
    fdl=data_taking.fusheng.calGhzFidelity(Pzz,Pxx,Nqubit);
    
    avg_fdl=mean(fdl)
    std_fdl=std(fdl)
end
end
%%
% figure();
% subplot(2,1,1)
% bar(Pxx);
% subplot(2,1,2)
% bar(ProDisMeasXXX{1,8}{1,2});
