function Temperature = B201XLD_1_Temperature(cfg)
    [Temperature, ~] = qes.util.blueForsTemperatureLogReader(cfg.logRootDir,cfg.Chnl);
end