function [fidelity,err]=calClusterFidelity(Pxz,Pzx,measureQs,N,pathxz,pathzx)
%fidelity=data_taking.ming.sampling.calClusterFidelity('','','','E:\data\20180216_12bit\sampling\20180505\Overall_8bit_clusterState_q5_q12_L2_180506T070456.mat','');
if nargin<4
    N=2500*10;
end
if nargin>=5
    load(pathxz);
    if exist('P')
        Pxz=P;
        zxdata=load(pathzx);
        Pzx=zxdata.P;
    else
        Pxz=Pxz;
        Pzx=Pzx;
    end
    measureQs=measureQs;
end
load('E:\data\20180622_12bit\sampling\toFidelity1.mat')
numQ=numel(measureQs);
Pxz=renormalize(mean(Pxz,1));
Pzx=renormalize(mean(Pzx,1));
if ismember(measureQs{end},{'q2','q4','q6','q8','q10','q12'})
    XZ=toFidelity{numQ-1}{2};
    ZX=toFidelity{numQ-1}{3};
else
    XZ=toFidelity{numQ-1}{3};
    ZX=toFidelity{numQ-1}{2};
end
if numQ==12
    pause(1)
end
% figure(55);subplot(2,2,1);bar(XZ/sum(XZ));xlabel('States');ylabel('\alpha_xz');axis tight;title('XZ');subplot(2,2,3);bar(Pxz);axis tight;xlabel('States');ylabel('\alpha_zx');
% subplot(2,2,2);bar(ZX);axis tight;xlabel('States');ylabel('\alpha_xz');title('ZX');subplot(2,2,4);bar(Pzx);axis tight;xlabel('States');ylabel('\alpha_zx');
fidelity=sum(Pxz.*XZ)+sum(Pzx.*ZX)-1;
err=sqrt(sum(abs(Pxz.*XZ))+sum(abs(Pzx.*ZX)))/sqrt(N);
end
function data=renormalize(data)
% data(find(data<0))=0;
% data=data/sum(data);
end