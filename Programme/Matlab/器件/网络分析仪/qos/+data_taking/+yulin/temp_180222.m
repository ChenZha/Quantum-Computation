q = 'q3';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-20e6:0.3e6:f01+100e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-5000:500:zdcamp+5000;
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P

q = 'q4';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-100e6:0.4e6:f01+100e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q5';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-50e6:0.4e6:f01+50e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q6';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-100e6:0.4e6:f01+100e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q7';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-30e6:0.4e6:f01+10e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q8';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-100e6:0.4e6:f01+100e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q9';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-30e6:0.4e6:f01+10e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

% q = 'q10';
% setQSettings('r_avg',700);
% f01 = getQSettings('f01',q);
% % freq = f01-1e6:0.03e6:f01+0.5e6;
% freq = f01-100e6:0.4e6:f01+100e6;
% zdcamp = getQSettings('zdc_amp',q);
% biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% % biasamp = 0;
% spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
%        'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% % spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q11';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-50e6:0.4e6:f01+50e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode

q = 'q12';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
% freq = f01-1e6:0.03e6:f01+0.5e6;
freq = f01-100e6:0.4e6:f01+100e6;
zdcamp = getQSettings('zdc_amp',q);
biasamp = zdcamp-15000:500:min(32768,zdcamp+5000);
% biasamp = 0;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
% spectroscopy1_zpa('qubit','q2'); % lazy mode
