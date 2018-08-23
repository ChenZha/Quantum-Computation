classdef Sweep_MWPwr < Sweep
    % sweep microwave power
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	methods
        function obj = Sweep_MWPwr(MWSourceObj)
            if ~isa(MWSourceObj,'MWSource') || ~isvalid(MWSourceObj)
                error('Sweep_MWFreq:InvalidInput','MWSourceObj should be a valid MWSource class object!');
            end
            ExpParamObj = ExpParam(MWSourceObj,'power');
            ExpParamObj.name = 'MW Power(dBm)';
            obj = obj@Sweep(ExpParamObj);
            obj.name = 'MW Power';
        end
    end
end