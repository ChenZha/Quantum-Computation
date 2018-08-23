classdef Sweep_MWFreq < Sweep
    % sweep microwave frequency
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	methods
        function obj = Sweep_MWFreq(MWSourceObj)
            if ~isa(MWSourceObj,'MWSource') || ~isvalid(MWSourceObj)
                error('Sweep_MWFreq:InvalidInput','MWSourceObj should be a valid MWSource class object!');
            end
            ExpParamObj = ExpParam(MWSourceObj,'frequency');
            ExpParamObj.name = 'MW Frequency(Hz)';
            obj = obj@Sweep(ExpParamObj);
            obj.name = 'MW Frequency';
        end
    end
end