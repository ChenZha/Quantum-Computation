classdef Sweep_DC < Sweep
    % sweep DC source output
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        waittime = 0; % number of seconds to wait after setting DC Source
    end

	methods
        function obj = Sweep_DC(DCSourceObj)
            if ~isa(DCSourceObj,'DCSource') || ~isvalid(DCSourceObj)
                error('Sweep_DC:InvalidInput','DCSourceObj should be a valid DCSource class object!');
            end
            ExpParamObj = ExpParam(DCSourceObj,'dcval');
            ExpParamObj.name = 'DC Value';
            obj = obj@Sweep(ExpParamObj);
            obj.name = 'DC Value';
            ExpParamObj.callbacks = {@(x) pause(obj.waittime)};
        end
        function set.waittime(obj,val)
            if ~isempty(val) && isreal(val) && val >=0 
                obj.waittime = ceil(val);
                obj.paramobjs.callbacks = {@(x) pause(obj.waittime)};
            else
                error('Sweep_DC:SetError','waittime should be a non negative integer!');
            end
        end
    end
end