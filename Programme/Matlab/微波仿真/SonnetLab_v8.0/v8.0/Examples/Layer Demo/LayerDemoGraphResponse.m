%*******************************************************
% This function analyzes the results of the circuit
% design with respect to BandWidth. It finds the
% BandWidth and returns it back to the caller.
%*******************************************************
function LayerDemoGraphResponse(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude)

disp('Graphing Frequency vs. Magnitude.');

figure(2);   
plot(Sp1DataFreq,Sp1DataMagnitude);        
title(sprintf('Frequency Vs. Magnitude (dB) For Circuit %d\\_%s',iCounter,FileName));
xlabel('Frequncy (GHZ)');
ylabel('Magnitude (dB)');
grid on
axis tight
axis([min(Sp1DataFreq) max(Sp1DataFreq) min(Sp1DataMagnitude) max(Sp1DataMagnitude)])

end