%% test mw source signalcore
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
%%
iobj = simuMwSrc.GetInstance();
%%
mwSrc = mwSource.GetInstance('mwSrc_simulated_1',iobj);
%%
mwChnl = mwSrc.GetChnl(1);
mwChnl.frequency = 6.9e9;
mwChnl.power = -10;
mwChnl.on = true;