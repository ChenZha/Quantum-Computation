q = 'q1';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-300e6:0.5e6:f01+20e6;
biasamp = 0:2000:3e4;
spectroscopy1_zpa('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P

q = 'q2';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+20e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P

q = 'q3';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q4';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q5';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q6';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q7';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P   
   
q = 'q8';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1.5e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q9';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -0.5e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q10';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -1e4:2000:3e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q11';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -2e4:2000:2e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
q = 'q12';
setQSettings('r_avg',700);
f01 = getQSettings('f01',q);
freq = f01-400e6:0.5e6:f01+50e6;
biasamp = -2e4:2000:2e4;
spectroscopy1_zdc('qubit',q,'biasAmp',biasamp,'driveFreq',[freq],...
       'updateReadoutFreq',true,'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
   
   
   
   
   
   
   
   
   
   
   