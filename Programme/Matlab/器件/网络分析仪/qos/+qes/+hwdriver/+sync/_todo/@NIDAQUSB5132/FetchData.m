function VoltSignal = FetchData(obj)
    % fetch data from digitizer buffer WHEN DATA IS READY
    % VoltSignal is 1 by numsamples array if only one channel is enabled, 
    % 2 by numsamples if both channnels are enabled, the first row is the
    % voltage signal data of the first channel, the second row, the second
    % channel.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ~obj.running
        error('NIDAQUSB5132:FetchError',...
            'data acquisition not started, there is no data to fetch in digitizer buffer, use method Run to start a data acquisition before fetching data!');
    end
    if ~obj.chnl1enabled && ~obj.chnl2enabled
        error('NIDAQUSB5132:FetchError', 'both chanels are disabled!');
    end
    if  obj.chnl1enabled && ~obj.chnl2enabled
        SignalChannel = '0';
        WaveformArray = zeros(1, obj.numsamples);
        WfmInfo = [struct];
    elseif ~obj.chnl1enabled && obj.chnl2enabled
        SignalChannel = '1';
        WaveformArray = zeros(1, obj.numsamples);
        WfmInfo = [struct];
    else
        SignalChannel = '0,1';
        WaveformArray = zeros(1, 2*obj.numsamples);
        WfmInfo = [struct struct];
    end
    
    cnt = 0;
    while cnt < 3000
         Points_Done = obj.acquisition.Points_Done;
         if Points_Done >= obj.numsamples
             break;
         end
         pause(0.02); % todo: use timer
         cnt = cnt + 1;
    end
    if cnt >= 3000
        error('NIDAQUSB5132:FetchTimeout','Fetch data timeout!');
    end

    [WaveformArray , WfmInfo] =  invoke(obj.acquisition, 'fetchbinary8',SignalChannel, obj.timeout, obj.numsamples, WaveformArray, WfmInfo);
    
    if  obj.chnl1enabled && ~obj.chnl2enabled
        VoltSignal  = WaveformArray(1:obj.numsamples)*WfmInfo.gain + WfmInfo.Offset;
    elseif ~obj.chnl1enabled && obj.chnl2enabled
        VoltSignal  = WaveformArray(1:obj.numsamples)*WfmInfo.gain + WfmInfo.Offset;
    else
        VoltSignal  = [WaveformArray(1:obj.numsamples)*WfmInfo(1).gain + WfmInfo(1).Offset;...
            WaveformArray(obj.numsamples+1:2*obj.numsamples)*WfmInfo(2).gain + WfmInfo(2).Offset];
    end
end