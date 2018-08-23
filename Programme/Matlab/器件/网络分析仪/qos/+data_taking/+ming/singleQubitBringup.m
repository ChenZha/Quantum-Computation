% bring up qubits one by one
% GM, 2017/4/14
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170509');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
import data_taking.public.util.*
import data_taking.public.xmon.*
%%
% qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
qubits = {'q1','q3','q4','q5'};
dips = [6.6903e+09 6.8060e+09 6.6163e9 6.577e9 ]; % by qubit index
%%
ustcaddaObj.close()
%%
for ii=3:3
s21_zdc_networkAnalyzer('qubit',qubits{ii},'NAName',[],'startFreq',dips(ii)-10e6,'stopFreq',dips(ii)+2e6,'numFreqPts',500,'avgcounts',30,'NApower',-15,'amp',[-3e4:1e3:3e4],'bandwidth',10000,'notes','','gui',true,'save',true)
end
%% S21
s21_zdc('qubit', qubits{1},...
      'freq',6.5e9:2e6:7e9,'amp',0,...
      'notes','','gui',true,'save',true);
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(1000),log10(30000),41)];
for ii = 2:2
s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-4e6:0.1e6:dips(ii)+0e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
      'notes',['RT attenuation:20dB; ' qubits{ii}],'gui',true,'save',true,'r_avg',1000);
end
%%

for II=2
s21_zdc('qubit', qubits{II},...
      'freq',[dips(II)-2e6:0.1e6:dips(II)+2e6],'amp',[-5e3:0.5e3:5e3],...
      'notes',[qubits{II}],'gui',true,'save',true);
end

%%
for ii=2
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(ii)-2e6:0.1e6:dips(ii)+2e6],'amp',[-3e4:3e3:3e4],...
      'notes',[qubits{ii} ', S21 vs Z pulse'],'gui',true,'save',true);
end



%% spectroscopy1_zpa_s21

for ii=2
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},6000)
    spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',[-3e4:1e3:3e4],'driveFreq',[6.3e9:2e6:6.55e9],...
       'r_avg',1000,'notes','','gui',true,'save',true);
end
%%
amp=5e3;
QS.saveSSettings({qubits{2},'spc_driveAmp'},amp)
spectroscopy1_zpa_s21('qubit',qubits{2},...
       'biasAmp',0,'driveFreq',[5.4e9:1e6:5.9e9],...
       'notes',[qubits{2} ', spc amp: ' num2str(amp)],'r_avg',1000,'gui',true,'save',true);
%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q3','biasAmp',[0],'biasLonger',10,...
      'xyDriveAmp',[0:300:3e4],'detuning',[0],'driveTyp','X','notes','RT 20dB',...
      'dataTyp','S21','r_avg',10000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% To do
rabi_long111('biasQubit','q3','driveQubit','q3','readoutQubit','q3','biasAmp',[0],'biasLonger',0,...
      'xyDriveAmp',[1e4],'xyDriveLength',[10:50:2000],'detuning',[0],'driveTyp','X',...
      'dataTyp','S21','r_avg',5000,'gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q2','gateTyp','X','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q3','gui',true,'save',true);
tuneup.iq2prob_01('qubit','q3','numSamples',1e4,...
      'gui',true,'save',true)
 
%%
spectroscopy1_zdc('qubit','q2',...
       'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
       'r_avg',1000,'gui',true,'save',true);
%%
% ramsey_df('qubit','q4',...
%       'time',[0:400:30000],'detuning',[1]*1e6,...
%       'dataTyp','S21','notes','','gui',true,'save',true);
ramsey_df01('qubit','q2',...
      'time',[0:40:2000],'detuning',[+4]*1e6,...
      'dataTyp','S21','notes','','gui',true,'save',true);
%%
T1_1_s21('qubit','q3','biasAmp',[0],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',10000)
  %%
  T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',5000)