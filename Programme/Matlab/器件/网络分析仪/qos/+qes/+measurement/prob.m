classdef (Abstract = true) prob < qes.measurement.measurement
    % Abstract class for probability measurement. All probability measurement
    % classes are subclasses of this class.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties (Abstract = true) % to be redefine in concrete subclasses. All prob subclasses should have this property!
        n	% number of samples,  probability = number of event occurence/n
    end

    methods
        function obj = prob(InstrumentObject)
            obj = obj@qes.measurement.measurement(InstrumentObject);
            obj.timeout = 60; % default timeout 60 seconds.
            obj.name = 'probability';
            obj.numericscalardata = true;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
        end
    end
end