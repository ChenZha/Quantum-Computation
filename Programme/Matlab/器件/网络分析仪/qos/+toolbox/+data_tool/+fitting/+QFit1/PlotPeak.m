%% plot amplitude

plot(freq*1e-9,log10(abs(s21))*20);
title('Amplitude of S21');
xlabel('Frequency(GHz)');
ylabel('S21(dB)');

%% plot phase

plot(freq,angle(s21));
title('Phase of S21');
xlabel('Frequency(GHz)');
ylabel('\angleS21(dB)');

%% plot smith

plot(real(1./s21),imag(1./s21));
title('Smith of S21^{-1}');
xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]');

%% plot amplitudeof calirated s21

calibrateds21 = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.calibrate(s21);

plot(freq*1e-9,log10(abs(calibrateds21))*20);
title('Amplitude of S21');
xlabel('Frequency(GHz)');
ylabel('S21(dB)');

%% plot phase of calirated s21

calibrateds21 = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.calibrate(s21);

plot(freq,angle(calibrateds21));
title('Phase of S21');
xlabel('Frequency(GHz)');
ylabel('\angleS21(dB)');

%% plot smith of calirated s21

calibrateds21 = yarui.Resonator.DataAnalyzeFitting.Fitting.QFit1.calibrate(s21);
plot(real(1./calibrateds21),imag(1./calibrateds21));
title('Smith of S21^{-1}');
xlabel('Re[S_{21}^{-1}]'); ylabel('Im[S_{21}^{-1}]');