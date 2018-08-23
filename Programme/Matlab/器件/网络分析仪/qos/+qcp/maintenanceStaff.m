%% maintenance staff
import qes.util.showQubitPropRecords
import qes.util.plotSettingsHis

timeRange = [now-7, now];

showQubitPropRecords('f01',timeRange,true);
% showQubitPropRecords('zdc_amp',timeRange,true);
% showQubitPropRecords('g_XY2_amp',timeRange,true);
% showQubitPropRecords('r_iq2prob_center0',timeRange,true);
% showQubitPropRecords('r_iq2prob_center1',timeRange,true);
%%
currentSession = qes.util.loadSettings('D:\settings\qCloud','selected');

qes.util.plotSettingsHis(fullfile('D:\settings\qCloud',currentSession,'shared','g_cz'),...
    {{'q1_q2','amp'},{'q3_q2','amp'},{'q3_q4','amp'},{'q5_q4','amp'},{'q5_q6','amp'},...
    {'q7_q6','amp'},{'q7_q8','amp'},{'q9_q8','amp'},{'q9_q10','amp'},{'q11_q10','amp'}},...
    timeRange,[],true);
%%
[s, r, t] = qes.util.loadSettings(fullfile('D:\settings\qCloud',currentSession,'shared','g_cz'),...,
    {'q3_q2','dynamicPhases'},true);
r(end+1,:) = s;
t(end+1) = now;
rmvInd = t < timeRange(1) | t > timeRange(2);
r(rmvInd,:) = [];
t(rmvInd) = [];
figure();plot(t,r/pi);