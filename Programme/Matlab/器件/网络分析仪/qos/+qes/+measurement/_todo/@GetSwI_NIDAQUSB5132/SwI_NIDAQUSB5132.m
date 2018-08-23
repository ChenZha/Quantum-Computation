function I = SwI_NIDAQUSB5132(obj)
% Measure switching current of a dc SQUID/Josephson junction under ramp driving by
% using NI DAQ USB5132 for switching voltage signal aquisition.

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
    % In continues no trigger acquisition mode, unlike in triggered
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
D = min(max(ceil(0.975*NSamplesPerReadout),10),NSamplesPerReadout);
while ii <= length(VSignal)
    if VSignal(ii) < MarkerThreshold && VSignal(ii-1) > MarkerThreshold
        % marker falling edge
        jj = jj +1;
        MarkerIdx(jj) = ii;
        ii = ii + D;
    end
    ii = ii +1;
end

if jj ~= N
    if abs((jj-N)/N) > 0.2
        I = 'Voltage signal marker amplitude too low, marker threshhold too high or MeasFreq incorrect. Please check settings, AWG and cable connections.';
        Error = true;
        if isempty(dir('VoltageSignalErrosData'))
            mkdir('VoltageSignalErrosData');
        end
        save(['VoltageSignalErrosData\',datestr(now,30),'.mat'],'VSignal','MarkerIdx','N','jj');
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
VSignal =[VSignal, zeros(1,N)];
I = NaN*zeros(1,jj);
for ii = 1:jj
    try
        idx = find(VSignal(MarkerIdx(ii)+VSignalStartIdx:MarkerIdx(ii)+VSignalEndIdx)>SignalThreshold,1);
    catch
        continue;
    end
    if isempty(idx)
        continue;
    end
    I(ii) = idx;

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

end
I(isnan(I)) = [];
I = I/obj.InstrumentObject.smplrate*obj.RampRate;


