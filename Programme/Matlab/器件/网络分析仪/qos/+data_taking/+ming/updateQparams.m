function updateQparams()
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
msg={};
msg=[msg;{''},qubits];

T1=sqc.util.getQSettings('T1')'/1e3;
T1msg={'T1(us)'};
for ii=1:12
T1msg=[T1msg,num2str(T1(ii),'%.1f')];
end

T2=sqc.util.getQSettings('T2')'/1e3;
T2msg={'T2(us)'};
for ii=1:12
T2msg=[T2msg,num2str(T2(ii),'%.1f')];
end

fidd=sqc.util.getQSettings('r_iq2prob_fidelity');fids=fidd(:,1)+fidd(:,2)-1;
fidsmsg={'Readout'};
for ii=1:12
fidsmsg=[fidsmsg,num2str(fids(ii)*100,'%.1f')];
end

f01=sqc.util.getQSettings('f01');
f01msg={'f01(GHz)'};
for ii=1:12
f01msg=[f01msg,num2str(f01(ii)/1e9,'%.4f')];
end

fah=sqc.util.getQSettings('f_ah');
fahmsg={'f_ah(MHz)'};
for ii=1:12
fahmsg=[fahmsg,num2str(fah(ii)/1e6,'%.1f')];
end

ramp=sqc.util.getQSettings('r_amp');
rampmsg={'r_amp'};
for ii=1:12
rampmsg=[rampmsg,num2str(ramp(ii),'%.3e')];
end

rln=sqc.util.getQSettings('r_ln');
rlnpmsg={'r_ln'};
for ii=1:12
rlnpmsg=[rlnpmsg,num2str(rln(ii),'%.3e')];
end

xyamp=sqc.util.getQSettings('g_XY2_amp');
xyampmsg={'g_XY2_amp'};
for ii=1:12
xyampmsg=[xyampmsg,num2str(xyamp(ii),'%.3e')];
end

msg=[msg;T1msg;T2msg;fidsmsg;f01msg;fahmsg;rampmsg;rlnpmsg;xyampmsg];
xlswrite('E:\data\20180622_12bit\_summary\Qubits.xls',msg)
end