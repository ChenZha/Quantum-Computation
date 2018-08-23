classdef GetSParam_MeanAmp < GetSParam
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = GetSParam_MeanAmp(InstrumentObject)
            obj = obj@GetSParam(InstrumentObject);
            obj.numericscalardata = true;
        end
        function Run(obj)
            % Run the measurement
            Run@GetSParam(obj); % check object and its handle properties are isvalid or not
            if ~isempty(obj.data)
                obj.data = mean(abs(obj.data(1,:)));
            end
        end
    end
    
end