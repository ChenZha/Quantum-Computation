function SwitchEvents = Psw_NIDAQUSB5132(obj)
    % measure swithcing probability with NI Digitizer USB5132.
    % the signal should be a periodic stacastic switching voltage that
    % can be resolved with a fixed threshold and markered with a
    % square pulse just before each switching to indicate the positions
    % where swiching might occur. The signal runs continues, amplitude of
    % the marker should be higher than the amplitude of the switching signal.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com


    NIDAQUSB5132OBJ = obj.InstrumentObject;
    
    NumSeqPerFetch = obj.NumSeqPerFetch;
    NumSignalPerSeq = obj.NumSignalPerSeq;
    N = NumSignalPerSeq*NumSeqPerFetch+10; % add a little margin
    TallMarkerThreshold = obj.TallMarkerThreshold;
    MarkerThreshold = obj.MarkerThreshold;
    SignalThreshold = obj.SignalThreshold;
    MeasFreq = obj.MeasFreq;
    VSignalStartIdx = obj.VSignalStartIdx;
    VSignalEndIdx = obj.VSignalEndIdx;

    AcquisitionTime = N/MeasFreq;
    pause(1.02*AcquisitionTime); % getting data
    VSignal  = NIDAQUSB5132OBJ.FetchData();
    NSamples = NIDAQUSB5132OBJ.numsamples;
    
    % Devide the waveform into N equal segments, and count the swithing.
    % 1, first segmant starts from the beginning of waveform.

    NSamplesPerReadout = floor(NSamples/N);        % do not use round or ceil!
    % reorder switching voltage signal
        % Continues no trigger acquisition mode, unlike triggered
        % acquisition mode(which the acquired waveform always starts at a
        % known trigger signal), the waveform starts a random position, it could
        % by chance starts at 'a voltage peak positon'(meaning the position, the
        % voltage peak may not exist if the switch dose not occur at this
        % particular readout). In this case, each voltage peak will be counted
        % twice if the segmentation starts from the beginning of the acquired
        % waveform.

        % in sequence rabi measurement ...
    [~, idx] = max(VSignal);
    idx1 = idx - round(NSamplesPerReadout/20);
    if idx1 < 1
        idx1 = idx + round(NSamplesPerReadout/20);
    end
    VSignal = [VSignal, VSignal(1:idx1)];
    VSignal(1:idx1) = [];

    
    ii = 2;
    jj = 0;
    kk = 0;
    TallMarkerIdx = [];
    MarkerIdx = [];
    D = ceil(0.95*NSamplesPerReadout);
    while ii <= length(VSignal)
        if VSignal(ii) < TallMarkerThreshold && VSignal(ii-1) > TallMarkerThreshold
            % marker falling edge
            kk = kk + 1;
            TallMarkerIdx(kk) = ii;
            jj = jj + 1;
            MarkerIdx(jj) = ii;
            ii = ii + D;
        elseif VSignal(ii) < MarkerThreshold && VSignal(ii-1) > MarkerThreshold
            % marker falling edge
            jj = jj + 1;
            MarkerIdx(jj) = ii;
            ii = ii + D;
        end
        ii = ii + 1;
    end

    if jj ~= N
        if abs((jj-N)/N) > 0.1
            SwitchEvents = 'Voltage signal marker amplitude too low, marker threshhold too high or MeasFreq incorrect. Please check settings, AWG and cable connections.';
            Error = true;
    %         if isempty(dir('VoltageSignalErrosData'))
    %             mkdir('VoltageSignalErrosData');
    %         end
    %         save(['VoltageSignalErrosData\',datestr(now,30),'.mat'],'VSignal','MarkerIdx','N','jj');
    %         % obsolete, produces at lot of garbage.
        else
            Error = false;
        end
    else
        Error = false;
    end
    
    if isempty(TallMarkerIdx) || TallMarkerIdx(1) ~= MarkerIdx(1)
        SwitchEvents = 'Voltage signal marker amplitude too low, marker threshhold too high or MeasFreq incorrect. Please check settings, AWG and cable connections.';
        Error = true;
    end

    if Error
        return;
    end
    % figure();
    % plot(VSignal,'-x');
    VSignal =[ VSignal, zeros(1,N)];
    SwitchEvents = zeros(kk-1,NumSignalPerSeq);
    zz = 1;
    for ii = 1:kk-1
        idx = find(MarkerIdx>=TallMarkerIdx(ii) & MarkerIdx<TallMarkerIdx(ii+1));
        NMkrs = length(idx);
        if NMkrs ~= NumSignalPerSeq
            warning('Number of voltage markers less than number of sequence.');
            continue;
        end
        for uu = 1:NumSignalPerSeq
            SwitchVoltage = max(VSignal(MarkerIdx(idx(uu))+VSignalStartIdx:MarkerIdx(idx(uu))+VSignalEndIdx));
            if SwitchVoltage > SignalThreshold
                SwitchEvents(zz,uu) = 1;
            end
        end
        zz = zz + 1;
    end
    SwitchEvents(zz:end,:) = [];

end


