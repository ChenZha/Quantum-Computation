cd F:\program\QOS\qos
addpath('F:\program\QOS\qos\dlls');
import qes.hwdriver.sync.*
%%
idc = ustc_dc_v1([1,2,3,4]);
dcSrc = dcSource.GetInstance('usct_dadc',idc);
dcChnl1 = dcSrc.GetChnl(1);
dcChnl1.dcval = -32768;