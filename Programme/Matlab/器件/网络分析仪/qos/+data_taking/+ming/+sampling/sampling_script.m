% function sampling_script()
% data_taking.ming.sampling.sampling_script()

qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
%% single qubit correction
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,2,3000)

%% CZ correction

allQs = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
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
numCZs = struct(); numCZs.q1 = 1; numCZs.q2 = 1; numCZs.q3 = 1;
numCZs.q4 = 1; numCZs.q5 = 1; numCZs.q6 = 1; numCZs.q7 = 1;
numCZs.q8 = 1; numCZs.q9 = 1;numCZs.q10 = 1; numCZs.q11 = 1; numCZs.q12 = 1;

% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1,1000)

%%
% for jj=1
%     for ii = 1:11
%         try
%             czQSet = czQSets{ii};
%             data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%             data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
%         catch ME
%             disp(ME)
%         end
%     end
% end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,3)
for jj=1:1
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',false,'freqonly',true);
        catch ME
            disp(ME)
        end
    end
end
% for jj=1
%     for ii = 11:-1:1
%         try
%             czQSet = czQSets{ii};
%             sqc.util.setQSettings('r_avg',3000);
%             data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'freqonly',true);
%             
%         catch ME
%             disp(ME)
%         end
%     end
% end
%%
try
%     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    [Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
    [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
catch ME
    disp(ME)
end
%%
for jj=1
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            catch ME
            disp(ME)
        end
    end
end
%%
% for jj=1
%     for ii = 1:11
% %         try
%             czQSet = czQSets{ii};
% %             data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%             sqc.util.setQSettings('r_avg',3000);
% %             params=[0.5 0.05 -0.1 0.1; 0.8 0.06 -0.05 0.1; 0.95 0.04 0.1 0.05; 1.1 0.03 0.05 0.1; 1.3 0.06 -0.1 0.1];
% %             for kk=2
% %                 data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',params(kk,:));
% %             end
% 
%             data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
% %             data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
% %             sqc.util.setQSettings('r_avg',3000);
% %             data_taking.public.xmon.tuneup.simu_czPhaseTomo('controlQ',czQSet{1},'targetQ',czQSet{2});
% %             if ii<=3
% %                 data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
% %                 sqc.util.setQSettings('r_avg',5000);
% %                 data_taking.public.xmon.tuneup.simu_czDynamicPhase_parallel('controlQ',czQSet{1},'targetQ',czQSet{2},'dynamicPhaseQs',{czQSet{3:end}},...
% %                     'numCZs',numCZs.(czQSet{ii}),'PhaseTolerance',0.03,'numIter',9,...
% %                     'gui','true','save',true);
% %             end
% 
% %         catch ME
% %             disp(ME)
% %         end
%     end
% end

%%
%  sqc.util.setQSettings('r_avg',1000);
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
% for ii=3
%     q=qubits{ii};
% f01=sqc.util.getQSettings('f01',q);
% zp=sqc.util.f012zpa(q,4.4e9:5e6:4.75e9);
% data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:50e3],... % [20:200:2.8e4]
%         'gui',true,'save',true);
% end
% %%
% for ii=2
%     q=qubits{ii};
% f01=sqc.util.getQSettings('f01',q);
% zp=sqc.util.f012zpa(q,4.17e9:2e6:4.19e9);
% data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:50e3],... % [20:200:2.8e4]
%         'gui',true,'save',true);
% end
% %%
% for ii=4
%     q=qubits{ii};
% f01=sqc.util.getQSettings('f01',q);
% zp=sqc.util.f012zpa(q,4.35e9:3e6:4.5e9);
% data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:1000:50e3],... % [20:200:2.8e4]
%         'gui',true,'save',true);
% end
%%
try
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
    [Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
    [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
catch ME
    disp(ME)
end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
Phase=data_taking.ming.sampling.optClusterPhase({qubits{3:end}},Phase);
Phase=data_taking.ming.sampling.optClusterPhase(qubits,Phase,{'q1','q2','q3'});
%% 4-12 bit
% maxRepeat=20;
% repeatid=1;
% F=0;
% while F<0.995 && repeatid<maxRepeat
%     disp(['check readout No.' num2str(repeatid)])
%     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
%     F=data_taking.public.xmon.tuneup.checkreadout('q1', 'q2');
%     repeatid=repeatid+1;
% end

numtake=[];
numpertake=40;

% try
%     for ii=4:12
%         data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2],0,1,numtake);
%     end
% catch ME
%     disp(ME)
% end

try
    for ii=1:9
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3],0,1,numtake);
    end
catch ME
    disp(ME)
end

data_taking.ming.sampling.clusterFidelityAnalyse
%%
% Phase=data_taking.ming.sampling.optClusterPhase(qubits,Phase,{'q1','q2','q3'});
