% PTomoDataCZ = twoQProcessTomo('qubit1','q7','qubit2','q8',...
%     'process','CZ','reps',1,...
%     'notes','','gui',true,'save',true);

phi = toolbox.data_tool.fitting.fitCZPhase(PTomoDataCZ1);
PIdeal = sqc.qfcns.CZP(phi);
ax = qes.util.plotfcn.Chi(PTomoDataCZ1);
hold(ax(1),'on');
hold(ax(2),'on');
ax = qes.util.plotfcn.Chi(PIdeal,ax,0);
