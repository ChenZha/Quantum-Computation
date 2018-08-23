classdef tcpip_client < mtwisted.io.async.iobase
    % a wrapper of matlab tcpip with async io
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


    properties (SetAccess = immutable)
        ip
        port
    end
    methods
        function obj = tcpip_client(ip,port)
            if nargin < 2
            	port = 80;
            end
            obj.backend = tcpip(ip,port,'NetworkRole','client');
            obj.ip = ip;
            obj.port = port;
            obj.backend.ReadAsyncMode = 'manual'; 
        end
    end
end