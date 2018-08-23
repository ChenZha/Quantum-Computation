classdef (Sealed = true) Wv_DC < Waveform
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        dcval = 0 % dc level
    end
    methods
        function obj = Wv_DC()
            obj = obj@Waveform();
            obj.directoutput = false;
            obj.dacoffset = false; % use awg offset to output dc
        end
        function set.dcval(obj,val)
            if isempty(val)
                return;
            end
            if ~isreal(val)
                error('Wv_DC:InvalidInput','dcval should be a real number!');
            end
            obj.dcval = val;
        end
        function GenWave(obj)
            GenWave@Waveform(obj); % check parameters
            obj.wvdata  = zeros(1,obj.length);
            obj.vpp = 0;
            obj.offset = obj.dcval;
        end
    end
end