classdef DefGen_Return < MException
    % 
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties(SetAccess = private)
        value
    end
    methods
        function self = DefGen_Return(val)
            self.value = val;
            self.identifier = 'mtwisted:DefGen_Return';
        end
    end
end