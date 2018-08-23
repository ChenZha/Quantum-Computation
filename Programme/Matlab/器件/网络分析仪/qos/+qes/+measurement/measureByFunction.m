classdef measureByFunction < qes.measurement.measurement
    % measurement 

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        func
    end
    methods
        function obj = measureByFunction(func)
            obj = obj@qes.measurement.measurement([]);
            assert(isa(func,'function_handle'));
            obj.func = func;
        end
        
        function Run(obj)
            Run@qes.measurement.measurement(obj);
            obj.dataready = false;
            obj.data = feval(obj.func);
            obj.dataready = true;
        end
    end
end