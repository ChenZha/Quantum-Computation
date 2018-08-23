import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.xmon.tuneup.*
import data_taking.public.jpa.*
czQSets = {{'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'},...
    {'q3','q2','q1','q4','q5','q6','q7','q8','q9','q10','q11','q12'},...
    {'q3','q4','q1','q2','q5','q6','q7','q8','q9','q10','q11','q12'},...
    {'q5','q4','q1','q2','q3','q6','q7','q8','q9','q10','q11','q12'},...
    {'q5','q6','q1','q2','q3','q4','q7','q8','q9','q10','q11','q12'},...
    {'q7','q6','q1','q2','q3','q4','q5','q8','q9','q10','q11','q12'},...
    {'q7','q8','q1','q2','q3','q4','q5','q6','q9','q10','q11','q12'},...
    {'q9','q8','q1','q2','q3','q4','q5','q6','q7','q10','q11','q12'},...
    {'q9','q10','q1','q2','q3','q4','q5','q6','q7','q8','q11','q12'},...
    {'q11','q10','q1','q2','q3','q4','q5','q6','q7','q8','q9','q12'},...
    {'q11','q12','q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'},...
    };
%%
tuneup.autoCalibration(qubits,0,4)
%%
% setQSettings('r_avg',3000);
% % tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
% %%
% setQSettings('r_avg',3000);
% % tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)
close all
% data_taking.ming.sampling.plusplus_Q1_Q12_rGates_withCal(qubits,40)
%%
% F=NaN(12,12);
% theta1=F;
% theta2=F;
% for ii=1:12
%     for jj=1:12
%         if ii~=jj
%             qc=qubits{ii};
%             qt=qubits{jj};
%             [F(ii,jj),theta]=data_taking.public.xmon.tuneup.checkreadout(qc,qt);
% %             F(jj,ii)=F(ii,jj);
%             theta1(ii,jj)=theta(1);
%             theta2(ii,jj)=theta(2);
%         end
%     end
% end
% hf=figure;imagesc(1:12,1:12,F)
% xlabel('qubit index')
% ylabel('qubit index')
% title('Two qubit |++> Fidelity')
% saveas(hf,['E:\data\20180216_12bit\12bit++Fidelity_' datestr(now,'yymmddhhMMss') '.fig'])
%%
% for ii=[6 7 12]
%     
% setQSettings('r_avg',700);
% spectroscopy1_zpa_auto('qubit',qubits{ii},'biasAmp',-10e3:500:10e3,...
%     'swpInitf01',[],'swpInitBias',[0],...
%     'swpBandWdth',25e6,'swpBandStep',1e6,...
%     'dataTyp','P','r_avg',700,'gui',true);
% end
%%
for jj=1:3
    for ii = 1:11
        czQSet = czQSets{ii};
        sqc.util.setQSettings('r_avg',1000);
        data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
        %         data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-20:2:20],'gui',true,'save',true);
    end
end
%%
for jj=1:2
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
        catch ME
            disp(ME)
        end
    end
try
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
    [Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
    [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
catch ME
    disp(ME)
end

numtake=[];
numpertake=40;
try
    for ii=1:11
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2],0,1,numtake);
    end
catch ME
    disp(ME)
end

try
    for ii=12:-1:2
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2],0,1,numtake);
    end
catch ME
    disp(ME)
end
end
