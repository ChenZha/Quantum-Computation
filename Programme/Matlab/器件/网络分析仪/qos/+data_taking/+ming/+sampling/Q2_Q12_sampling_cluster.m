import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.xmon.tuneup.*
import data_taking.public.jpa.*
czQSets = {{'q3','q2'},...
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
qubits = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};

%%

% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
% for ii=10
%     q=qubits{ii};
% f01=sqc.util.getQSettings('f01',q);
% zp=sqc.util.f012zpa(q,f01-30e6:2e6:f01+30e6);
% % zp=0;
% setQSettings('r_avg',1000);
% T1_1('qubit',q,'biasAmp',zp,'biasDelay',0,'time',[100:1000:38e3],... % [20:200:2.8e4]
%         'gui',true,'save',true,'fit',true);
% end
%%
try
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,4)
%     data_taking.ming.sampling.plusplus_Q2_Q12_rGates_withCal(qubits,10)
catch
    data_taking.public.xmon.tuneup.autoCalibration(qubits,1,2)
end
close all
%%
for jj=1
    for ii = 1%[10     2     3     9     8     4     7     6     5     1]
        try
        czQSet = czQSets{ii};
        sqc.util.setQSettings('r_avg',2000);
        data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
        %         data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-20:2:20],'gui',true,'save',true);
        end
    end
end
%%
for ii=1%[10     2     3     9     8     4     7     6     5     1]
    czQSet = czQSets{ii};
    sqc.util.setQSettings('r_avg',1000);
    data_taking.public.xmon.tuneup.scanCZdetune('controlQ',czQSet{1},'targetQ',czQSet{2},'czdetune',[-100e6:10e6:100e6],'gui',true,'save',true);
end
%%
for jj=1
    for ii = 1%[10     2     3     9     8     4     7     6     5     1]
        try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
        catch ME
            disp(ME)
        end
    end
%%
try
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
    [~,~,datafile]=data_taking.ming.sampling.indCZTomo_Q2_Q12_incircuit();
    [Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo_Q2_Q12(datafile);
catch ME
    disp(ME)
end

for jj=1:10
numtake=1;
numpertake=10;
try
    for ii=1:10
        data_taking.ming.sampling.clusterState_Q2_Q12_rGates_withCal(qubits(ii:11),Phase,numpertake,[1,2,4],1,1,numtake);
    end
catch ME
    disp(ME)
end
end

try
    for ii=11:-1:2
        data_taking.ming.sampling.clusterState_Q2_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2],1,1,numtake);
    end
catch ME
    disp(ME)
end
end