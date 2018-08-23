%% iq2prob_centers tester
numSamples = 4e4;
sigma = 0.5;
showProcess = true;


iq_raw_0 = normrnd(0,sigma,numSamples,1)+1j*normrnd(0,0.3,numSamples,1);
iq_raw_1 = normrnd(1,sigma,numSamples,1)+1j*normrnd(1,0.3,numSamples,1);


[center0, center1] =... 
		data_taking.public.dataproc.iq2prob_centers(iq_raw_0,iq_raw_1,~showProcess);

figure();
plot(iq_raw_0,'.b'); hold on; plot(iq_raw_1,'.r');
plot(center0,'+g','MarkerSize',15,'LineWidth',2);
plot(center1,'+g','MarkerSize',15,'LineWidth',2);