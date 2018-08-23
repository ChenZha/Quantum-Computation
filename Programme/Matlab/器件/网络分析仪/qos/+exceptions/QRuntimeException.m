classdef QRuntimeException < MException
    properties (SetAccess = private, GetAccess = private)
    end
    methods
        function obj = QRuntimeException(msgID,msgtext)
            obj = obj@MException(msgID,msgtext);
        end
    end
end