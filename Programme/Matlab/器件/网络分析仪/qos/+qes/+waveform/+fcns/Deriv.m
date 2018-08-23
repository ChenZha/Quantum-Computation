function Wv = Deriv(obj,dt)
    % waveform derivative
    % dt, dirivative step length, default 0.1, unit: 1/sampling frequency
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    obj = copy(obj); % do make a copy!
    if nargin == 1
        dt = 0.1;
    end
    timefcn = @(t)obj.TimeFcn(obj,t); % note: TimeFcn is a static method
    timefcn = @(t)(timefcn(t+dt)-timefcn(t-dt))/(2*dt);
    freqfcn = @obj.FreqFcn;
    freqfcn = @(f)2j*pi*f.*freqfcn(f);
    Wv = qes.waveform.arbFcn(obj.length, timefcn, freqfcn);
end