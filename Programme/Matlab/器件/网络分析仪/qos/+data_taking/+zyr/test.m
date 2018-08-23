%%
qNames = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
for ii = 1:numel(qNames)
    % set to the dc value in registry:
	setZDC(qNames{ii});
    % or set to an specifice value
    % setZDC(qNames{ii},0);
end
%%
for ii = 1:numel(qNames)
	setZDC(qNames{ii});
end
q = 'q2';
setQSettings('readoutQubits',{q},'shared');
dcAmp = getQSettings('zdc_amp',q);
r_freq = getQSettings('r_freq',q);
r_amp = getQSettings('r_amp',q);
readoutfreq = r_freq-1e6:0.02e6:r_fr+0.2e6;
s21data=s21_rAmp('qubit',q,'freq',readoutfreq,'amp',r_amp,...
      'notes','','gui',true,'save',true);
s21data = s21data.data{1,1};
s21data = cell2mat(s21data);
[s21,index] = min(abs(s21data));
r_freq = readoutfreq(index);
setQSettings('r_freq',r_freq,q);
biasAmp = dcAmp-5000:2000:dcAmp+5000;
f01 = getQSettings('f01',q);
freq = f01-25e6:1e6:f01+25e6;
spectroscopy1_zdc('qubit',q,'biasAmp',biasAmp,'driveFreq',[freq],...
'dataTyp','S21','gui',true,'save',true);
%%
for ii = 1:numel(qNames)
	setZDC(qNames{ii});
end
for ii = 1:numel(qNames)
q = qNames{ii};
setQSettings('readoutQubits',{q},'shared');
dcAmp = getQSettings('zdc_amp',q);
biasAmp = dcAmp-5000:2000:dcAmp+5000;
f01 = getQSettings('f01',q);
freq = f01-50e6:2e6:f01+50e6;
spectroscopy1_zdc('qubit',q,'biasAmp',biasAmp,'driveFreq',[freq],...
'dataTyp','S21','gui',true,'save',true);
end
%%
for ii = 1:numel(qNames)
	setZDC(qNames{ii});
end
q = 'q12';

setQSettings('readoutQubits',{q},'shared');
biasAmp = -25000:500:0;
freq = 4e9:3e6:4.55e9;

spectroscopy1_zdc('qubit',q,'biasAmp',biasAmp,'driveFreq',[freq],...
'dataTyp','S21','gui',true,'save',true);