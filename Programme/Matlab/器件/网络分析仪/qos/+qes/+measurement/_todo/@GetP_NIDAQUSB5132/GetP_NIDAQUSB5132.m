classdef GetP_NIDAQUSB5132 < GetP
    % Measure switching probability of a dc SQUID/Josephson junction under
    % pulsed driving by using NI DAQ USB5132 for switching voltage signal
    % aquisition.
    % The signal is a periodic stacastic switching voltage that can be
    % resolved with a fixed threshold and markered with a square pulse just
    % before each switching to indicate the positions where swiching might
    % occur. The signal runs continues, amplitude of the marker should be
    % higher than the amplitude of the switching signal.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        N
        MarkerThreshold % threshold of marker
        SignalThreshold % threshold of switching signal
        MeasFreq % squid drivng pulse frequency
        VSignalStartIdx % start idx of switching signal
        VSignalEndIdx % end idx of switching signal
        MaxTries = 5;
    end
    
    methods (Access = private)
        [P, varargout] = SwitchingProb_NIDAQUSB5132(obj)
    end
	methods
        function obj = GetP_NIDAQUSB5132(InstrumentObject)
            if ~isa(InstrumentObject,'NIDAQUSB5132') || ~isvalid(InstrumentObject)
                error('GetP_NIDAQUSB5132:InvalidInput','InstrumentObject is not a valid NIDAQUSB5132 class object!');
            end
            obj = obj@GetP(InstrumentObject);
        end
        function set.N(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetP_NIDAQUSB5132:InvalidInput','N should be a positive integer!');
            end
            obj.N = val;
            if ~isempty(obj.MeasFreq)
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*obj.N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new config is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function set.MeasFreq(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetP_NIDAQUSB5132:InvalidInput','MeasFreq should be a positive integer!');
            end
            obj.MeasFreq = val;
            if ~isempty(obj.N)
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*obj.N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new config is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function set.MaxTries(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetP_NIDAQUSB5132:InvalidInput','MaxTries should be a positive integer!');
            end
            obj.MaxTries = val;
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.N) || isempty(obj.MarkerThreshold) || isempty(obj.SignalThreshold)||...
                    isempty(obj.MeasFreq) || isempty(obj.VSignalStartIdx) || isempty(obj.VSignalEndIdx) || isempty(obj.MaxTries)
                error('GetP_NIDAQUSB5132:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            ii = 1;
            while ii <= obj.MaxTries
                [P, SwitchingVoltages] = obj.SwitchingProb_NIDAQUSB5132();
                if ~ischar(P)
                    obj.data = P;
                    obj.extradata = SwitchingVoltages;
                    break;
                elseif ii == obj.MaxTries
                    obj.msg = P;
                    obj.data = NaN;
                    obj.extradata = NaN;
                end
                ii  = ii +1;
            end
            obj.dataready = true;
        end
        function ShowSwitchVoltage(obj)
            % Show switching voltages of each sample
            if isempty(obj.extradata) || isnan(obj.extradata(1))
                return;
            end
            figure('NumberTitle','off','Name','Switching Voltages','Color',[1,1,1]);
            plot(obj.extradata,'.');
            hold on;
            plot([1,length(obj.extradata)],[obj.SignalThreshold,obj.SignalThreshold],'-r');
            legend({'Voltage Signal','Threshhold'});
            xlabel('Nth Sample');
            ylabel('V');
            title(['P = ', num2str(obj.data,'%0.3f')]);
        end
    end
    
end