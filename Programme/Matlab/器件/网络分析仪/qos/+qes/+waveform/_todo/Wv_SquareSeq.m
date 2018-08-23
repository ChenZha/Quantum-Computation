classdef (Sealed = true) Wv_SquareSeq < Waveform
    % sequare pulse sequence
    %

% Copyright 2015 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        gap         % gap between pulses, the first gap is the start time of the first pulse, unit: points, 1 by N, N is the number of pulses
        duration    % duration time of each pulse, unit: points, 1 by N, N is the number of pulses
        amp = 0.001         % 1 by 1, pulse amplitude
        rise = 1        % 1 by 1, rise/fall time of pulse
        edgefunc = 1; % edge function: 1/2: linear/sqrcos/gaussian, default linear
    end
    properties (Hidden = true, SetAccess = protected, GetAccess = protected)
        Wv_PlateauSeqObj
    end
    methods
        function obj = Wv_SquareSeq()
            obj = obj@Waveform();
            obj.Wv_PlateauSeqObj = Wv_PlateauSeq();
            obj.Wv_PlateauSeqObj.temperory = true; % temperoy waveform, not regist in HandleQES object tracing list
                                                   % in this way, at the deletion of a Wv_SquareSeq instance,
                                                   % its Wv_PlateauSeqObj waveform object will also be deleted
        end
        function set.gap(obj,val)
            if val < 0
                error('Wv_SquareSeq:InvalidInput','gap value should be non negative integers!');
            elseif ceil(val) ~= val
                warning('Wv_SquareSeq:ImproperInput', 'gap value rounded to integer!');
                val = ceil(val);
            end
            obj.gap = val;
            if ~isempty(obj.duration)
                if ~obj.ParametersSameLn()
                    warning('Wv_SquareSeq:ParameterError','size of gap and duration not equal or their value not set!');
                    return;
                end
                obj.length = sum(obj.gap+obj.duration)+2*length(obj.duration)*obj.rise+1;
            end
        end
        function set.duration(obj,val)
            if val < 0
                error('Wv_SquareSeq:InvalidInput','duration value should be non negative integers!');
            elseif ceil(val) ~= val
                warning('Wv_SquareSeq:ImproperInput', 'duration value rounded to integer!');
                val = ceil(val);
            end
            obj.duration = val;
            if ~isempty(obj.gap)
                if ~obj.ParametersSameLn()
                    warning('Wv_SquareSeq:ParameterError','size of gap and duration not equal or their value not set!');
                    return;
                end
                obj.length = sum(obj.gap+obj.duration)+2*length(obj.duration)*obj.rise+1;
            end
        end
        function set.rise(obj,val)
            if isempty(val)
                error('Wv_SquareSeq:InvalidInput','empty value!');
            end
            val = val(1);
            if val <= 0
                error('Wv_SquareSeq:InvalidInput','rise value should be a positive integer!');
            elseif ceil(val) ~= val
                warning('Wv_SquareSeq:ImproperInput', 'rise value rounded to integer!');
                val = ceil(val);
            end
            obj.rise = val;
            if ~isempty(obj.gap) && ~isempty(obj.duration)
                if ~obj.ParametersSameLn()
                    warning('Wv_SquareSeq:ParameterError','size of gap and duration not equal or their value not set!');
                    return;
                end
                obj.length = sum(obj.gap+obj.duration)+2*length(obj.duration)*obj.rise+1;
            end
        end
        function set.edgefunc(obj,val)
            if val ~=1 && val ~=2 && val ~=3
                error('Wv_SquareSeq:InvalidInput','illegal edgefuc value, edgefunc only has two choices: 1 for linear, 2 for square cosine and 3 for gaussian.');
            end
            obj.edgefunc = val;
        end
        function GenWave(obj)
            if ~obj.ParametersSameLn()
                error('Wv_SquareSeq:ParameterError','size of gap and duration not equal or their value not set!');
            end
            obj.length = sum(obj.gap+obj.duration)+2*length(obj.duration)*obj.rise+1;
            obj.Wv_PlateauSeqObj.length = obj.length;
            obj.Wv_PlateauSeqObj.edgefunc = obj.edgefunc;
            N = numel(obj.duration);
            obj.Wv_PlateauSeqObj.startpnt = obj.gap(1)+1;
            obj.Wv_PlateauSeqObj.rise = obj.rise*ones(1,2*N);
            tmp = [obj.duration;[obj.gap(2:end),0]];
            obj.Wv_PlateauSeqObj.duration = tmp(:)';
            temp = [obj.amp*ones(1,N);zeros(1,N)];
            obj.Wv_PlateauSeqObj.amp = temp(:)';
            
            obj.Wv_PlateauSeqObj.GenWave();
            obj.wvdata  = obj.Wv_PlateauSeqObj.wvdata;
            obj.vpp = obj.Wv_PlateauSeqObj.vpp;
            obj.offset = obj.Wv_PlateauSeqObj.offset;
        end
    end
    methods (Access = private)
        function bol = ParametersSameLn(obj)
            % check all parameters are of the same length
            ln = [numel(obj.gap),numel(obj.duration)];
            ln(ln == 0) = [];
            if isempty(ln) || numel(unique(ln))==1
                bol = true;
            else
                bol = false;
            end
        end
        function CheckParameters(obj)
            if sum(2*numel(obj.duration)*obj.rise+obj.duration(:)+obj.gap(:)) > obj.length - 1
                error('Wv_SquareSeq:ParameterError', 'waveform length too short for the current parameter set.');
            end
        end
    end
end