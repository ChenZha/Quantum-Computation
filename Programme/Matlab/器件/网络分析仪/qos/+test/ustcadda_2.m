%%
% ustcadda tester
%%
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
%% not needed unless you want to reconfigure the DACs and ADCs during the measurement
% a DACs and ADCs reconfiguration is only needed when the hardware settings
% has beens changed, a reconfiguration will update the changes to the
% hardware.
ustcaddaObj = qes.hwdriver.sync.ustcadda_v1.GetInstance();
%%
ustcaddaObj.close()
%% run all channels
numChnls = 60;
numRuns = 100000;
% wavedata=[32768*zeros(1,10),65535*zeros(1,10),32768*zeros(1,1)];
wavedata=[3e4*zeros(1,500),0*zeros(1,500)];
ustcaddaObj.runReps = 2e3;
tic
clc
for jj = 1:numRuns
    tic
    for ii = 1:numChnls
%         tic
        ustcaddaObj.SendWave(ii,wavedata);
%         ii
%         toc
    end
    ustcaddaObj.Run(false);
%      [datai,dataq] = ustcaddaObj.Run(true);
    
    pause(0.5);
    toc
%     disp(sprintf('%0.0f, elapsed time: %0.1fs',jj,t));
end
%% sync test, and use the mimimum oscillascope vertical range to check zero offset
ustcaddaObj.runReps = 1e4;
ustcaddaObj.SendWave(37,[32768*ones(1,200),33768*ones(1,200)]+0); % 620
ustcaddaObj.SendWave(38,[32768*ones(1,200),33768*ones(1,200)]+0); % 750
ustcaddaObj.SendWave(39,[32768*ones(1,200),33768*ones(1,200)]+0); % -230
ustcaddaObj.SendWave(40,[32768*ones(1,200),33768*ones(1,200)]+0); % -400
ustcaddaObj.Run(false);
%% Amp test
t=1:4000;
wave1=32768+32768/2*cos(2*pi*t/40);
wave2=32768+32768/2*sin(2*pi*t/40);
ustcaddaObj.runReps = 1000;
ustcaddaObj.SendWave(2,wave1); % 620
ustcaddaObj.SendWave(1,wave2); % 750
[datai,dataq] = ustcaddaObj.Run(true);
plot(mean(datai,1));hold on;plot(datai(1,:));hold off;
%%
t=1:4000;
wave1=32768+32768/2*cos(2*pi*t/10);
wave2=32768+32768/2*sin(2*pi*t/10);
ustcaddaObj.SendContinuousWave(2,wave1)
ustcaddaObj.SendContinuousWave(1,wave2)
%% sin wave
for ii = 10
    ustcaddaObj.SendWave(ii,32768+32768*sin((1:8000)/1000*2*pi));
end
ustcaddaObj.Run(false);
%% test da -> ad
clc
wvLn = 4e3; % 2us
wvData = 32768+1000*ones(1,wvLn);
ustcaddaObj.runReps = 1000;
% ustcaddaObj.setDAChnlOutputDelay(1,100);
% ustcaddaObj.setDAChnlOutputDelay(2,100);
% ustcaddaObj.setDAChnlOutputDelay(3,100);
% ustcaddaObj.setDAChnlOutputDelay(4,100);
ustcaddaObj.SendWave(15,wvData); % 620
% ustcaddaObj.SendWave(2,wvData); % 750
% ustcaddaObj.SendWave(3,wvData); % 620
% ustcaddaObj.SendWave(4,wvData); % 750
tic
data = ustcaddaObj.Run(true);
toc
%%
ustcaddaObj.runReps = 100;
for ii = 0:200:20e3
    clc;
    disp(sprintf('waveform code: %d',ii));
    wvData = (32768+ii)*ones(1,2000);   
%     ustcaddaObj.SendWave(15,wvData);
    ustcaddaObj.SendWave(21,wvData);
%     ustcaddaObj.SendWave(21,wvData); 
    data = ustcaddaObj.Run(true);
end
%%
N = 10;
runReps = ceil(logspace(1,4,30));
wvLn = 4e3; % 2us
T = nan*ones(1,N);
for ii = 1:N
    tic
    ustcaddaObj.runReps = runReps(ii);
    ustcaddaObj.SendWave(3,65535*ones(1,wvLn));
    ustcaddaObj.SendWave(4,65535*ones(1,wvLn));
    data = ustcaddaObj.Run(true);
    T(ii) = toc;
end
figure();
semilogx(runReps,T-runReps/5e3);
xlabel('Number of samples');
ylabel('Time taken(s)');
title('Repetition 5kHz,waveform length 4000pts(da), 2000pts(ad).');
%%
wvLn = 4e3; % 2us
N = 20;
T = nan*ones(1,N);
for ii = 1:N
    tic
    ustcaddaObj.runReps = 1000;
    ustcaddaObj.SendWave(3,65535*ones(1,wvLn));
    ustcaddaObj.SendWave(4,65535*ones(1,wvLn));
    data = ustcaddaObj.Run(true);
    T(ii) = toc;
end
figure();
plot(1:N,T);
xlabel('Number of runs');
ylabel('Time taken(s)');
%%