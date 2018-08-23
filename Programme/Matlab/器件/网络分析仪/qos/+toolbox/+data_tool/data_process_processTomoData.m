%% CZ
if ~exist('CZTomoData','var')
    CZTomoData = P;
end
chi = sqc.qfcns.processTomoData2Chi(CZTomoData);
phi = toolbox.data_tool.fitting.fitCZPhase(CZTomoData)
PIdeal = sqc.qfcns.CZChiP(phi);
chiIdeal = sqc.qfcns.processTomoData2Chi(PIdeal);
trace(chi*chiIdeal)
trace(chi*chiIdeal)/trace(chi)/trace(chiIdeal)

ax = qes.util.plotfcn.Chi(CZTomoData,[],1,real(trace(chi*chiIdeal)));
hold(ax(1),'on');
hold(ax(2),'on');
qes.util.plotfcn.Chi(PIdeal,ax,0);

clear CZTomoData

%% Idle
if ~exist('TomoData','var')
    TomoData = P;
end
chi = sqc.qfcns.processTomoData2Chi(TomoData);
phi = toolbox.data_tool.fitting.fit2QIdlePhase(TomoData)
PIdeal = sqc.qfcns.IChiP(phi);
chiIdeal = sqc.qfcns.processTomoData2Chi(PIdeal);
trace(chi*chiIdeal)
trace(chi*chiIdeal)/trace(chi)/trace(chiIdeal)

ax = qes.util.plotfcn.Chi(TomoData,[],1,real(trace(chi*chiIdeal)));
hold(ax(1),'on');
hold(ax(2),'on');
qes.util.plotfcn.Chi(PIdeal,ax,0);

clear TomoData