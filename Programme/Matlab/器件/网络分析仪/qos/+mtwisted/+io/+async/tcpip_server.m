classdef tcpip_server < mtwisted.io.async.iobase
    % ticpip server
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = immutable)
        ip
        port
    end
    methods
        function obj = tcpip_server(ip,port)
            if nargin < 2
            	port = 80;
            end
            obj.backend = tcpip(ip,port,'NetworkRole','server');
            obj.ip = ip;
            obj.port = port;
            obj.backend.ReadAsyncMode = 'manual'; 
        end
    end
end