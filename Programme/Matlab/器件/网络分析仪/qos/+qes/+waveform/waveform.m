classdef (Abstract = true) waveform < handle & matlab.mixin.Copyable
    % base class of all waveform classes

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phase = 0; % phase of frequency mxing
        carrierFrequency = 0;
%         xfrFunc
    end
	properties (SetAccess = private)
		length
    end
	properties (SetAccess = protected)
		jWaveform
	end
    methods
		function set.phase(obj,val)
			obj.jWaveform.phase = single(val);
		end
		function val = get.phase(obj)
			val = obj.jWaveform.phase;
        end
        function set.carrierFrequency(obj,val)
			obj.jWaveform.carrierFrequency = val;
		end
		function val = get.carrierFrequency(obj)
			val = obj.jWaveform.carrierFrequency;
		end
		function val = get.length(obj)
            val = obj.jWaveform.length;
        end
        function v = freqSamples(obj,f)
            v = obj.jWaveform.freqSamples(f);
			v = reshape(v,2,[]);
        end
    end
    methods (Access = protected)
		function newobj = copyElement(obj)
			newobj = copyElement@matlab.mixin.Copyable(obj);
			newobj.jWaveform = obj.jWaveform.copy();
		end
	end
    methods (Hidden=true)
        function obj1 = plus(obj1,obj2)
			obj1.jWaveform.add(obj2.jWaveform);
        end
        function obj = mtimes(obj1,obj2)
            if isnumeric(obj1)
                obj2.jWaveform.scale(obj1);
                obj = obj2;
            elseif isnumeric(obj2)
                obj1.jWaveform.add(obj2);
                obj = obj1;
            else
                error('waveform multiplication is not supported.');
            end
        end
        function obj = uminus(obj1)
            obj = obj1.scale(-1);
        end
        function obj1 = deriv(obj1)
			obj1.jWaveform = obj1.jWaveform.deriv();
        end
        function obj = dragify(obj,alpha)
            obj.jWaveform = obj.jWaveform.dragify(alpha);
        end
        function obj = vertcat(varargin)
			obj = horzcat(varargin);
        end
		function obj = horzcat(varargin)
            obj = [qes.waveform.sequence(varargin{1}),varargin{2:end}];
        end
    end
end