classdef (Abstract = true) iobase < handle
% async io base class

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        timeout = 10 % seconds
        InputBufferSize = 1024*10 % bytes
        OutputBufferSize = 1024*10  % bytes
        BytesAvailableFcnMode = 'terminator'   %{'terminator'}, 'bytes';
        BytesAvailableFcnCount % bytes, only used when BytesAvailableFcnMode = 'bytes'
    end
    properties (Dependent = true)
        isopen = false
    end
    properties (SetAccess = protected, GetAccess = protected)
        backend % a icinterface object
        write_deferred % no used for the moment
        read_deferred % no used for the moment
    end

    methods
        function set.timeout(obj,val)
            obj.backend.timeout = val;
        end
        function val = get.timeout(obj)
            val = obj.backend.timeout;
        end
        function set.InputBufferSize(obj,val)
            obj.backend.InputBufferSize = val;
        end
        function val = get.InputBufferSize(obj)
            val = obj.backend.InputBufferSize;
        end
        function set.OutputBufferSize(obj,val)
            obj.backend.OutputBufferSize = val;
        end
        function val = get.OutputBufferSize(obj)
            val = obj.backend.OutputBufferSize;
        end
        function set.BytesAvailableFcnMode(obj,val)
            obj.backend.BytesAvailableFcnMode = val;
        end
        function val = get.BytesAvailableFcnMode(obj)
            val = obj.backend.BytesAvailableFcnMode;
        end
        function set.BytesAvailableFcnCount(obj,val)
            obj.backend.BytesAvailableFcnCount = val;
        end
        function val = get.BytesAvailableFcnCount(obj)
            val = obj.backend.BytesAvailableFcnCount;
        end

        function val = get.isopen(obj)
            val = obj.backend.Status(1) =='o';
        end
        function d = query(obj,cmd)
            % query response in text format
            d = fread(obj);
            function result = cb(result)
                result = char(result);
            end
            d.addCallback(@cb);
            [~] = fprintf(obj,cmd);
        end
        function d = fprintf(obj,cmd)
            % sends out text string
            % note: fwrite is the fastest, if speed is a priority, consider
            % using binary based commands and use fwrite instead of fprintf
            % to transfer
            d = mtwisted.defer.Deferred();
            function result = cb1(result)
                obj.backend.OutputEmptyFcn = '';
            end
            d.addBoth(@cb1);
            function cb2(~,~)
                d.callback([]);
            end
            obj.backend.OutputEmptyFcn = @cb2;
            try
%                 fprintf(igetfield(obj.backend, 'jobject'), cmd, 1);
                fprintf(obj.backend, cmd, 1); 
            catch aException
%                 newExc = MException('mtwisted:io:asyncio:backendFprintf:opfailed', aException.message);
                d.errback(mtwisted.Failure(aException));
            end
        end
        function d = fwrite(obj, bytes)
            % sends out bytes 
            % note: fwrite is the fastest, if speed is a priority, use
            % fwrite instead of fprintf.
            d = mtwisted.defer.Deferred();
            function result = cb1(result)
                obj.backend.OutputEmptyFcn = '';
            end
            d.addBoth(@cb1);
            function cb2(~,~)
                d.callback([]);
            end
            obj.backend.OutputEmptyFcn = @cb2;
            try
%                fwrite(igetfield(obj.backend, 'jobject'), bytes, length(bytes), 5, 1, 0);
                fwrite(obj.backend, bytes, 1);
            catch aException
%                 newExc = MException('mtwisted:io:asyncio:backendFwrite:opfailed', aException.message);
                d.errback(mtwisted.Failure(aException));
            end
        end
        function d = fread(obj,numbytes)
            % read numbytes bytes from input buffer
            % if numbytes not  specified, read all bytes available in
            % input buffer
            % note: fread is the fastest, if speed is a priority, use fread
            % instead of fscanf.
            if nargin < 2
                numbytes = [];
            end
            TS = obj.backend.TransferStatus;
            if TS(1)=='r' || length(TS) == 10
                error('An asynchronous read is already in progress.');
            end
            d = mtwisted.defer.Deferred();
            function result = cb1(result)
                obj.backend.BytesAvailableFcn = '';
            end
            d.addBoth(@cb1);
            function cb2(~,~)
                if isempty(numbytes)
                    try 
                        data = fread(obj.backend,obj.backend.BytesAvailable);
    %                     out = fread(igetfield(obj.backend, 'jobject'), obj.backend.BytesAvailable, 5, 0);
    %                     data = out(1);
                        d.callback(data);
                    catch ME
                        d.errback(mtwisted.Failure(ME));
                    end
                elseif numbytes <= obj.backend.BytesAvailable
                    data = fread(obj.backend,numbytes,'uchar');
%                     out = fread(igetfield(obj.backend, 'jobject'), numbytes, 5, 0);
%                     data = out(1);
                    d.callback(data);
                else
                    ME = MException('mtwisted:io:asyncio:backendFread:opfailed',...
                        'number of bytes to read exceeding number of bytes available in input buffer.');
                    d.errback(mtwisted.Failure(ME));
                end
            end
            obj.backend.BytesAvailableFcn = @cb2;
            obj.read_deferred = d; % no used for the moment
            try
%                 readasync(igetfield(obj.backend, 'jobject'), numbytes);
                readasync(obj.backend);
            catch aException
%                 newExc = MException('mtwisted:io:asyncio:backendReadasync:opfailed', aException.message);
                d.errback(mtwisted.Failure(aException));
            end
        end
        function flushinput(obj)
            flushinput(obj.backend);
        end
        function flushoutput(obj)
            flushoutput(obj.backend);
        end
        function fopen(obj)
            if obj.backend.Status(1)=='c'
                fopen(obj.backend);
            end
        end
        function fclose(obj)
            if obj.backend.Status(1)=='o'
                fclose(obj.backend);
            end
        end
        function delete(obj)
            fclose(obj.backend);
        end
    end
    methods (Access = protected, Hidden = true)
        % the counter part of fprintf, fscanf does not have async mode as
        % for as I know, keep a syncronized fscanf for private usage
        function d = fscanf(obj)
            d = fscanf(obj.backend);
        end
    end
end