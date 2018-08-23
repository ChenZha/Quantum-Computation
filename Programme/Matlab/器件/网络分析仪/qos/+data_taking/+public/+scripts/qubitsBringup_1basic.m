% bring up qubits
% Yulin Wu, 2017/3/11
clear all
cd('D:\QOS-v0.1\qos');
addpath('D:\QOSLib');
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.xmon.tuneup.*
import data_taking.public.jpa.*
import qes.*
import qes.hwdriver.sync.*
clc
QS = qSettings.GetInstance('E:\settings');
QS.SU('ming');
QS.SS('s180330_0622');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
% padLength = 2e3;
% com.qos.waveform.Waveform.setPadLength(padLength);
clc;
app.RE

% qes.util.copySession([],'s170626');
% sqc.util.resetQSettings();
%% just in case the hardware dose not startup with zero dc output, we set the output of qubit dc channels to zero
% setQSettings('zdc_amp',0);
% qubits = allQNames();
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};

for ii = 1:numel(qubits)
    % set to the dc value in registry:
	setZDC(qubits{ii});
    % or set to an specifice value
    % setZDC(qNames{ii},0);
end
% %% s21 vs power with network analyzer
% for qubitIndex = 1:9
% data_taking.public.s21_scan_networkAnalyzer(... % 'NAName' can be ommitted if there is only one network analyzer
%       'startFreq',readoutFreqs(qubitIndex)-0.5e6,'stopFreq',readoutFreqs(qubitIndex)+2e6,...
%       'numFreqPts',501,'avgcounts',30,...
%       'NAPower',[-30:1:20],'bandwidth',30e3,...
%       'notes','attenuation:30dB','gui',true,'save',true);
% end
% %% s21 vs qubit dc bias with network analyzer
% for qubitIndex = 1:1
% s21_zdc_networkAnalyzer('qubit',qNames{qubitIndex},...% 'NAName' can be ommitted if there is only one network analyzer
%       'startFreq',readoutFreqs(qubitIndex)-0.1e6,'stopFreq',readoutFreqs(qubitIndex)+1e6,...
%       'numFreqPts',51,'avgcounts',20,'NApower',-10,...
%       'biasAmp',[-3.2e4:200:3.2e4],'bandwidth',30e3,...
%       'gui',true,'save',true);
% end
%%
for ii=2:numel(qubits)
%     sqc.util.getQSettings('f01_set',qubits{ii})
    sqc.util.SetWorkingPoint(qubits{ii},sqc.util.getQSettings('f01_set',qubits{ii}),false)
end
%% s21 with DAC, a coarse scan to find all the qubit readoutFreqs
setQSettings('r_avg',1000);
for ii = 3%%:numel(qubits)
q=qubits{ii};
rfreq = getQSettings('r_freq',q);
freq = rfreq-0.5e6:0.01e6:rfreq+0.5e6;
% freq = 6.5e9:1e6:6.9e9;
amp = 2e3;
s21_rAmp('qubit',q,'freq',freq,'amp',amp,...
      'notes','','gui',true,'save',true,'updateSettings',true);
end
%% finds all qubit readoutFreqs automatically by fine s21 scan, session/public/autoConfig.readoutResonators.* has to be properly set for it to work
[readoutFreqs, pkWithd] = auto.qubitreadoutFreqs();
% after this you need to order readoutFreqs in accordance with qNames
% the upadate the readoutFreqs value to r_fr in registry for each qubit:
%%
for ii = 1:numel(qubits)
    % r_fr, the qubit dip frequency, it's exact value changes with qubit state and readout power,
    % the value of r_fr is just a reference frequency for automatic
    % routines, a close value is sufficient.
    setQSettings('r_fr',readoutFreqs(ii),qubits{ii});
    % also set r_freq is the frequency of the readout pulse, it is slightly
    % different than the qubit dip frequency after optimization, but at the beginning of the
    % meausrement, set it to the qubit dip frequency is OK.
    setQSettings('r_freq',readoutFreqs(ii),qubits{ii});
end
%%  s21 vs power with DAC to finds the dispersive shift
setQSettings('r_avg',1000);
for ii=2:numel(qubits)
    q=qubits{ii};
amp = logspace(log10(1000),log10(3e4),30);
% amp = getQSettings('r_amp',q);
rfreq = getQSettings('r_fr',q);
freq = rfreq-0.7e6:0.2e6:rfreq+0.5e6;
data1{ii}=s21_rAmp('qubit',q,'freq',freq,'amp',amp,...
      'notes','','gui',true,'save',true);
end
  %%
  for II=2:numel(qubits)
    dd=abs(cell2mat(data1{1,II}.data{1,1}));
%     dd=abs(cell2mat(Data{1,1}));
    z_ = 20*log10(abs(dd));
    sz=size(z_);
    for jj = 1:sz(2)
        z_(:,jj) = z_(:,jj) - z_(1,jj);
    end
    frqs=freq;
    [~,mm]=min(z_);
    figure;surface(frqs,amp,z_','edgecolor','none')
    hold on;plot3(frqs(mm),amp,100*ones(1,length(amp)),'-or')
    set(gca,'YScale','log')
    axis tight
    colormap('jet')
    title(qubits{II})
end
%%
q = 'q10';
rfreq = getQSettings('r_freq',q);
freq = rfreq-1e6:0.1e6:rfreq+1e6;
s21_zdc('qubit', q,...
      'freq',freq,'amp',[-3e4:1.5e3:3e4],'updateSettings',true,'isDip',true,...
      'gui',true,'save',true);
%%
s21_zpa('qubit', 'q4',...
      'freq',[readoutFreqs(4)-2.2e6:0.15e6:readoutFreqs(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);  
%% to find all the peaks
    % export data with DataViewer
    yinDB = 20*log10(abs(y)/max(abs(y)));
    [pks,locs,w,p] = findpeaks(-yDB,x,'SortStr','none','NPeaks',12,...
        'MinPeakDistance',15e6,...
        'MinPeakHeight',4,...
        'WidthReference','halfheight');
    figure();plot(x/1e9,yDB);hold on;plot(locs/1e9,-pks,'*');
%%
s21_01('qubit','q1','freq',6.635e9:0.1e6:6.638e9,'notes','','gui',true,'save',true);
%% hint: you can use this to measure IQ stability over a long duration of time
IQvsReadoutDelay('qubit','q1','delay',[36*ones(1,500)],...
    'notes','','gui',true,'save',true);

