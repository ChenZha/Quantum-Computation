classdef GetSwI_NIDAQUSB5132 < GetSwI
    % Measure switching current of a dc SQUID/Josephson junction under ramp driving by
    % using NI DAQ USB5132 for switching voltage signal aquisition.
    % a marker is combined with the switching voltage signal to indicate
    % the start of the signal.
    % see the doc for detailed decription.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        N  % number of samples
        MarkerThreshold % threshold of marker
        SignalThreshold % threshold of switching signal
        VSignalStartIdx % start idx of switching signal
        VSignalEndIdx % end idx of switching signal
        RampRate % ramp rate of the SQUID ramp driving current
        MeasFreq % squid ramp drivng frequency
    end
    
    methods (Access = private)
        I = SwI_NIDAQUSB5132(obj)
    end
	methods
        function obj = GetSwI_NIDAQUSB5132(InstrumentObject)
            if ~isa(InstrumentObject,'NIDAQUSB5132') || ~isvalid(InstrumentObject)
                error('GetSwI_NIDAQUSB5132:InvalidInput','InstrumentObject is not a valid NIDAQUSB5132 class object!');
            end
            obj = obj@GetSwI(InstrumentObject);
        end
        function set.N(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetSwI_NIDAQUSB5132:InvalidInput','N should be a positive integer!');
            end
            obj.N = val;
            if ~isempty(obj.MeasFreq)
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*obj.N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new configuration is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function set.MeasFreq(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetSwI_NIDAQUSB5132:InvalidInput','MeasFreq should be a positive integer!');
            end
            obj.MeasFreq = val;
            if ~isempty(obj.N)
                obj.InstrumentObject.numsamples = obj.InstrumentObject.smplrate*obj.N/obj.MeasFreq;
                obj.InstrumentObject.Reset();  % a new configuration is done in Reset.
                obj.InstrumentObject.Run();
            end
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.N) || isempty(obj.MarkerThreshold) || isempty(obj.SignalThreshold)||...
                    isempty(obj.MeasFreq) || isempty(obj.VSignalStartIdx) || isempty(obj.VSignalEndIdx) ||...
                    isempty(obj.RampRate)
                error('GetSwI_NIDAQUSB5132:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            I = obj.SwI_NIDAQUSB5132();
            if ~ischar(I)
                obj.data = I(~isnan(I));
            else
                obj.msg = I;
                obj.data = NaN;
            end
            obj.dataready = true;
        end
    end
    
end