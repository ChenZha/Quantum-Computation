classdef alazarATS_Client < qes.hwdriver.hardware
    % dirver for Alazar Tech ATS Digitizer to run on a remote Matlab,
    % client
    % 

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        busy = false
        numsamples
    end
    properties (SetAccess = private, GetAccess = private)
        tcpipobj
    end
    methods
        function obj = alazarATS_Client(name,ip,port,numsamples)
            obj = obj@qes.hwdriver.hardware(name);
            obj.tcpipobj = mtwisted.io.async.tcpip_client(ip,port);
            obj.numsamples = numsamples;
            numbytes = numsamples*2*8;
            obj.tcpipobj.InputBufferSize = numbytes;
            obj.tcpipobj.Timeout = 30;
            obj.tcpipobj.BytesAvailableFcnMode = 'byte';
            obj.tcpipobj.BytesAvailableFcnCount = numbytes;
            fopen(obj.tcpipobj);
        end
        function d = FetchData(obj)
            persistent lastdeferred
            function result = run_next_deferred(result,d_)
                d_.callback();
            end
            function result = run_next_fetch(~)
                result = obj.FetchData();
            end
            if obj.busy
                d = mtwisted.defer.Deferred();
                d.addBoth(@run_next_fetch);
                lastdeferred.addBoth(@(x)run_next_deferred(x,d));
            else
                d = FetchData_(obj);
            end
            lastdeferred = d;
        end
        function Reset(obj)
            obj.busy = false;
            flushinput(obj.tcpipobj);
            flushoutput(obj.tcpipobj);
        end
        function Open(obj)
            fopen(obj.tcpipobj);
        end
        function Close(obj)
            fclose(obj.tcpipobj);
        end
        function delete(obj)
            fclose(obj.tcpipobj);
        end
    end
    methods (Access = private, Hidden = true)
        function d = FetchData_(obj)
            obj.busy = true;
            function result = set_busy_status(result)
                obj.busy = false;
            end
            function result = cb1(result)
                result = typecast(result,'double');
                result = reshape(result,obj.numsamples,2)';
            end
            d = fread(obj.tcpipobj);
            d.addBoth(@set_busy_status);
            d.addCallback(@cb1);
            d2 = fprintf(obj.tcpipobj,'FetchData');
            function result = cb2(result)
                if ~d.called
                    d.errback(result);
                end
            end
            d2.addErrback(@cb2);
        end
    end
end