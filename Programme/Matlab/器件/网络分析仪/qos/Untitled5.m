%% two qubit gate benchmarking
sqc.util.setQSettings('r_avg',1000);
numGates = [1];
[Pref,Pi] = data_taking.public.xmon.randBenchMarking('qubit1','q1','qubit2','q2',...
       'process','Cluster','numGates',numGates,'numReps',40,...
       'gui',true,'save',true);
% [fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, mean(Pref,1), mean(Pgate, 1),2, 'CZ');