data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.9)
[Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
[Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
%%
numtake=1;
numpertake=10;

for jj=1:10
    try
        for ii=1:9
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3,4],1,1,numtake);
        end
    catch ME
        disp(ME)
    end
    close all
end

%%
maxRepeat=20;
repeatid=1;
F=0;
while F<0.995 && repeatid<maxRepeat
    disp(['check readout No.' num2str(repeatid)])
    data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0)
    F=data_taking.public.xmon.tuneup.checkreadout('q1', 'q2');
    repeatid=repeatid+1;
end

numtake=1;
numpertake=5;

for jj=1:10
    try
        for ii=12:-1:4
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(1:ii),Phase,numpertake,[1,2,3],0,1,numtake);
        end
    catch ME
        disp(ME)
    end
    close all
end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
Phase=data_taking.ming.sampling.optClusterPhase(qubits,Phase);

%%
numtake=1;
numpertake=10;

for jj=1:10
    try
        for ii=1:9
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3,4],1,1,numtake);
        end
    catch ME
        disp(ME)
    end
    close all
end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,4)
for jj=1
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
end
%%
data_taking.public.xmon.tuneup.autoCalibration(qubits,0,0.5)
[Phase1,Phase2,Phase3,Phase4,Phase5,Phase6,Phase7,Phase8,Phase9,Phase10,Phase11,Phase12,Ptomo12,Ptomo23,Ptomo34,Ptomo45,Ptomo56,Ptomo67,Ptomo78,Ptomo89,Ptomo910,Ptomo1011,Ptomo1112,datafile]=data_taking.ming.sampling.indCZTomo_Q1_Q12_incircuit();
[Phase,Fcz,Fpp]=data_taking.ming.sampling.analyseCZTomo(datafile);
%%
numtake=1;
numpertake=10;

for jj=1:10
    try
        for ii=1:9
            data_taking.ming.sampling.clusterState_Q1_Q12_rGates_withCal(qubits(ii:12),Phase,numpertake,[1,2,3,4],1,1,numtake);
        end
    catch ME
        disp(ME)
    end
    close all
end