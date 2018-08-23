function P = qcpdt(P)
% "Due to low readout visibility(high readout error) of the current 11-bit sample, ",
% "we have to perform a calibration on the measured state counts to obtain the real state probabilities, ",
% "since the measured calibration matrix is not accurate, the calibrated results may have small minus values, ",
% "we remove these non physical values by set them to zeros and re-normalize the state probabilities."

    P(P < 0) = 0;
    P = P/sum(P);
end