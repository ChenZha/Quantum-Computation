classdef (Abstract = true) GetP < Measurement
    % Abstract class for probability measurement. All probability measurement
    % classes are subclasses of this class.
    % Purpose of creating this dummy class:
    % With GetP, to determine if a object 'obj' is a probability measurement:
    % isa(obj,'GetP')
    % without GetP: isa(obj,'GetP_NIDAQUSB5132') || isa(obj,'GetP_XXXX') || ...
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties (Abstract = true) % to be redefine in concrete subclasses. All GetP subclasses should have this property!
        N	% number of samples,  probability = number of event occurence/N
    end

    methods
        function obj = GetP(InstrumentObject)
            obj = obj@Measurement(InstrumentObject);
            obj.timeout = 60; % default timeout 60 seconds.
        end
    end
end