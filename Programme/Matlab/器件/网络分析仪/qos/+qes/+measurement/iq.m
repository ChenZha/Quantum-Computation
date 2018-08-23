classdef (Abstract = true) iq < qes.measurement.measurement
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties (Abstract = true) % to be redefine in concrete subclasses. All iq subclasses should have this property!
        n	% number of samples,  probability = number of event occurence/n
    end

    methods
        function obj = iq(InstrumentObject)
            obj = obj@qes.measurement.measurement(InstrumentObject);
            obj.timeout = 60; % default timeout 60 seconds.
            obj.name = 'IQ';
            obj.numericscalardata = false;
        end
    end
end