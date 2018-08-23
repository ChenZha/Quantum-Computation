classdef GetPSeq_NIDAQUSB5132 < Measurement
    % Measure switching probability of a dc SQUID/Josephson junction under pulsed driving by
    % using NI DAQ USB5132 for switching voltage signal aquisition.
    % a marker is combined with the switching voltage signal to indicate
    % the start of the signal.
    % see the doc for a detailed decription.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        NumFetch
        NumSeqPerFetch
        NumSignalPerSeq
        TallMarkerThreshold
        MarkerThreshold % threshold of marker
        SignalThreshold % threshold of switching signal
        MeasFreq % squid drivng pulse frequency
        VSignalStartIdx % start idx of switching signal
        VSignalEndIdx % end idx of switching signal
    end
    
    methods (Access = private)
        SwitchEvents = Psw_NIDAQUSB5132(obj)
    end
	methods
        function obj = GetPSeq_NIDAQUSB5132(InstrumentObject)
            if ~isa(InstrumentObject,'NIDAQUSB5132') || ~isvalid(InstrumentObject)
                error('GetPSeq_NIDAQUSB5132:InvalidInput','InstrumentObject is not a valid NIDAQUSB5132 class object!');
            end
            obj = obj@Measurement(InstrumentObject);
        end
        function set.NumFetch(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetPSeq_NIDAQUSB5132:InvalidInput','NumFetch should be a positive integer!');
            end
            obj.NumFetch = val;
        end
        function set.NumSeqPerFetch(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetPSeq_NIDAQUSB5132:InvalidInput','NumSeqPerFetch should be a positive integer!');
            end
            obj.NumSeqPerFetch = val;
            if ~isempty(obj.MeasFreq) && ~isempty(obj.NumSignalPerSeq)
                N = obj.NumSignalPerSeq*obj.NumSeqPerFetch;
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new config is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function set.NumSignalPerSeq(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetPSeq_NIDAQUSB5132:InvalidInput','NumSignalPerSeq should be a positive integer!');
            end
            obj.NumSignalPerSeq = val;
            if ~isempty(obj.MeasFreq) && ~isempty(obj.NumSeqPerFetch)
                N = obj.NumSignalPerSeq*obj.NumSeqPerFetch;
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new config is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function set.MeasFreq(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetPSeq_NIDAQUSB5132:InvalidInput','MeasFreq should be a positive integer!');
            end
            obj.MeasFreq = val;
            if ~isempty(obj.NumSeqPerFetch) && ~isempty(obj.NumSignalPerSeq)
                N = obj.NumSignalPerSeq*obj.NumSeqPerFetch;
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new config is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.NumFetch) ||isempty(obj.NumSeqPerFetch)||...
                    isempty(obj.NumSignalPerSeq)|| isempty(obj.TallMarkerThreshold) ||...
                    isempty(obj.MarkerThreshold) ||...
                    isempty(obj.SignalThreshold)||...
                    isempty(obj.MeasFreq) || isempty(obj.VSignalStartIdx) ||...
                    isempty(obj.VSignalEndIdx)
                error('GetPSeq_NIDAQUSB5132:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            SwitchEvents = [];
            for ii = 1: obj.NumFetch
                SwitchEvents_ = obj.Psw_NIDAQUSB5132();
                if ischar(SwitchEvents_)
                    obj.msg = SwitchEvents_;
                    break;
                else
                    SwitchEvents = [SwitchEvents;SwitchEvents_];
                end
            end
            sz = size(SwitchEvents);
            obj.data = sum(SwitchEvents,1)/sz(1);
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