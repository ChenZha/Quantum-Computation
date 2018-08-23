numtest=80;
singlestus=2.5e4;

fidelity=NaN(numtest,12,2);
center0=NaN(numtest,12);
center1=NaN(numtest,12);
visibility=NaN(numtest,12);
datafile=['E:\data\20180216_12bit\readout cross talk\' 'ReadoutStability_',datestr(now,'hhmmss'),'.mat'];

for ii=1:numtest
    disp(['Test' num2str(ii)])
    data_taking.public.xmon.tuneup.iq2prob_01('qubits',qubits,'numSamples',singlestus,'gui',false,'save',true);
    fidelity(ii,:,:)=sqc.util.getQSettings('r_iq2prob_fidelity');
    center0(ii,:)=sqc.util.getQSettings('r_iq2prob_center0');
    center1(ii,:)=sqc.util.getQSettings('r_iq2prob_center1');
    visibility(ii,:)=sum(fidelity(ii,:,:),3)-1;
    save(datafile,'fidelity','center0','center1','visibility','numtest','singlestus')
end


hf=figure;
subplot(4,1,1);
plot(fidelity(:,:,1))
title(['readout 0 fidelity overall std=' num2str(mean(std(fidelity(:,:,1))))])
subplot(4,1,2);
plot(fidelity(:,:,2))
title(['readout 1 fidelity overall std=' num2str(mean(std(fidelity(:,:,2))))])
subplot(4,1,3);
plot(center0,'.');hold on;plot(center1,'.');
subplot(4,1,4);
plot(visibility)
title(['total visibility overall std=' num2str(mean(std(visibility)))])

saveas(hf,replace(datafile,'.mat','.fig'));