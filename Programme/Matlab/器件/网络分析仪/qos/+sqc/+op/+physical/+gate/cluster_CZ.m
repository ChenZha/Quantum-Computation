function proc=cluster_CZ(qc,qt)

import sqc.op.physical.*
    
% Get simutanous cz qubits sets
% qubits = sqc.util.loadQubits();
qubits = sqc.util.getQSettings('allQubits','shared');
qRegs = sqc.qobj.qRegisters.GetInstance();
for ii=1:numel(qubits)
    qubits{ii}=qRegs.get(qubits{ii});
end

simuCZset=sqc.util.getQSettings('g_cz.simuCZ','shared');

precq={};
pretq={};

for ii=1:numel(simuCZset)
    for jj=1:numel(simuCZset{ii})
        precq{ii}{jj}=simuCZset{ii}{jj}{1};
        pretq{ii}{jj}=simuCZset{ii}{jj}{2};
    end
end

preCZ={};
for ii=1:numel(precq)
    for jj=1:numel(precq{ii})
        preCZ{ii}{jj}=sqc.op.physical.gate.ACZ(qubits{qes.util.find(precq{ii}{jj},qubits)},qubits{qes.util.find(pretq{ii}{jj},qubits)});
        if jj==1
            preGate{ii}=preCZ{ii}{1};
        else
            preGate{ii}=preGate{ii}.*preCZ{ii}{jj};
        end
    end
end

preGateCZ=preGate{1};
for ii=2:numel(preGate)
    preGateCZ=preGateCZ*preGate{ii};
end

proc=preGateCZ;

