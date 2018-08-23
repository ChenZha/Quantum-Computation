classdef GetSwI_SR620Timer < GetSwI
    % Measure switching current of a dc SQUID/Josephson junction under ramp driving by
    % using Stanford Instrument SR620 to measure the time at which the switching occurs.
    % a gate signal starts synchronously with the ramp is send to t SR620
    % to indicate the start time.
    % 
    % see the doc for a detailed decription.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        N  % number of samples
        RampRate % ramp rate of the SQUID ramp driving current
    end

	methods
        function obj = GetSwI_SR620Timer(InstrumentObject)
            if ~isa(InstrumentObject,'SR620Timer') || ~isvalid(InstrumentObject)
                error('GetSwI_SR620Timer:InvalidInput','InstrumentObject is not a valid SR620Timer class object!');
            end
            obj = obj@GetSwI(InstrumentObject);
            obj.timeout = 180; % default timeout 180 seconds.
        end
        function set.N(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetSwI_SR620Timer:InvalidInput','N should be a positive integer!');
            end
            obj.N = val;
            obj.InstrumentObject.samplesize = val;
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.N) || isempty(obj.RampRate)
                error('GetSwI_SR620Timer:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            for ii = 1:3
                T = obj.InstrumentObject.Run();
                if ~isempty(T) && ~ischar(T)
                    break;
                end
            end
            if ~ischar(T)
                obj.data = T*obj.RampRate;
            else
                obj.msg = I;
                obj.data = NaN;
            end
            obj.dataready = true;
        end
    end
    
end