classdef jpa < sqc.qobj.qobject
    properties
        startDelay = 0
    end
    methods
        function set.startDelay(obj,val)
            if isempty(val)
                throw(MException('QOS_jpa:invalidInput','startDelay can not be empty.'));
            end
            obj.startDelay = val;
        end
    end
end