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
%     for ii=1:12
%     q=qubits{ii};
%     f01=sqc.util.getQSettings('f01',q);
% % f01=4.28e9;
%     zp=sqc.util.f012zpa(q,f01-40e6:0.2e6:f01+40e6);
%     setQSettings('r_avg',3000);
%     T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[30e3],... % [20:200:2.8e4]
%         'gui',true,'save',true,'fit',true);
% end
%%
try
     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,4)
    %     data_taking.ming.sampling.plusplus_Q2_Q12_rGates_withCal(qubits,10)
catch
    data_taking.public.xmon.tuneup.autoCalibration(qubits,1,2)
end
%%
% setQSettings('r_avg',3000);
% % tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
% %%
% setQSettings('r_avg',3000);
% % tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)
% %%
% data_taking.ming.updateQparams
% close all
% clc
%%
% for jj=1
%     data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)
    for ii=2
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',1000);
            if ii==1
                data_taking.public.xmon.tuneup.scanCZdetune('controlQ',czQSet{1},'targetQ',czQSet{2},'czdetune',[-100e6:10e6:200e6],'gui',true,'save',true);
%             elseif ii==8 
%                 data_taking.public.xmon.tuneup.scanCZdetune('controlQ',czQSet{1},'targetQ',czQSet{2},'czdetune',[-50e6:10e6:50e6],'gui',true,'save',true);
            else
                data_taking.public.xmon.tuneup.scanCZdetune('controlQ',czQSet{1},'targetQ',czQSet{2},'czdetune',[-200e6:10e6:200e6],'gui',true,'save',true);
            end
        catch me
            disp(me)
        end
    end
% end
%%
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,2)
%%
%  for jj=1:2
%      for ii = 1:11
% %          data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)
%          
%          try
%              czQSet = czQSets{ii};
%              sqc.util.setQSettings('r_avg',2000);
%              data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
%          end
%      end
%  end
%%
for jj=1
    for ii = 9:11
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',2000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
        end
    end
end
close all
%%
    try
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
        [Phase1,~,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
        [Phase0,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo_Q1_Q12(datafile);
    catch ME
        disp(ME)
    end
    %%
 for jj=1:2
     for ii = 1:11
%          data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)
         
         try
             czQSet = czQSets{ii};
             sqc.util.setQSettings('r_avg',2000);
             data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
         end
     end
 end
 %%
    try
        data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
        [Phase1,~,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
        [Phase0,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo_Q1_Q12(datafile);
    catch ME
        disp(ME)
    end
    %%
    Phase=Phase0;
%     try
%         Phase=data_taking.ming.sampling.optClusterParams(qubits,Phase0,'q1');
%     end
    
    for jj=1:10
        numtake=1;
        numpertake=10;
        try
            for ii=1:11
                data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2],1,1,numtake);
            end
        catch ME
            disp(ME)
        end
    end
    
    try
        for ii=12:-1:2
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2],1,1,numtake);
        end
    catch ME
        disp(ME)
    end

    %%
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
    
    try
        Phase=data_taking.ming.sampling.optClusterParams(qubits,Phase0,'');
    end
    
        for jj=1:10
        numtake=1;
        numpertake=10;
        try
            for ii=1:11
                data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2],1,1,numtake);
            end
        catch ME
            disp(ME)
        end
    end
    
    try
        for ii=12:-1:2
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2],1,1,numtake);
        end
    catch ME
        disp(ME)
    end
    
% %%
% for ii=10:-1:4
%     data_taking.ming.sampling.clusterStateTomo_Q1_Q12_rGates_withCal(qubits(ii:11),Phase,1);
% end
% %%
% for jj=1:50
%     for ii=9
%         data_taking.ming.sampling.clusterStateTomo_Q2_Q12_rGates_withCal(qubits(ii:11),Phase,1);
%     end
% end
% %%
% for jj=1:50
%     for ii=10
%         data_taking.ming.sampling.clusterStateTomo_Q2_Q12_rGates_withCal(qubits(ii:11),Phase,1);
%     end
% end