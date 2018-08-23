% measure qubit dips with a network analyzer, this is the first step of a
% qubit measurement with resonator readout 
import  data_taking.public.s21_scan_networkAnalyzer
%%
%  <_o_> = s21_scan_networkAnalyzer('NAName',<[_c_]>,...
%       'startFreq',_f_,'stopFreq',_f_,...
%       'numFreqPts',_i_,'avgcounts',_i_,...
%       'NAPower',[_f_],'bandwidth',_f_,...
%       'notes',<[_c_]>,'gui',<_b_>,'save',<_b_>)
%% initial scan to find all qubit dips
doSave = true;
num_points = 2e4;
notes = 'network analyzer output => 40dB => A1';
s21_scan_networkAnalyzer(...
    'startFreq',6.475e9,'stopFreq',6.875e9,'numFreqPts',num_points,...
    'NAPower',0,'bandwidth',30e3,'avgcounts',10,...
    'notes',notes,'gui',true,'save',doSave);
%% now you should have found all the qubit dips
dips = [6.5079 6.5517 6.5945 6.6316 6.6791 6.7176 6.7593 6.7882 6.8018 6.8408]*1e9;
scanRange = 4e6; % fine scan each qubit dips
%% fine scan power dependence for each qubit dips
doSave = true;
pwr = 20:-1:-30;
notes = 'network analyzer output => 30dB => A1';
for ii = 1:10
f0 = dips(ii) - 1*scanRange/4;
f1 = dips(ii) + 3*scanRange/4;
s21_scan_networkAnalyzer(...
    'startFreq',f0,'stopFreq',f1,'numFreqPts',300,...
    'NAPower',pwr,'bandwidth',30e3,'avgcounts',50,...
    'notes',notes,'gui',true,'save',doSave);
end
%% measure stability overnight
doSave = true;
pwr = 20:-1:-30;
notes = 'network analyzer output => 30dB => A1';
for ii = 1:10
    pause(3600);
f0 = dips(2) - 1*scanRange/4;
f1 = dips(2) + 3*scanRange/4;
s21_scan_networkAnalyzer(...
    'startFreq',f0,'stopFreq',f1,'numFreqPts',300,...
    'NAPower',pwr,'bandwidth',30e3,'avgcounts',50,...
    'notes',notes,'gui',true,'save',doSave);
end