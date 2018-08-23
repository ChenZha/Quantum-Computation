classdef (Sealed = true) sequence < matlab.mixin.Copyable
    % sequence

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
		length
		jSequence
    end
    methods
        function obj = sequence(wv)
            if nargin > 0
                obj.jSequence = com.qos.waveform.Sequence(wv.jWaveform);
            else
                obj.jSequence = com.qos.waveform.Sequence();
            end
        end
		function val = get.length(obj)
            val = obj.jSequence.getLength();
        end
        function shiftPhase(obj,phase)
            obj.jSequence.shiftPhase(phase);
        end
    end
	methods (Access = protected)
		function newobj = copyElement(obj)
			newobj = copyElement@matlab.mixin.Copyable(obj);
			newobj.jSequence = com.qos.waveform.Sequence(obj.jSequence);
		end
	end
    methods (Hidden=true)
        function obj = mtimes(obj1,obj2)
            if ~isa(obj1,'qes.waveform.sequence') && isnumeric(obj1)
                obj = obj2.copy();
                obj.jSequence = obj.jSequence.scale(obj1);
            elseif ~isa(obj2,'qes.waveform.sequence') && isnumeric(obj2)
                obj = obj1.copy();
                obj.jSequence = obj.jSequence.scale(obj2);
            else
                throw(MException('QOS_sequence:multiplicationError',...
                    'a sequence can only be multiplied with an numeric scalar.'));
            end
        end
        function obj = plus(obj,obj2)
			obj.jSequence.add(obj2.jSequence);
		end
		function obj = minus(obj,obj2)
            obj2.jSequence.scale(-1);
			obj.jSequence.add(obj2.jSequence);
		end
		function obj = uminus(obj)
			obj.jSequence.scale(-1);
		end
        function obj = vertcat(varargin)
			obj = horzcat(varargin);
        end
		function obj = horzcat(varargin)
            
            if isempty(varargin{1})
                varargin(1) = [];
            end
            if isempty(varargin{end})
                varargin(end) = [];
            end
            numWv = numel(varargin);
			obj = varargin{1};
            % no copying here for efficiency as copying is only needed
            % in special cases, the copying must be done by the caller if neccessary
            % obj = copy(varargin{1}); 
            for ii = 2:numWv
                if isa(varargin{ii},'qes.waveform.sequence')
                    obj.jSequence.concat(varargin{ii}.jSequence);
                else
                    obj.jSequence.concat(varargin{ii}.jWaveform);
                end
            end
        end
    end
end