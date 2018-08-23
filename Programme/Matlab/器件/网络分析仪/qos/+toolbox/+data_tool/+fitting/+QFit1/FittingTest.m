%%
datafreq = catchedfreq;
datas21 = castcheds21;
n = length(datafreq);
% m = fix(n/100);
% datafreq = datafreq((1:m)*100);
% datas21 = datas21((1:m)*100);
calibrateds21 = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.calibrate(datafreq,datas21);

[ c,dc ] = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.qfit1( datafreq,calibrateds21,true);
%% Power dependent of Q factor
peakdata = peakdatas(4);

ipowers = ([1:4 6 8:length(peakdata.Power)-1]);
power = peakdata.Power(ipowers);

datafreq = peakdata.Freq;
datas21 = peakdata.S21(ipowers,:);

calibrateds21 = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.calibrate(datafreq,datas21);

npower = length(power);
c = zeros(npower,4);
dc = zeros(npower,4);
for ipower = 1:npower
    [ c(ipower,:),dc(ipower,:) ] = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.qfit1( datafreq,calibrateds21(ipower,:),false);
end
yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.showfittingresult( peakdata.Name,power,datafreq,calibrateds21,c,dc );
% f0 = c(:,1);
% Qi = c(:,2);
% Qc = c(:,3);
% phi = c(:,4);
% 
% df0 = dc(:,1);
% dQi = dc(:,2);
% dQc = dc(:,3);
% dphi = dc(:,4);

% figure();errorbar(power,Qi,dQi,'blue');
% hold on
% errorbar(power,Qc,dQc,'r');
% legend('Qi','Qc')
% title(peakdata.Name);
% xlabel('Power(dB)');
% ylabel('Qi&Qc');
% 
% figure();errorbar(power,f0,df0,'blue');
% legend('f0')
% title(peakdata.Name);
% xlabel('Power(dB)');
% ylabel('f0(Hz)');
%%
JPAdip1_f0 = [];
JPAdip1_Qi = [];
JPAdip1_Qc = [];
JPAdip1_phi = [];

JPAdip1_df0 = [];
JPAdip1_dQi = [];
JPAdip1_dQc = [];
JPAdip1_dphi = [];
JPAdip1_power = [];
%%
JPAdip1_f0 = [JPAdip1_f0 c(:,1)'];
JPAdip1_Qi = [JPAdip1_Qi c(:,2)'];
JPAdip1_Qc = [JPAdip1_Qc c(:,3)'];
JPAdip1_phi = [JPAdip1_phi c(:,4)'];

JPAdip1_df0 = [JPAdip1_df0 dc(:,1)'];
JPAdip1_dQi = [JPAdip1_dQi dc(:,2)'];
JPAdip1_dQc = [JPAdip1_dQc dc(:,3)'];
JPAdip1_dphi = [JPAdip1_dphi dc(:,4)'];
JPAdip1_power = [JPAdip1_power power];
%%
figure();errorbar(JPAdip1_power,JPAdip1_Qi,JPAdip1_dQi,'blue');
hold on
errorbar(JPAdip1_power,JPAdip1_Qc,JPAdip1_dQc,'r');
legend('Qi','Qc')
title(peakdata.Name);
xlabel('Power(dB)');
ylabel('Qi&Qc');

figure();errorbar(JPAdip1_power,JPAdip1_f0,JPAdip1_df0,'blue');
legend('f0')
title(peakdata.Name);
xlabel('Power(dB)');
ylabel('f0(Hz)');
%%
figure();errorbar(dip1_power,dip1_Qc,dip1_dQc,'blue');
hold on
errorbar(JPAdip1_power,JPAdip1_Qc,JPAdip1_dQc,'--b');
errorbar(dip2_power,dip2_Qc,dip2_dQc,'red');
errorbar(JPAdip1_power,JPAdip1_Qc,JPAdip1_dQc,'black');
title('Qc of dip1-3');
xlabel('Power(dB)');
ylabel('Qi&Qc');
legend('dip1','dip1_JPA','dip2','dip3');
%%
figure();plot(dip1_power,dip1_Qi,'blue');
hold on
plot(JPAdip1_power,JPAdip1_Qi,'--bo');
plot(dip2_power,dip2_Qi,'red');
plot(JPAdip2_power,JPAdip2_Qi,'--ro');
plot(dip3_power,dip3_Qi,'k');
plot(JPAdip3_power,JPAdip3_Qi,'--ko');

title('Qi of dip1-3');
xlabel('Power(dB)');
ylabel('Qi&Qc');
legend('dip1','dip1-JPA','dip2','dip2-JPA','dip3','dip3-JPA');