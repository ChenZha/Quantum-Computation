function [P, varargout] = SwitchingProb_NIDAQUSB5132(obj)
    % measure swithcing probability with NI Digitizer USB5132.
    % the signal should be a periodic stacastic switching voltage that
    % can be resolved with a fixed threshold and markered with a
    % square pulse just before each switching to indicate the positions
    % where swiching might occur. The signal runs continues, amplitude of
    % the marker should be higher than the amplitude of the switching signal.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com


    NIDAQUSB5132OBJ = obj.InstrumentObject;
    N = obj.N;
    MarkerThreshold = obj.MarkerThreshold;
    SignalThreshold = obj.SignalThreshold;
    MeasFreq = obj.MeasFreq;
    VSignalStartIdx = obj.VSignalStartIdx;
    VSignalEndIdx = obj.VSignalEndIdx;

    AcquisitionTime = N/MeasFreq;
    pause(1.02*AcquisitionTime); % getting data
    VSignal  = NIDAQUSB5132OBJ.FetchData();
    NSamples = NIDAQUSB5132OBJ.numsamples;
    % % Band stop filtering
    % if DigitizerSettings.BandStopFilter1Para.On
    %     VSignal = BandStopFilter(VSignal,DigitizerSettings.BandStopFilter1Para.LowerStopFreq,...
    %         DigitizerSettings.BandStopFilter1Para.UpperStopFreq,...
    %         DigitizerSettings.BandStopFilter1Para.BandLowerEdgeFreq,...
    %         DigitizerSettings.BandStopFilter1Para.BandUpperEdgeFreq,...
    %         DigitizerSettings.BandStopFilter1Para.EdgeAttenuation,...
    %         DigitizerSettings.BandStopFilter1Para.StopAttenuation,...
    %         DigitizerSettings.SampleRate);
    % end
    % 
    % if DigitizerSettings.BandStopFilter2Para.On
    %     VSignal = BandStopFilter(VSignal,DigitizerSettings.BandStopFilter2Para.LowerStopFreq,...
    %         DigitizerSettings.BandStopFilter2Para.UpperStopFreq,...
    %         DigitizerSettings.BandStopFilter2Para.BandLowerEdgeFreq,...
    %         DigitizerSettings.BandStopFilter2Para.BandUpperEdgeFreq,...
    %         DigitizerSettings.BandStopFilter2Para.EdgeAttenuation,...
    %         DigitizerSettings.BandStopFilter2Para.StopAttenuation,...
    %         DigitizerSettings.SampleRate);
    % end
    % 
    % if DigitizerSettings.BandStopFilter3Para.On
    %     VSignal = BandStopFilter(VSignal,DigitizerSettings.BandStopFilter3Para.LowerStopFreq,...
    %         DigitizerSettings.BandStopFilter3Para.UpperStopFreq,...
    %         DigitizerSettings.BandStopFilter3Para.BandLowerEdgeFreq,...
    %         DigitizerSettings.BandStopFilter3Para.BandUpperEdgeFreq,...
    %         DigitizerSettings.BandStopFilter3Para.EdgeAttenuation,...
    %         DigitizerSettings.BandStopFilter3Para.StopAttenuation,...
    %         DigitizerSettings.SampleRate);
    % end


    % Devide the waveform into N equal segments, and count the swithing.
    % 1, first segmant starts from the beginning of waveform.
    NSwitchs = 0;
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
    MarkerIdx = [];
    D = ceil(0.95*NSamplesPerReadout);
    while ii <= length(VSignal)
        if VSignal(ii) < MarkerThreshold && VSignal(ii-1) > MarkerThreshold
            % marker falling edge
            jj = jj + 1;
            MarkerIdx(jj) = ii;
            ii = ii + D;
        end
        ii = ii + 1;
    end

    if jj ~= N
        if abs((jj-N)/N) > 0.1
            P = 'Voltage signal marker amplitude too low, marker threshhold too high or MeasFreq incorrect. Please check settings, AWG and cable connections.';
            varargout{1} = P;
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

    if Error
        return;
    end
    % figure();
    % plot(VSignal,'-x');
    VSignal =[ VSignal, zeros(1,N)];
    SwitchEvents = zeros(1,jj);
    SwitchVoltage = NaN*zeros(1,jj);
    for ii = 1:jj
        SwitchVoltage(ii) = max(VSignal(MarkerIdx(ii)+VSignalStartIdx:MarkerIdx(ii)+VSignalEndIdx));
    %     SwitchVoltage(ii) = VSignal(MarkerIdx(ii)+2);
        if SwitchVoltage(ii) > SignalThreshold
            NSwitchs = NSwitchs+1;
            SwitchEvents(ii) = 1;
        end
    end

    %     if N < 500
    %         nbins = ceil(N/10);
    %     elseif N < 1500
    %         nbins = ceil(N/15);
    %     elseif N < 3000
    %         nbins = ceil(N/20);
    %     else
    %         nbins = ceil(N/30);
    %     end
    %     [V_dis,V] = hist(SwitchVoltage,nbins);
    %     figure;
    %     plot(V,V_dis,'-x');

    P  = NSwitchs/N;

    % figure();
    % plot(SwitchVoltage,'x');
    % xlabel('No.');
    % ylabel('Switching Voltage');

    varargout{1} = SwitchVoltage;
end


