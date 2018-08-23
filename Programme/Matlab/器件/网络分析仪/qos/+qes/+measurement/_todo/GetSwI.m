classdef (Abstract = true) GetSwI < Measurement
    % Abstract class for switch current measurement.
    % All switch current measurement classes with different instruments
    % are subclasses of this class.
    % Purpose of introducing this dummy class:
    % With GetSwI, to determine if a object 'obj' is a switch current measurement:
    % isa(obj,'GetSwI')
    % without GetP: isa(obj,'GetSwI_NIDAQUSB5132') || isa(obj,'GetSwI_XXXX') || ...
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = GetSwI(InstrumentObject)
            obj = obj@Measurement(InstrumentObject);
            obj.numericscalardata = false;
            obj.timeout = 180; % default timeout 180 seconds.
        end
    end
end