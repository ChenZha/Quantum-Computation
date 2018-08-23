% ustcadda demodulation tester
%%
demodeFreq = 100e6;
%%
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
%%
daInterface = ustc_da_v1([3,4]);
awgObj = awg.GetInstance('tempAWG',daInterface);
%%
mwSrcInterface = visa('agilent','TCPIP0::10.0.0.4::inst0::INSTR');
mwSrc_ = mwSource.GetInstance('anritsu_02',mwSrcInterface);
mwSrc = mwSrc_.GetChnl(1);
%%
mwSrc.frequency = 6.5e9;
mwSrc.power = 20;
mwSrc.on = true;
%%
ad = ustc_ad_v1.GetInstance('ustc_ad_v1',[1,2]);
ad.recordLength = 2000;
iq_obj = sqc.measure.iq_ustc_ad(ad);
iq_obj.n = 500;
iq_obj.freq = demodeFreq;
iq_obj.startidx = 15;
iq_obj.endidx = ad.recordLength-0;
%%
g = qes.waveform.dc(4e3);
g.dcval = 3e4;
g.df = demodeFreq/2e9;
% g.phase = pi/2;
%%
t = 0:0.2:50;
figure();
plot(t,real(g(t)),t,imag(g(t)));
%%
g.awg = awgObj;
g.awgchnl = [1,2];
%%
% g.awg.SetTrigOutDelay(1,0);
% g.output_delay = [0,0];
g.SendWave();
% g.Run(2e4);
%%
mwSrc.power = 20;
mwSrc.on = true;

g.df = 0.05;
g.dcval = 1e4;
iq_obj.freq = demodeFreq;

num = 100;
phi = linspace(0,2*pi,num);
iq = NaN*zeros(1,num);

figure();
ln = line(real(iq),imag(iq));

for ii = 1:num
    g.phase = phi(ii);
    g.SendWave();
    iq(ii) = iq_obj();
    set(ln,'XData',real(iq),'YData',imag(iq));
    set(gca,'PlotBoxAspectRatio',[1,1,1],...
                    'PlotBoxAspectRatio',[1,1,1],...
                    'DataAspectRatio',[1,1,1],'PlotBoxAspectRatio',[1,1,1]);
    drawnow;
end