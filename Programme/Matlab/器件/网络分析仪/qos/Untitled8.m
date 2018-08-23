t0 = now;
calInterval = 1/24;
while 1
    time = now;
    if time - t0 > calInterval
        data_taking.qCloud.calibrationsXLD180322.calibration_lvl1(qes.util.hvar(false),qes.util.hvar(false));
        t0 = now;
    end
end