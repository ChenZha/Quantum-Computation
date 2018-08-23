classdef arbFcn < qes.waveform.waveform
    % Arbitary fucntion waveform
    %

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (SetAccess = private, GetAccess = private)
        timefcn
        freqfcn
    end
    methods
        function obj = arbFcn(ln,timefcn,freqfcn)
            % checking removed for efficiency
%             if ~isa(timefcn,'function_handle') || ~isa(freqfcn,'function_handle')
%                 error('arbFcn:invalidinput','timefcn and freqfcn should be function handles.');
%             end
            obj = obj@qes.waveform.waveform(ln);
            obj.timefcn = timefcn;
            obj.freqfcn = freqfcn;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            t = t-obj.t0;
            v = obj.timefcn(t);
        end
        function v = FreqFcn(obj,f)
            v = exp(-1j*2*pi*f*obj.t0).*obj.freqfcn(f);
        end
    end
end