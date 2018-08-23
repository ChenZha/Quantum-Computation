data_taking.public.xmon.tuneup.autoCalibration(qubits,0,3)
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)

% for ii = 1:11
%     try
%         czQSet = czQSets{ii};
%         sqc.util.setQSettings('r_avg',1000);
%         data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-10:1:10],'gui',true,'save',true);
%     catch ME
%         disp(ME)
%     end
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
numtake=[];
numpertake=40;
try
    for ii=1:9
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3],0,1,numtake);
    end
catch ME
    disp(ME)
end  
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.9)
for jj=1:4
    for ii = 1:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',2500);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
        catch ME
            disp(ME)
        end
    end
end
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
numtake=[];
numpertake=40;
try
    for ii=1:9
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3],0,1,numtake);
    end
catch ME
    disp(ME)
end  
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
Phase=data_taking.ming.sampling.optClusterPhase({qubits{3:end}},Phase);
Phase=data_taking.ming.sampling.optClusterPhase(qubits,Phase,{'q1','q2','q3'});
  %% 
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
numtake=[];
numpertake=40;
try
    for ii=1:9
        data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3],0,1,numtake);
    end
catch ME
    disp(ME)
end  
% %% Check TOMO between 2 optimize
% for jj=1:2
%     for ii = 1:11
%         try
%             data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.9)
%             czQSet = czQSets{ii};
%             sqc.util.setQSettings('r_avg',2500);
%             data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
%             data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
%         catch ME
%             disp(ME)
%         end
%     end
%     try
%         data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
%         [Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
%         [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
%     catch ME
%         disp(ME)
%     end
% end
%   %% 
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
% numtake=[];
% numpertake=40;
% try
%     for ii=1:9
%         data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3],0,1,numtake);
%     end
% catch ME
%     disp(ME)
% end  

