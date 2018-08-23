classdef (Abstract = true) Wv_Piecewise < Waveform
    % Piecewise waveform
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        startpnt = 1; % startpnt: start time of the first segment, unit: points
        rise        % Rise time, unit: points, 1 by N, N is the number of pulses
        duration    % Duration, unit: points, 1 by N, N is the number of pulses
        amp         % Amplitude, unit: points, 1 by N, N is the number of pulses
    end
    methods
        function obj = Wv_Piecewise()
            obj = obj@Waveform();
        end
        function set.startpnt(obj,val)
            if val <= 0
                error('Wv_Piecewise:InvalidInput','startpnt value should be a positive integer!');
            elseif ceil(val) ~= val
                warning('Wv_Piecewise:ImproperInput', 'startpnt value rounded to integer!');
                val = ceil(val);
            end
            obj.startpnt = val;
        end
        function set.rise(obj,val)
            if val <= 0
                error('Wv_Piecewise:InvalidInput','rise value should be positive integers!');
            elseif ceil(val) ~= val
                warning('Wv_Piecewise:ImproperInput', 'rise value rounded to integer!');
                val = ceil(val);
            end
            obj.rise = val;
            if ~obj.ParametersSameLn()
                error('Wv_Piecewise:InvalidInput','parameters should have the same size!');
            end
        end
        function set.duration(obj,val)
            if val < 0
                error('Wv_Piecewise:InvalidInput','duration value should be non negative integers!');
            elseif ceil(val) ~= val
                warning('Wv_Piecewise:ImproperInput', 'duration value rounded to integer!');
                val = ceil(val);
            end
            obj.duration = val;
            if ~obj.ParametersSameLn()
                error('Wv_Piecewise:InvalidInput','parameters should have the same size!');
            end
        end
        function set.amp(obj,val)
            obj.amp = val;
            if ~obj.ParametersSameLn()
                error('Wv_Piecewise:InvalidInput','parameters should have the same size!');
            end
        end
    end
    methods (Access = protected)
        function CheckParameters(obj)
            if obj.startpnt - 1 + sum(obj.rise(:)+obj.duration(:)) > obj.length
                error('Wv_Piecewise:ParameterError', 'waveform length too short for the current parameter set!');
            end
            ln = [numel(obj.rise),numel(obj.duration),numel(obj.amp)];
            if any(ln==0)
                error('Wv_Piecewise:GenWaveError', 'some parameters are not set!');
            end
            if any(obj.rise<= 0) 
                error('Wv_Piecewise:GenWaveError', 'zero or negative rise(duration) found, generate a rise edge with zero or negative duration is impossible.');
            end
            if any(obj.duration < 0) 
                error('Wv_Piecewise:GenWaveError', 'negative duration found, generate a pulse with negative duration is impossible.');
            end
        end
    end
    methods (Access = private)
        function bol = ParametersSameLn(obj)
            % check all parameters are of the same length
            ln = [numel(obj.rise),numel(obj.duration),numel(obj.amp)];
            ln(ln == 0) = [];
            if isempty(ln) || numel(unique(ln))==1
                bol = true;
            else
                bol = false;
            end
        end
    end
end