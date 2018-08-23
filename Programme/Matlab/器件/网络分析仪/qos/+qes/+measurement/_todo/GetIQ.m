classdef (Abstract = true) GetIQ < Measurement
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties (Abstract = true) % to be redefine in concrete subclasses. All GetIQ subclasses should have this property!
        n	% number of samples,  probability = number of event occurence/N
    end

    methods
        function obj = GetIQ(InstrumentObject)
            obj = obj@Measurement(InstrumentObject);
            obj.timeout = 60; % default timeout 60 seconds.
        end
    end
end