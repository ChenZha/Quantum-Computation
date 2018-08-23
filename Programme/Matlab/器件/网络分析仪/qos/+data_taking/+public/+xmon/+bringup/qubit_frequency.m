function qubit_frequency(qName)
    % bring up qubit frequency. 
    % qubit frequency might drifts from time to time, run this function
    % will automatically bring the qubit frequency back to the frequency
    % set in the settings: qubit.f01
    
    % Yulin Wu, 2017/1/7
    import data_taking.public.xmon.spectroscopy1
    e = spectroscopy1('qubit',qName,'bias',0,'drive_freq',f,'save',false);
    P = d{2}{1};
end