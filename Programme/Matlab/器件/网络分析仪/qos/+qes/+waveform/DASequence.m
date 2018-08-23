classdef (Sealed = true) DASequence < handle % matlab.mixin.Copyable
    % da sequence

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
		outputDelay = [0,0];
		outputDelayByHardware = false;
        xfrFunc
        padLength
    end
	properties (SetAccess = private, GetAccess = private)
		jDASequence
    end
    methods
        function obj = DASequence(chnl, sequence)
            obj.jDASequence = com.qos.waveform.DASequence(chnl,sequence.jSequence);
        end
		%
		function set.outputDelay(obj,val)
			obj.jDASequence.setOutputDelay(val);
		end
		function val = get.outputDelay(obj)
			val = obj.jDASequence.getOutputDelay();
            if isempty(val) % a bug to be fixed
                val = [0,0];
            else
                val = double(val);
            end
		end
		%
		function set.outputDelayByHardware(obj,val)
			obj.jDASequence.outputDelayByHardware=val;
		end
		function val = get.outputDelayByHardware(obj)
			val = obj.jDASequence.outputDelayByHardware;
		end
		%
		function set.xfrFunc(obj,val)
			obj.jDASequence.setXfrFunc(val);
		end
		function val = get.xfrFunc(obj)
			val = obj.jDASequence.getXfrFunc();
        end
        %
		function set.padLength(obj,val)
			obj.jDASequence.setPadLength(val);
		end
		function val = get.padLength(obj)
			val = obj.jDASequence.padLength;
		end
        
        function [v]= samples(obj)
            v = obj.jDASequence.samples();
			v = reshape(v,2,[]);
        end
    end
end