chi = sqc.qfcns.processTomoData2Chi(CZTomoData);
figure;bar3(real(chi));figure;bar3(imag(chi));
phi = toolbox.data_tool.fitting.fitCZPhase(CZTomoData)
PIdeal = sqc.qfcns.CZP(phi);
chiIdeal = sqc.qfcns.processTomoData2Chi(PIdeal);
trace(chi*chiIdeal)
trace(chi*chiIdeal)/trace(chi)/trace(chiIdeal)


%%
ax = qes.util.plotfcn.Chi(CZTomoData);
hold(ax(1),'on');
hold(ax(2),'on');
qes.util.plotfcn.Chi(PIdeal,ax,0);