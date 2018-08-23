%% test mw source signalcore
import qes.*
import qes.hwdriver.sync.signalCore5511a
QS = qSettings.GetInstance('D:\settings');
%%
iobj = signalCore5511a.GetInstance();
%%
mwSrc = mwSource.GetInstance('mwSrc_sc5511a',iobj);
%%
mwChnl = mwSrc.GetChnl(5);
mwChnl.frequency = 6.9e9;
mwChnl.power = -10;
mwChnl.on = true;