classdef GetVolt_NIDAQUSB5132 < Measurement
    % Measure voltage signal by NI DAQ USB5132
    % Since the  digitizer is mainly used for other measurements, it is
    % better to kept the digitizer status as is. To avoid any setting of
    % the digitizer status, this class is designed to has no properties.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	methods
        function obj = GetVolt_NIDAQUSB5132(InstrumentObject)
            if ~isa(InstrumentObject,'NIDAQUSB5132') || ~isvalid(InstrumentObject)
                error('GetVolt_NIDAQUSB5132:InvalidInput','InstrumentObject is not a valid NIDAQUSB5132 class object!');
            end
            obj = obj@Measurement(InstrumentObject);
            obj.numericscalardata = false;
            obj.timeout = 300; % default timeout 300 seconds.
        end
        function Run(obj)
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            if ~obj.NIDAQUSB5132OBJ.running
                try
                    obj.NIDAQUSB5132OBJ.Run();
                catch
                    try
                        obj.NIDAQUSB5132OBJ.Config();
                        obj.NIDAQUSB5132OBJ.Run();
                    catch
                        obj.NIDAQUSB5132OBJ.Reset();
                        obj.NIDAQUSB5132OBJ.Run();
                    end
                end
            end
            try
                obj.data = obj.NIDAQUSB5132OBJ.FetchData();
            catch
                warning('GetVolt_NIDAQUSB5132:MeasurementError','Can not fectch data from digitizer!');
                obj.data = NaN;
                obj.extradata = NaN;
            end
            obj.dataready = true;
        end
    end
end