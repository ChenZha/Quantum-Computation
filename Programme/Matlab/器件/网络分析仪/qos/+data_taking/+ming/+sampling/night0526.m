for ii=[2 4]
    q=qubits{ii};
f01=sqc.util.getQSettings('f01',q);
zp=sqc.util.f012zpa(q,f01-60e6:2e6:f01+60e6);
% zp=-1000:100:1000;
sqc.util.setQSettings('r_avg',1000);
data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:2000:40e3],... % [20:200:2.8e4]
        'gui',true,'save',true);

end
for ii=3
    q=qubits{ii};
f01=sqc.util.getQSettings('f01',q);
zp=sqc.util.f012zpa(q,4.55e9:5e6:4.95e9);
% zp=-1000:100:1000;
sqc.util.setQSettings('r_avg',1000);
data_taking.public.xmon.T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:2000:40e3],... % [20:200:2.8e4]
        'gui',true,'save',true);

end
%%
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
%%
% data_taking.public.xmon.tuneup.autoCalibration(qubits,0,1)
% data_taking.public.xmon.tuneup.autoCalibration(qubits,1,4)
for jj=1:2
    for ii = [1 2]
%         try
            czQSet = czQSets{ii};
            sqc.util.setQSettings('r_avg',3000);
            data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
            data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true);
%         catch ME
%             disp(ME)
%         end
    end
end
%%
for ii = 2
    %         try
    czQSet = czQSets{ii};
    sqc.util.setQSettings('r_avg',1000);
%     data_taking.public.xmon.tuneup.simu_czAmplitude_incircuit('controlQ',czQSet{1},'targetQ',czQSet{2},'largeRange',false,'repeatIfOutOfBoundButClose',true,'gui',true);
    data_taking.public.xmon.tuneup.scanCZparams2('controlQ',czQSet{1},'targetQ',czQSet{2},'czln',[-15:2:15],'gui',true,'save',true);
    %         catch ME
    %             disp(ME)
    %         end
end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
[Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
[Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
%%
numtake=[];
numpertake=40;

for jj=1:10
    try
        for ii=1:9
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2],1,1,numtake);
        end
    catch ME
        disp(ME)
    end
    close all
end