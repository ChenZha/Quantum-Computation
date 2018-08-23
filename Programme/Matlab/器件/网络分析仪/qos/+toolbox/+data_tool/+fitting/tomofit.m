% 数据： P
% 格式：
% 4^n x 3^n x 2^n
% P(n,:,:) 是第n个State tomo 数据
% 对两比特：
% P(1,:,:)： 初态是 |q2:0, q1:0>；
% P(2,:,:)： 初态是 |q2:0, q1:1>；
% P(3,:,:)： 初态是 |q2:0, q1:+>；
% P(4,:,:)： 初态是 |q2:0, q1:i>；
% P(5,:,:)： 初态是 |q2:1, q1:0>；
% P(6,:,:)： 初态是 |q2:1, q1:1>；
% 态： {0,1,+,i} => {|0>, |1>, |0>+|1>, |0>+i|1>} ;
% state tomo 数据格式：3^n by 2^n， n 是比特数
% 行排序： 
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:Z},... ,{q2:Z q1:Z}
% X: Y/2 门, 测量 X 分量
% Y：-X/2 门, 测量 Y 分量
% Z：I 门, 测量 Z 分量
% 列排序： 
%       1Q: P|0>, P|1> 
%       2Q: P|q2:0, q1:0>，P|q2:0, q1:1>， P|q2:1, q1:0>， P|q2:1, q1:1>
   
%%
load('D:\Work\Software Documents\Matlab\20170908Tomo\PTomo2_q9q8_170907T144314_2ACZ.mat')
load('D:\Work\Software Documents\Matlab\20170908Tomo\PTomo2_q9q8_170907T143713_1ACZ.mat')
%% CZ
if ~exist('CZTomoData','var')
    CZTomoData = P;
end
chi = sqc.qfcns.processTomoData2Chi(CZTomoData);
phi = toolbox.data_tool.fitting.fitCZPhase(CZTomoData)
PIdeal = sqc.qfcns.CZChiP(phi);
chiIdeal = sqc.qfcns.processTomoData2Chi(PIdeal);
trace(chi*chiIdeal)
trace(chi*chiIdeal)/trace(chi)/trace(chiIdeal)
ax = qes.util.plotfcn.Chi(CZTomoData,[],1,real(trace(chi*chiIdeal)));
hold(ax(1),'on');
hold(ax(2),'on');
qes.util.plotfcn.Chi(PIdeal,ax,0);
clear CZTomoData
%%
showprocesstomo(P,PIdeal);